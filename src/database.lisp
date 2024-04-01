(in-package :mx-proxy)

(defvar *db-file* nil
  "Filename of the current Sqlite connection.")

(defun migrate (&key recreate ensure)
  (loop :for table :in '(http:request http:response http:message-pair)
        :do (cond (recreate (mito:recreate-table table))
                  (ensure   (mito:ensure-table-exists table))
                  (t        (mito:migrate-table table)))))

(defun connect (&key (file "/tmp/proxy.sqlite3"))
  "Connect to a Sqlite database.
This serves as a 'project file' for proxy sessions."
  (mito:connect-toplevel :sqlite3 :database-name file)
  (setf *db-file* file)
  (migrate :ensure t))

(defun insert-pair (request response &key (metadata '((:normal))))
  "Insert a message pair into the database.
   Optionally provide an alist of metadata"
  (let ((mp (mito:insert-dao
             (make-instance 'http:message-pair
                            :metadata metadata
                            :request (mito:insert-dao request)
                            :response (mito:insert-dao response)))))
    (proxy/hooks:run-hook :on-message-pair mp)
    mp))

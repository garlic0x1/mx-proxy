(in-package :http)

(defvar *server* nil)
(defvar *halt* nil)
(defvar *host* "Offline")

(defun accept-connection (sock handler)
  (let ((conn (us:socket-accept sock :element-type '(unsigned-byte 8))))
    (bt:make-thread
     (lambda ()
       (unwind-protect (funcall handler conn)
         (us:socket-close conn))))))

(defun server-loop (host port handler)
  (let ((sock (us:socket-listen host port :element-type '(unsigned-byte 8))))
    (unwind-protect (until *halt* (accept-connection sock handler))
      (us:socket-close sock))))

(defun stop-server (&key force)
  "Kill the thread if this isn't enough."
  (setf *host* "Offline")
  (setf *halt* t)
  (when force (bt:destroy-thread *server*)))

(defun start-server (&key (host "127.0.0.1")
                          (port 5000)
                          (handler (error "Must provide handler.")))
  (setf *host* (format nil "~a:~a" host port))
  (setf *halt* nil)
  (setf *server* (bt:make-thread
                  (lambda ()
                    (server-loop host port handler)))))

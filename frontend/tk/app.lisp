(in-package :mx-proxy/tk)

(define-command apropos-command () ()
  "Get info about a command."
  (prompt-for-string
   (lambda (str) (alert (gethash str mx-proxy:*commands*)))
   :completion (completion (mx-proxy:all-command-names))
   :message "Apropos command"))

(define-command apropos-function () ()
  "Get info about a function."
  (prompt-for-string
   (lambda (str)
     (with-tk-error
       (alert
        (with-output-to-string (c)
          (describe (read-from-string str) c)))))
   :completion (completion
                (mapcar (lambda (sym) (format nil "~(~s~)" sym))
                        (mx-proxy:package-symbols :mx-proxy)))
   :message "Apropos function"))

(define-command start-server (port) ("iPort")
  "Start the proxy server on port."
  (with-tk-error (mx-proxy:start-server :port port)))

(define-command stop-server () ()
  "Stop the proxy server"
  (mx-proxy:stop-server))

(define-command load-project (path) ("fSelect file")
  "Pick a SQLite file to work with."
  (mito:disconnect-toplevel)
  (with-tk-error (mx-proxy:connect-database :file path))
  (mx-proxy:run-hook :on-load-project))

(define-command save-project (path) ("fSave path")
  "Copy current project database to file."
  (uiop:copy-file mx-proxy:*db-file* path))

(defwidget main-app (frame)
  ()
  ((main-view traffic
              :grid '(0 0 :sticky :nsew))
   (modeline entry
             :grid '(2 0 :sticky :nsew)
             :height 32))

  (grid-rowconfigure self 0 :weight 1)
  (grid-rowconfigure self 1 :weight 0)
  (grid-rowconfigure self 2 :weight 0)
  (grid-columnconfigure self 0 :weight 1)

  (bind *tk* "<Alt-x>"
    (lambda (e)
      (declare (ignore e))
      (execute-command)))

  (let ((menubar (make-menubar)))
    (make-menubutton menubar "Command" 'execute-command)
    (let ((menu (make-menu menubar "Project")))
      (make-menubutton menu "Load" (lambda () (call-with-prompts 'load-project)))
      (make-menubutton menu "Save" (lambda () (call-with-prompts 'save-project))))
    (let ((menu (make-menu menubar "Server")))
      (make-menubutton menu "Start" (lambda () (call-with-prompts 'start-server)))
      (make-menubutton menu "Stop" (lambda () (call-with-prompts 'stop-server))))))

(defvar *main-app* nil)
(defvar *wish-conn* nil)

(defun main ()
  (with-nodgui (:title "Proxy")
    (setf *wish-conn* *wish*)
    (set-geometry *tk* 1000 800 0 0)
    (mx-proxy:connect-database)
    (setf *main-app* (make-instance 'main-app :pack '(:fill :both :expand t)))
    (redraw-modeline)
    (mx-proxy:run-hook :init)
    nil))

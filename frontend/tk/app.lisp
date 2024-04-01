(in-package :mx-proxy/tk)

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

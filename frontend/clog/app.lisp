(in-package :mx-proxy/clog)

(defparameter if:*interface* :clog)

(defvar *window*)
(defvar *messages* nil)

(defun on-server-start (obj)
  (declare (ignore obj))
  (if:call-with-prompts 'start-server))

(defun on-server-stop (obj)
  (declare (ignore obj))
  (if:call-with-prompts 'stop-server))

(defun on-database-connect (obj)
  (declare (ignore obj))
  (if:call-with-prompts 'load-project))

(defun on-database-save (obj)
  (declare (ignore obj))
  (if:call-with-prompts 'save-project))

(defun on-mx-prompt (obj)
  (declare (ignore obj))
  (if:prompt-for-command
   (lambda (cmd) (mx-proxy/interface:call-with-prompts cmd))))

(defun on-key-press (obj ev)
  (declare (ignore obj))
  (let ((key (getf ev :key))
        (alt-p (getf ev :alt-key)))
    (cond ((and alt-p (string-equal "x" key))
           (if:message ev)
           (if:prompt-for-command 'if:call-with-prompts)))))

(defun on-new-window (body)
  (clog-gui-initialize body)
  (enable-clog-popup)
  (add-class body "w3-dark-gray")
  (setf *window* body)
  (set-on-key-down (window body) 'on-key-press)
  (with-clog-create body
      (gui-menu-bar
       ()
       (gui-menu-item (:content "λ" :on-click 'on-mx-prompt))
       (gui-menu-item (:content "REPL" :on-click 'create-repl-window))
       (gui-menu-item (:content "Logs" :on-click 'create-logs-window))
       (gui-menu-drop-down
        (:content "Traffic")
        (gui-menu-item
         (:content "All" :on-click (a:curry 'create-traffic-window :all)))
        (gui-menu-item
         (:content "Browser" :on-click (a:curry 'create-traffic-window :browser)))
        (gui-menu-item
         (:content "Repeater" :on-click (a:curry 'create-traffic-window :repeater))))
       (gui-menu-drop-down
        (:content "Server")
        (gui-menu-item
         (:content "Start" :on-click 'on-server-start))
        (gui-menu-item
         (:content "Stop" :on-click 'on-server-stop)))
       (gui-menu-drop-down
        (:content "Database")
        (gui-menu-item
         (:content "Connect" :on-click 'on-database-connect))
        (gui-menu-item
         (:content "Save" :on-click 'on-database-save)))
       (gui-menu-drop-down
        (:content "Windows")
        (gui-menu-item
         (:content "Tile windows" :on-click 'tile-windows))
        (gui-menu-item
         (:content "Maximize all" :on-click 'maximize-all-windows))
        (gui-menu-item
         (:content "Normalize all" :on-click 'normalize-all-windows))))))

(defun start-server ()
  (mx-proxy:connect-database)
  (initialize 'on-new-window))

(defun main ()
  (ceramic:setup)
  (ceramic:start)
  (start-server)
  (ceramic:show (ceramic:make-window :url "http://localhost:8080"))
  (loop (sleep 1)))

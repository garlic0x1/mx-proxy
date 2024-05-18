(in-package :mx-proxy/clog)

(defparameter if:*interface* :clog)

(defvar *window*)
(defvar *messages* nil)

(defun on-help-about (obj)
  (alert-toast obj "toasty" "toasted"))

(defun on-server-start (obj)
  (declare (ignore obj))
  (mx-proxy/interface:call-with-prompts 'start-server))

(defun on-server-stop (obj)
  (declare (ignore obj))
  (mx-proxy/interface:call-with-prompts 'stop-server))

(defun on-database-connect (obj)
  (declare (ignore obj))
  (mx-proxy/interface:call-with-prompts 'load-project))

(defun on-database-save (obj)
  (declare (ignore obj))
  (mx-proxy/interface:call-with-prompts 'save-project))

(defun on-mx-prompt (obj)
  (declare (ignore obj))
  (mx-proxy/interface:prompt-for-command
   (lambda (cmd) (mx-proxy/interface:call-with-prompts cmd))))

(defun on-key-press (obj ev)
  (declare (ignore obj))
  (let ((key (getf ev :key))
        (alt-p (getf ev :alt-key)))
    (cond ((and alt-p (string-equal "x" key))
           (if:prompt-for-command 'if:call-with-prompts))))
  (mx-proxy/interface:message ev))

(defun on-new-window (body)
  (clog-gui-initialize body)
  (enable-clog-popup)
  (add-class body "w3-dark-gray")
  (setf *window* body)
  (set-on-key-down (window body) 'on-key-press)
  (with-clog-create body
      (gui-menu-bar
       ()
       (gui-menu-item (:content "λ"
                       :on-click 'on-mx-prompt))
       (gui-menu-item (:content "Logs"
                       :on-click 'make-logs-window))
       (gui-menu-drop-down (:content "Traffic")
                           (gui-menu-item
                            (:content "All"
                             :on-click (a:curry 'make-traffic-window :all)))
                           (gui-menu-item
                            (:content "Browser"
                             :on-click (a:curry 'make-traffic-window :browser)))
                           (gui-menu-item
                            (:content "Repeater"
                             :on-click (a:curry 'make-traffic-window :repeater))))
       (gui-menu-drop-down (:content "Server")
                           (gui-menu-item
                            (:content "Start"
                             :on-click 'on-server-start))
                           (gui-menu-item
                            (:content "Stop"
                             :on-click 'on-server-stop)))
       (gui-menu-drop-down (:content "Database")
                           (gui-menu-item
                            (:content "Connect"
                             :on-click 'on-database-connect))
                           (gui-menu-item
                            (:content "Save"
                             :on-click 'on-database-save))))))

(defun main ()
  (mx-proxy:connect-database)
  (initialize 'on-new-window)
  (open-browser))

;; (main)

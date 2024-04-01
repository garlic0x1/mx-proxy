(in-package :mx-proxy/qt)
(in-readtable :qtools)

(defmethod call-with-prompts ((command mx-proxy:command))
  (prompt-for-specs
   (lambda (&rest args)
     (apply (mx-proxy:command-symbol command) args)
     (mx-proxy:run-hook :on-command command))
   (mx-proxy:command-prompts command)))

(defmethod call-with-prompts ((str string))
  (when-let ((cmd (gethash str mx-proxy:*commands*)))
    (call-with-prompts cmd)))

(defmethod call-with-prompts ((sym symbol))
  (when-let ((cmd (gethash (format nil "~(~a~)" sym) mx-proxy:*commands*)))
    (call-with-prompts cmd)))

(defun execute-command ()
  (prompt-for-string
   (lambda (str) (print str) (call-with-prompts str))
   :completion (mx-proxy::completion (mx-proxy:all-command-names))
   :message "Command"))

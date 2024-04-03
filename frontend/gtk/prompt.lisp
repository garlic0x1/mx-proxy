(in-package :mx-proxy/gtk)

(defun prompt-for-string (callback &key (message "Prompt") (completion #'list))
  (let ((widget))
    (setf widget (make-instance 'prompt
                                :message message
                                :completion completion
                                :callback (lambda (val)
                                            (funcall callback val)
                                            (grid-remove *top-grid*
                                                         (gobject widget)))))
    (grid-attach *top-grid* (gobject widget) 0 2 1 1)))

(defun prompt-and-execute-command ()
  (prompt-for-string
   (lambda (str)
     (print str))
   :message "Command prompt"
   :completion (mx-proxy::completion (mx-proxy:all-command-names))))

(defmethod mx-proxy:prompt-for-string* ((impl (eql :gtk)) callback &key message completion)
  (prompt-for-string callback :message message :completion completion))

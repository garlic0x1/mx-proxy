(in-package :mx-proxy/interface)

;; Essential utilities for the frontends

(defun fuzzy-match-p (str elt &optional ignore-case)
  (loop :with start := 0
        :for c :across str
        :for test := (if ignore-case #'char-equal #'char=)
        :for pos := (position c elt :start start :test test)
        :do (if pos (setf start pos) (return nil))
        :finally (return t)))

(defun make-completion (selection &key (test *default-completion-test*))
  (lambda (str) (remove-if-not (curry test str) selection)))

(defun file-completion (str)
  (let ((dir (namestring (uiop:pathname-directory-pathname str))))
    (remove-if-not (curry #'str:starts-with-p str)
                   (mapcar #'namestring
                           (append (uiop:subdirectories dir)
                                   (uiop:directory-files dir))))))

(defmethod call-with-prompts ((obj command))
  (prompt-for-specs
   (lambda (&rest args)
     (apply (command-symbol obj) args)
     (run-hook :on-command obj))
   (command-prompts obj)))

(defmethod call-with-prompts ((obj string))
  (when-let ((cmd (gethash obj *commands*)))
    (call-with-prompts cmd)))

(defmethod call-with-prompts ((obj symbol))
  (when-let ((cmd (gethash (format nil "~(~a~)" obj) *commands*)))
    (call-with-prompts cmd)))

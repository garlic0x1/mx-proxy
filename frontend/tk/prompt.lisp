(in-package :mx-proxy/tk)

(defun prompt-for-file (callback &key (message "File prompt"))
  (let ((widget nil))
    (setf widget (make-instance 'file-prompt
                                :master *main-app*
                                :message message
                                :command (lambda (pathname)
                                           (funcall callback pathname)
                                           (destroy widget))))
    (grid widget 1 0 :sticky :nsew)))

(defun prompt-for-string (callback &key message (completion #'list))
  (let ((widget nil))
    (setf widget (make-instance 'prompt
                                :master *main-app*
                                :message message
                                :completion completion
                                :command (lambda (value)
                                           (funcall callback value)
                                           (destroy widget))))
    (grid widget 1 0 :sticky :nsew)))

(defun prompt-for-integer (callback &key message (completion #'list))
  (let ((widget nil))
    (setf widget (make-instance 'prompt
                                :master *main-app*
                                :message message
                                :completion completion
                                :command
                                (lambda (value)
                                  (if-let ((num (ignore-errors
                                                  (parse-integer value))))
                                    (progn
                                      (funcall callback num)
                                      (destroy widget))
                                    (prompt-swap widget "")))))
    (grid widget 1 0 :sticky :nsew)))

(defun prompt-for-spec (callback spec)
  "Lem style prompt spec, with type as the first char
and message as the rest of the string. ex: \"fFile prompt\" \"sString prompt\""
  (funcall (case (elt spec 0)
             (#\i 'prompt-for-integer)
             (#\s 'prompt-for-string)
             (#\f 'prompt-for-file))
           callback
           :message (subseq spec 1)))

(defun prompt-for-specs (callback prompts)
  "Lem style prompt specs. ex: '(\"fSelect file\" \"iInt prompt\"). "
  (if (car prompts)
      (prompt-for-spec
       (lambda (value) (prompt-for-specs (curry callback value) (cdr prompts)))
       (car prompts))
      (funcall callback)))

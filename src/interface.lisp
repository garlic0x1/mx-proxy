(in-package :mx-proxy)

(defparameter *implementation* nil)
(defparameter *default-completion-test* #'search)

(defgeneric prompt-for-string* (implementation callback &key message completion))

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

(defun prompt-for-string (callback &key (message "String Prompt")
                                        (completion #'list))
  (prompt-for-string*
   *implementation*
   callback
   :message message
   :completion completion))

(defun prompt-for-file (callback &key (message "File Prompt")
                                      (completion #'file-completion))
  (prompt-for-string*
   *implementation*
   callback
   :message message
   :completion completion))

(defun prompt-for-integer (callback &key (message "Integer Prompt")
                                         (completion #'list))
  (prompt-for-string*
   *implementation*
   (lambda (str)
     (when-let ((num (parse-integer str)))
       (funcall callback num)))
   :message message
   :completion completion))

(defun prompt-for-command (callback &key (message "Command Prompt"))
  (prompt-for-string*
   *implementation*
   callback
   :message message
   :completion (make-completion (all-command-names))))

(defun prompt-for-spec (callback spec)
  (funcall
   (case (elt spec 0)
     (#\i 'prompt-for-integer)
     (#\c 'prompt-for-command)
     (#\b 'prompt-for-yes-or-no)
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

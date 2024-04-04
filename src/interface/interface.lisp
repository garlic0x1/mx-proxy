(in-package :mx-proxy/interface)

(defparameter *interface* nil)
(defparameter *default-completion-test* #'search)

(defgeneric prompt-for-string*
    (interface callback &key message completion validation start))

(defgeneric show-error-message (interface condition &key severity))

(defmacro with-ui-errors (&body body)
  `(handler-case (progn ,@body)
     (error (c) (show-error-message *interface* c))))

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

(defun prompt-for-string
    (callback &key (message "String Prompt")
                   (completion #'list)
                   (validation (constantly t))
                   (start ""))
  (prompt-for-string*
   *interface*
   callback
   :message message
   :validation validation
   :completion completion
   :start start))

(defun prompt-for-yes-or-no
    (callback &key (message "Yes or No Prompt")
                   (completion (make-completion '("Yes" "No")))
                   (validation (constantly t))
                   (start ""))
  (prompt-for-string*
   *interface*
   (lambda (str)
     (funcall callback (string-equal :yes str)))
   :message message
   :completion completion
   :validation validation
   :start start))

(defun prompt-for-file
    (callback &key (message "File Prompt")
                   (completion #'file-completion)
                   (validation (constantly t))
                   (start (namestring (user-homedir-pathname))))
  (prompt-for-string*
   *interface*
   callback
   :message message
   :validation validation
   :completion completion
   :start start))

(defun prompt-for-integer
    (callback &key (message "Integer Prompt")
                   (completion #'list)
                   (validation (lambda (str) (ignore-errors (parse-integer str))))
                   (start ""))
  (prompt-for-string*
   *interface*
   (lambda (str)
     (when-let ((num (ignore-errors (parse-integer str))))
       (funcall callback num)))
   :message message
   :completion completion
   :validation validation
   :start start))

(defun prompt-for-command
    (callback &key (message "Command Prompt")
                   (completion (make-completion (all-command-names)))
                   (validation (lambda (s) (find s (all-command-names) :test 'equal)))
                   (start ""))
  (prompt-for-string*
   *interface*
   (lambda (str)
     (when-let ((cmd (gethash str *commands*)))
       (funcall callback cmd)))
   :message message
   :completion completion
   :validation validation
   :start start))

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

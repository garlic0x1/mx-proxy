(in-package :mx-proxy/interface)

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

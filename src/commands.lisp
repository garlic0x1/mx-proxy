(in-package :mx-proxy)

(defun completion (selection &key (test #'search))
  (lambda (str) (remove-if-not (curry test str) selection)))

(defvar *commands* (make-hash-table :test #'equal))

(defclass command ()
  ((symbol
    :initarg :symbol
    :initform (error "Must provide symbol.")
    :accessor command-symbol)
   (prompts
    :initarg :prompts
    :initform nil
    :accessor command-prompts)
   (namestring
    :initform nil
    :accessor command-namestring)
   (docstring
    :initform nil
    :accessor command-docstring)))

(defmethod initialize-instance :after ((obj command) &key &allow-other-keys)
  (setf (command-docstring obj)  (documentation (command-symbol obj) 'function)
        (command-namestring obj) (format nil "~(~a~)" (command-symbol obj))))

(defun all-commands ()
  (hash-table-keys *commands*))

(defun all-command-names ()
  (mapcar (lambda (name) (format nil "~(~a~)" name))
          (hash-table-keys *commands*)))

(defmacro defcommand (name lambda-list prompts &body body)
  `(progn
     (defun ,name ,lambda-list ,@body)
     (setf (gethash (format nil "~(~a~)" (quote ,name)) *commands*)
           (make-instance 'command
                          :symbol (quote ,name)
                          :prompts (quote ,prompts)))))

(defmethod call-with-prompts ((command command))
  (prompt-for-specs
   (lambda (&rest args)
     (apply (command-symbol command) args)
     (proxy/hooks:run-hook :on-command command))
   (command-prompts command)))

(defmethod call-with-prompts ((str string))
  (when-let ((cmd (gethash str *commands*)))
    (call-with-prompts cmd)))

(defmethod call-with-prompts ((sym symbol))
  (when-let ((cmd (gethash (format nil "~(~a~)" sym) *commands*)))
    (call-with-prompts cmd)))

(defun execute-command ()
  (prompt-for-string
   (lambda (str) (print str) (call-with-prompts str))
   :completion (completion (all-commands))
   :message "Command"))

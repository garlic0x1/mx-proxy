(in-package :mx-proxy/interface)

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

(defun all-command-names ()
  (hash-table-keys *commands*))

(defun all-commands ()
  (hash-table-values *commands*))

(defmacro define-command (name lambda-list prompts &body body)
  `(progn
     (defun ,name ,lambda-list ,@body)
     (setf (gethash (format nil "~(~a~)" (quote ,name)) *commands*)
           (make-instance 'command
                          :symbol (quote ,name)
                          :prompts (quote ,prompts)))))

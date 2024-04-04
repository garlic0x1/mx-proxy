(in-package :mx-proxy/interface)

(defvar *hooks* (make-hash-table)
  "Global hook table, use `register-hook` to modify it.")

(defclass hook ()
  ((funcs
    :initform '()
    :accessor hook-funcs)
   (named-funcs
    :initform (make-hash-table)
    :accessor hook-named-funcs)))

(defmethod run-hook (key &rest args)
  "Run all functions associated with hook."
  (if-let ((hook (gethash key *hooks*)))
    (handler-case
        (progn
          (loop :for f :in (hook-funcs hook)
                :do (apply f args))
          (loop :for f :being :the :hash-value :of (hook-named-funcs hook)
                :do (apply f args)))
      (error (c)
        (warn (format nil "Warning: ~a" c))))
    (warn "No hooks registered for key: ~a" key)))

(defgeneric register-hook* (key func)
  (:method ((key symbol) func)
    (if-let ((hook (gethash key *hooks*)))
      (setf (hook-funcs hook) (cons func (hook-funcs hook)))
      (progn
        (setf (gethash key *hooks*) (make-instance 'hook))
        (register-hook* key func))))

  (:method ((key list) func)
    (if-let ((hook (gethash (first key) *hooks*)))
      (let ((funcs (hook-named-funcs hook)))
        (setf (gethash (second key) funcs) func))
      (progn
        (setf (gethash (first key) *hooks*) (make-instance 'hook))
        (register-hook* key func)))))

(defmacro register-hook (key lambda-list &body body)
  "Add a function to hook.
The `key` argument can be a symbol to register an unnamed function,
or a list where the second symbol is the name of the function."
  `(register-hook* (quote ,key) (lambda ,lambda-list ,@body)))

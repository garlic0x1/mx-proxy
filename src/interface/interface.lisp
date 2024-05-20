(in-package :mx-proxy/interface)

(defparameter *interface* nil)

(defparameter *default-completion-test* #'search)

;;
;; Generics that frontends must implement:
;;

(defgeneric prompt-for-string*
    (interface callback &key message completion validation start))

(defgeneric message* (interface value))

(defgeneric show-error-message (interface condition &key severity))

(defun message (value)
  (message* *interface* value))

(defmacro with-ui-errors (&body body)
  `(handler-case (progn ,@body)
     (error (c) (show-error-message *interface* c))))

(defmacro with-log-errors (&body body)
  `(handler-case (progn ,@body)
     (error (c) (message c))))

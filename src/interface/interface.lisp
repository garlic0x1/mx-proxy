(in-package :mx-proxy/interface)

(defparameter *interface* nil)

(defparameter *default-completion-test* #'search)

;;
;; Generics that frontends must implement:
;;

(defgeneric prompt-for-string*
    (interface callback &key message completion validation start))

(defgeneric show-error-message (interface condition &key severity))

(defmacro with-ui-errors (&body body)
  `(handler-case (progn ,@body)
     (error (c) (show-error-message *interface* c))))

(in-package :mx-proxy/clog)

(defparameter *table-class* "w3-table w3-striped w3-bordered w3-border w3-hoverable")

(defvar *obj*)
(defvar *ev*)

(defmacro on ((event obj &rest keys &key &allow-other-keys) &body body)
  (let ((set-on (intern (string-upcase (format nil "set-on-~a" event)))))
    `(,set-on ,obj
              (lambda (obj &optional ev)
                (let ((*obj* obj)
                      (*ev* ev))
                  ,@body))
              ,@keys)))

(defmacro orient-win (win top left width height)
  `(progn (unless ,top
            (setf (,top ,win) (unit :px (- (/ (inner-height (window *window*)) 2.0)
                                           (/ (,height ,win) 2.0)))))
          (unless ,left
            (setf (,left ,win) (unit :px (- (/ (inner-width (window *window*)) 2.0)
                                            (/ (,width ,win) 2.0)))))))

(defun slot-names (obj)
  (mapcar #'sb-mop:slot-definition-name
          (sb-mop:class-slots (class-of obj))))

(defun slot-values (obj)
  (mapcar (lambda (slot) (ignore-errors (slot-value obj slot)))
          (slot-names obj)))

(defun slots-alist (obj)
  (loop :for name :in (slot-names obj)
        :for val :in (slot-values obj)
        :collect (cons name val)))

(defun type-of-simple (obj)
  (let ((type (type-of obj)))
    (if (listp type)
        (car type)
        type)))

(defun class-of-simple (obj)
  (class-name (class-of obj)))

(defparameter *default-width* 500)
(defparameter *default-height* 500)

(defmacro create-gui-window* (obj &rest rest &key &allow-other-keys)
  `(create-gui-window ,obj ,@rest :width *default-width* :height *default-height*))

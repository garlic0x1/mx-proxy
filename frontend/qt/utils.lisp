(in-package :mx-proxy/qt)

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

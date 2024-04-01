(in-package :ng-widgets)

(defun vector-insert (vec index values)
  (let ((tail (subseq vec index)))
    (dotimes (_ (length tail)) (vector-pop vec))
    (loop :for val :in values :do (vector-push-extend val vec))
    (loop :for it :across tail :do (vector-push-extend it vec))
    vec))

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

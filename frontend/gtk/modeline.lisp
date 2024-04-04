(in-package :mx-proxy/gtk)

(defclass modeline (widget)
  ((value
    :initarg :value
    :initform nil
    :accessor value)
   (container
    :accessor container)
   (widgets
    :initform nil
    :accessor widgets)))

(defmethod initialize-instance :after ((self modeline) &key &allow-other-keys)
  (let* ((box (make-box :orientation +orientation-horizontal+ :spacing 16)))
    (setf (gobject self) box
          (container self) box

          (widget-halign box) +align-end+
          (widget-margin-all box) 8))
  (update-modeline self))

(defmethod update-modeline ((self modeline))
  (loop :for widget :in (widgets self)
        :do (box-remove (container self) widget))
  (setf (widgets self) nil)
  (loop :for (k v) :on (value self) :by #'cddr
        :for widget
           := (make-label :str (format nil "~a: ~a" (string-capitalize k) v))
        :do (push widget (widgets self))
        :do (box-append (container self) widget)))

(defun (setf modeline) (value key)
  (if (null (value *top-modeline*))
      (setf (value *top-modeline*) (list key value))
      (setf (getf (value *top-modeline*) key) value))
  (update-modeline *top-modeline*)
  (print (value *top-modeline*))
  value)

(define-command set-modeline-value (key val) ("sKey" "sVal")
  (let ((key (http::make-keyword* key)))
    (setf (modeline key) val)))

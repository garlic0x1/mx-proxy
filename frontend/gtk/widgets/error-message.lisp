(in-package :gtk-widgets)

(defclass error-message (widget)
  ((value
    :initarg :value
    :initform nil
    :accessor value)
   (callback
    :initarg :callback
    :initform (lambda () (warn "No callback."))
    :accessor callback)))

(defmethod initialize-instance :after ((self error-message) &key &allow-other-keys)
  (let* ((box (make-box :orientation +orientation-vertical+ :spacing 16))
         (label (make-label :str (format nil "~a" (value self))))
         (ok-button (make-button :label "Okay")))

    (setf (gobject self) box)

    (box-append box label)
    (box-append box ok-button)

    (connect ok-button "clicked"
             (lambda (button)
               (declare (ignore button))
               (funcall (callback self))))

    (let ((controller (make-event-controller-key)))
      (connect controller "key-pressed"
               (lambda (widget kval kcode state)
                 (declare (ignore widget kcode state))
                 (if (= kval gdk4:+key-escape+)
                     (funcall (callback self))
                     (values gdk4:+event-propagate+))))
      (widget-add-controller box controller))))

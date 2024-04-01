(in-package :mx-proxy/tk)

(defwidget alert-message (frame)
  ((value
    :initarg :value
    :accessor alert-message-value))
  ((content inspector
            :pack (:fill :both :expand t)
            :value (alert-message-value self))
   (dismiss button
            :pack (:fill :both :expand t)
            :text "Dismiss"
            :command (lambda () (destroy self)))))

(defun alert (value)
  (let ((w (make-instance 'alert-message
                          :master *main-app*
                          :value value)))
    (bind w "<Escape>"
      (lambda (e)
        (declare (ignore e))
        (destroy w)))

    (grid w 1 0 :sticky :nsew)
    (focus w)))

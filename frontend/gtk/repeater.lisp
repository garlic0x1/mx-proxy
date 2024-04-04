(in-package :mx-proxy/gtk)

(defclass repeater (widget)
  ((value
    :initarg :value
    :initform nil
    :accessor value)
   (message-pair
    :accessor message-pair)))

(defmethod initialize-instance :after ((self repeater) &key &allow-other-keys)
  (let* ((box (make-box :orientation +orientation-vertical+ :spacing *box-spacing*))
         (replay-button (make-button :label "Replay"))
         (message-pair (make-instance 'message-pair :value (value self))))

    (setf (gobject self) box
          (message-pair self) message-pair)

    (box-append box replay-button)
    (box-append box (gobject message-pair))

    (connect replay-button "clicked"
             (lambda (button)
               (declare (ignore button))
               (let* ((req (http:message-pair-request (value self)))
                      (edited (text-buffer-text (req-buf message-pair)))
                      (host (http:request-host req)))
                 (with-ui-errors
                   (multiple-value-bind (resp pair)
                       (mx-proxy:replay req edited :ssl host :host host)
                     (declare (ignore resp))
                     (swap message-pair pair))))))))

(defmethod swap ((self repeater) value)
  (setf (value self) value)
  (swap (message-pair self) value))

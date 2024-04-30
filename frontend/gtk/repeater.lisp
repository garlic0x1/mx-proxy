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
         (buttons (make-box :orientation +orientation-horizontal+ :spacing 0))
         (replay-button (make-button :label "Replay"))
         (fuzzer-button (make-button :label "Send to Fuzzer"))
         (message-pair (make-instance 'message-pair :value (value self))))

    (setf (gobject self) box
          (message-pair self) message-pair)

    (box-append buttons replay-button)
    (box-append buttons fuzzer-button)
    (box-append box buttons)
    (box-append box (gobject message-pair))

    (connect fuzzer-button "clicked"
             (lambda (button)
               (declare (ignore button))
               (swap *top-fuzzer* (http:message-pair-request (value self)))))

    (connect replay-button "clicked"
             (lambda (button)
               (declare (ignore button))
               (let* ((req (http:message-pair-request (value self)))
                      (edited (text-buffer-text (req-buf message-pair))))
                 (with-ui-errors
                   (swap message-pair (mx-proxy:replay req edited))))))))

(defmethod swap ((self repeater) value)
  (setf (value self) value)
  (swap (message-pair self) value))

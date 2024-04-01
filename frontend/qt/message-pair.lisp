(in-package :mx-proxy/qt)
(in-readtable :qtools)

(define-widget message-pair (QWidget)
  ((value
    :initarg :value
    :initform nil
    :accessor value)))

(define-signal (message-pair update) ())

(define-subwidget (message-pair inspector)
    (make-instance
     'collapsible
     :content (make-instance
               'inspector
               :value (value message-pair))))

(define-subwidget (message-pair request) (q+:make-qtextedit))

(define-subwidget (message-pair response) (q+:make-qtextedit))

(define-subwidget (message-pair layout) (q+:make-qgridlayout message-pair)
  (q+:add-widget layout inspector 0 0)
  (q+:add-widget layout request 1 0)
  (q+:add-widget layout response 2 0))

(define-slot (message-pair update) ()
  (declare (connected message-pair (update)))
  (let ((value (value message-pair)))
    (ignore-errors
      (setf
       (q+:text request) (http:message-raw (http:message-pair-request value))
       (q+:text response) (http:message-raw (http:message-pair-response value))))
    (swap (content inspector) value)))

(define-initializer (message-pair setup)
  (signal! message-pair (update)))

(defmethod swap ((self message-pair) value)
  (setf (value self) value)
  (signal! self (update)))

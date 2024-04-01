(in-package :mx-proxy/qt)
(in-readtable :qtools)

(defun display-message-pair (item)
  (let ((req (http:message-pair-request item))
        (resp (http:message-pair-response item)))
    (format nil "~a ~a ~a ~a"
            (ignore-errors (http:request-method req))
            (ignore-errors (http:request-uri req))
            (ignore-errors (http:response-status-code resp))
            (ignore-errors (http:response-status resp)))))

(define-widget traffic (QWidget)
  ((messages
    :initarg :messages
    :initform '()
    :accessor messages)))

(define-subwidget (traffic listbox) (q+:make-qlistwidget traffic))
(define-subwidget (traffic repeater) (make-instance 'message-pair))

(define-subwidget (traffic layout) (q+:make-qgridlayout traffic)
  (q+:add-widget layout listbox 0 0)
  (q+:add-widget layout repeater 0 1))

(define-slot (traffic select-handler) ((row int))
  (declare (connected listbox (current-row-changed int)))
  (swap repeater (elt (messages traffic) row)))

(define-initializer (traffic setup)
  (mx-proxy:connect-database)
  (mx-proxy:register-hook (:on-message-pair :traffic) (mp)
    (push mp (messages traffic))
    (q+:insert-item listbox 0 (format nil "added: ~a" mp)))
  (loop :for mp :in (mito:select-dao 'http:message-pair)
        :do (push mp (messages traffic))
        :do (q+:insert-item listbox 0 (display-message-pair mp))))

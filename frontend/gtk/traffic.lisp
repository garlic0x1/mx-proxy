(in-package :mx-proxy/gtk)

(defclass traffic (widget) ())

(defmethod initialize-instance :after ((self traffic) &key &allow-other-keys)
  (let* ((paned (make-paned :orientation +orientation-horizontal+))
         (message-pair (make-instance 'message-pair))
         (scroll (make-scrolled-window))
         (genlist (make-instance 'generic-string-list
                                 :on-change (lambda (val)
                                              (swap message-pair val)
                                              (print val))
                                 :display #'display-message-pair
                                 :contents (reverse
                                            (mito:select-dao 'http:message-pair)))))
    (setf (widget-size-request scroll) '(400 200)
          (scrolled-window-child scroll) (gobject genlist)
          (paned-start-child paned) scroll
          (paned-end-child paned) (gobject message-pair)
          (gobject self) paned)))

(defun display-message-pair (item)
  (let ((req (http:message-pair-request item))
        (resp (http:message-pair-response item)))
    (format nil "~a ~a ~a ~a"
            (ignore-errors (http:request-method req))
            (ignore-errors (http:request-uri req))
            (ignore-errors (http:response-status-code resp))
            (ignore-errors (http:response-status resp)))))

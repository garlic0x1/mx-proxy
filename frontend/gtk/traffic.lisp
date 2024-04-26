(in-package :mx-proxy/gtk)

(defclass traffic (widget) ())

(defmethod initialize-instance :after ((self traffic) &key &allow-other-keys)
  (let* ((box (make-box :orientation +orientation-horizontal+ :spacing 0))
         (repeater (make-instance 'repeater))
         (scroll (make-scrolled-window))
         (traffic-list (make-instance
                        'traffic-list
                        :callback (lambda (val)
                                    (print val)
                                    (swap repeater val))
                        :contents (reverse (mito:select-dao 'http:message-pair)))))
    (register-hook (:on-load-project :traffic) ()
      (idle-add
       (lambda ()
         (traffic-list-clear traffic-list)
         (traffic-list-append
          traffic-list
          (reverse (mito:select-dao 'http:message-pair))))))
    (register-hook (:on-message-pair :traffic) (mp)
      (with-ui-errors
        (idle-add (lambda () (traffic-list-push traffic-list mp)))))
    (box-append box scroll)
    (box-append box (make-separator :orientation +orientation-horizontal+))
    (box-append box (gobject repeater))
    (setf
     (widget-size-request scroll) '(400 200)
     (scrolled-window-child scroll) (gobject traffic-list)
     (widget-hexpand-p (gobject repeater)) t
     (widget-vexpand-p (gobject repeater)) t
     (gobject self) box)))

(defun display-message-pair (item)
  (let ((req (http:message-pair-request item))
        (resp (http:message-pair-response item)))
    (format nil "~a ~a ~a ~a"
            (ignore-errors (http:request-method req))
            (ignore-errors (http:request-uri req))
            (ignore-errors (http:response-status-code resp))
            (ignore-errors (http:response-status resp)))))

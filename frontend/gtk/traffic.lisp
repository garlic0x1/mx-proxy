(in-package :mx-proxy/gtk)

(defclass traffic (widget) ())

(defmethod initialize-instance :after ((self traffic) &key &allow-other-keys)
  (let* (
         ;; (paned (make-paned :orientation +orientation-horizontal+))
         (split (adw:make-overlay-split-view))
         (repeater (make-instance 'repeater))
         ;; (scroll (make-scrolled-window))
         (genlist (make-instance 'generic-string-list
                                 :on-change (lambda (val) (swap repeater val))
                                 :display #'display-message-pair
                                 :contents (reverse
                                            (mito:select-dao 'http:message-pair)))))
    (register-hook (:on-load-project :traffic) ()
      (idle-add
       (lambda ()
         (generic-string-list-clear genlist)
         (generic-string-list-append
          genlist
          (reverse (mito:select-dao 'http:message-pair)) ))))
    (register-hook (:on-message-pair :traffic) (mp)
      (with-ui-errors
        (idle-add (lambda () (generic-string-list-insert genlist 0 mp)))))
    (setf
     ;; (widget-size-request scroll) '(400 200)
     ;; (scrolled-window-child scroll) (gobject genlist)
     (adw:overlay-split-view-content split) (gobject repeater)
     (adw:overlay-split-view-sidebar split) (gobject genlist)
     ;; (paned-start-child paned) scroll
     ;; (paned-end-child paned) (gobject repeater)
     (gobject self) split)))

(defun display-message-pair (item)
  (let ((req (http:message-pair-request item))
        (resp (http:message-pair-response item)))
    (format nil "~a ~a ~a ~a"
            (ignore-errors (http:request-method req))
            (ignore-errors (http:request-uri req))
            (ignore-errors (http:response-status-code resp))
            (ignore-errors (http:response-status resp)))))

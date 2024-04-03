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
                                 :contents (reverse
                                            (mito:select-dao 'http:message-pair)))))
    (setf
     (scrolled-window-child scroll) (gobject genlist)
     (paned-start-child paned) scroll
     (paned-end-child paned) (gobject message-pair)
     (gobject self) paned)))

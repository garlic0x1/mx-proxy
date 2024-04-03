(in-package :mx-proxy/gtk)

(defclass message-pair (widget)
  ((value
    :initarg :value
    :initform nil
    :accessor value)))

(defmethod initialize-instance :after ((self message-pair) &key &allow-other-keys)
  (let* ((paned (make-paned :orientation +orientation-vertical+))
         (req (http:message-pair-request (value self)))
         (resp (http:message-pair-response (value self)))
         (req-pane (make-text-view))
         (resp-pane (make-text-view))
         (req-buf (text-view-buffer req-pane))
         (resp-buf (text-view-buffer resp-pane))
         (req-scroll (make-scrolled-window))
         (resp-scroll (make-scrolled-window)))
    (setf
     (gobject self) paned
     (widget-size-request paned) '(500 400)
     (widget-margin-all req-scroll) 2
     (widget-margin-all resp-scroll) 2
     (text-buffer-text req-buf) (http:message-raw req)
     (text-buffer-text resp-buf) (http:message-raw resp)
     (scrolled-window-child req-scroll) req-pane
     (scrolled-window-child resp-scroll) resp-pane
     (paned-start-child paned) req-scroll
     (paned-end-child paned) resp-scroll)))

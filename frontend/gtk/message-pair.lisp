(in-package :mx-proxy/gtk)

(defclass message-pair (widget)
  ((value
    :initarg :value
    :initform nil
    :accessor value)
   (req-buf
    :accessor req-buf)
   (resp-buf
    :accessor resp-buf)))

(defmethod initialize-instance :after ((self message-pair) &key &allow-other-keys)
  (let* ((paned (make-paned :orientation +orientation-vertical+))
         (req-pane (make-text-view))
         (resp-pane (make-text-view))
         (req-scroll (make-scrolled-window))
         (resp-scroll (make-scrolled-window)))
    (setf (gobject self) paned
          (widget-vexpand-p paned) t
          (widget-size-request paned) '(500 400)
          (widget-margin-all req-scroll) 2
          (widget-margin-all resp-scroll) 2
          (req-buf self) (text-view-buffer req-pane)
          (resp-buf self) (text-view-buffer resp-pane)
          (scrolled-window-child req-scroll) req-pane
          (scrolled-window-child resp-scroll) resp-pane
          (paned-start-child paned) req-scroll
          (paned-end-child paned) resp-scroll)
    (rerender-message-pair self)))

(defmethod rerender-message-pair ((self message-pair))
  (let* ((req (ignore-errors (http:message-pair-request (value self))))
         (resp (ignore-errors (http:message-pair-response (value self)))))
    (ignore-errors
      (setf (text-buffer-text (req-buf self)) (http:message-raw req)
            (text-buffer-text (resp-buf self)) (http:message-raw resp)))))

(defmethod swap ((self message-pair) value)
  (setf (value self) value)
  (rerender-message-pair self))

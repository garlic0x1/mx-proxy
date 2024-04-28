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
         (req-label (make-label :str "Request"))
         (resp-label (make-label :str "Response"))
         (req-box (make-box :orientation +orientation-vertical+ :spacing 0))
         (resp-box (make-box :orientation +orientation-vertical+ :spacing 0))
         (req-pane (make-text-view))
         (resp-pane (make-text-view))
         (req-scroll (make-scrolled-window))
         (resp-scroll (make-scrolled-window)))
    (box-append req-box req-label)
    (box-append req-box req-scroll)
    (box-append resp-box resp-label)
    (box-append resp-box resp-scroll)
    (setf (gobject self) paned
          (widget-vexpand-p paned) t
          (widget-vexpand-p req-box) t
          (widget-vexpand-p resp-box) t
          (widget-vexpand-p req-scroll) t
          (widget-vexpand-p resp-scroll) t
          (widget-size-request paned) '(300 0)
          ;; (widget-margin-all req-scroll) 2
          ;; (widget-margin-all resp-scroll) 2
          (req-buf self) (text-view-buffer req-pane)
          (resp-buf self) (text-view-buffer resp-pane)
          (scrolled-window-child req-scroll) req-pane
          (scrolled-window-child resp-scroll) resp-pane
          (paned-start-child paned) req-box
          (paned-end-child paned) resp-box)
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

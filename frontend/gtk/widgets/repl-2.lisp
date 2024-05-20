(in-package :gtk-widgets)

(defclass repl-item (widget)
  ((handler
    :initarg :handler
    :initform (lambda (val) (declare (ignore val)) (warn "No handler."))
    :accessor handler)))

(defmethod initialize-instance :after ((self repl-item) &key &allow-other-keys)
  (let* ((box (make-box :orientation +orientation-vertical+ :spacing 0))
         (hbox (make-box :orientation +orientation-horizontal+ :spacing 0))
         (entry (make-entry))
         (submit (make-button :label "Eval"))
         (output (make-label :str "")))
    (box-append box hbox)
    (box-append hbox entry)
    (box-append hbox submit)
    ))

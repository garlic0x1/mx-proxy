(in-package :gtk-widgets)

(defun evaluate (string)
  (handler-case
      (let* ((code (read-from-string string))
             (result (eval code))
             (output (format nil "~a" result)))
        output)
    (error (c) (format nil "~a" c))))

(defclass repl-item (widget)
  ((parent
    :initarg :parent
    :initform (error "Must provide parent.")
    :accessor repl-item-parent)
   (last-p
    :initform t
    :accessor repl-item-last-p)))

(defmethod initialize-instance :after ((self repl-item) &key &allow-other-keys)
  (let* ((box (make-box :orientation +orientation-vertical+ :spacing 0))
         (entry-box (make-box :orientation +orientation-horizontal+ :spacing 0))
         (entry (make-entry))
         (entry-button (make-button :label "Eval"))
         (output (make-label :str "")))
    (box-append entry-box entry)
    (box-append entry-box entry-button)
    (box-append box entry-box)
    (box-append box output)

    (connect entry-button "clicked"
             (lambda (button)
               (declare (ignore button))
               (setf (label-text output)
                     (evaluate
                      (entry-buffer-text
                       (entry-buffer entry))))
               (when (repl-item-last-p self)
                 (box-append (gobject (repl-item-parent self))
                             (gobject
                              (make-instance 'repl-item
                                             :parent (repl-item-parent self)))))
               (setf (repl-item-last-p self) nil)))

    (setf (gobject self) box
          (widget-hexpand-p (gobject self)) t
          (widget-hexpand-p entry-box) t
          (widget-hexpand-p entry) t
          (widget-hexpand-p box) t
          (widget-margin-top output) 8
          (widget-margin-bottom output) 8
          (widget-hexpand-p output) t)))

(defclass repl (widget)
  ((package
    :initarg :package
    :initform :mx-proxy
    :accessor repl-package)
   (history
    :initform '()
    :accessor repl-history)))

(defmethod initialize-instance :after ((self repl) &key &allow-other-keys)
  (let* ((box (make-box :orientation +orientation-vertical+ :spacing 0)))
    (box-append box (gobject (make-instance 'repl-item :parent self)))
    (setf (gobject self) box
          (widget-hexpand-p box) t)))

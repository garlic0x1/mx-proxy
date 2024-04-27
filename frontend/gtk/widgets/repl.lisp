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
         (entry (make-instance 'lisp-entry))
         (output (make-label :str "")))

    (box-append box (gobject entry))
    (box-append box output)

    (flet ((repl-item-evaluate ()
             (setf (label-text output)
                   (evaluate (value entry)))
             (when (repl-item-last-p self)
               (box-append (repl-box (repl-item-parent self))
                           (gobject
                            (make-instance 'repl-item
                                           :parent (repl-item-parent self)))))
             (setf (repl-item-last-p self) nil)))

      (setf (lisp-entry-activate entry)
            (lambda (self) (declare (ignore self)) (repl-item-evaluate)))

      ;; (connect entry-button "clicked"
      ;;          (lambda (button)
      ;;            (declare (ignore button))
      ;;            (repl-item-evaluate)))

      ;; (connect (lisp-entry-entry entry) "activate"
      ;;          (lambda (entry)
      ;;            (declare (ignore entry))
      ;;            (repl-item-evaluate)))
      )

    (setf (gobject self) box
          (widget-halign output) +align-start+
          (widget-hexpand-p (gobject self)) t
          (widget-hexpand-p (gobject entry)) t
          (widget-hexpand-p box) t
          (widget-margin-all output) 8
          (widget-hexpand-p output) t)))

(defclass repl (widget)
  ((package
    :initarg :package
    :initform :mx-proxy
    :accessor repl-package)
   (history
    :initform '()
    :accessor repl-history)
   (box
    :accessor repl-box)))

(defmethod initialize-instance :after ((self repl) &key &allow-other-keys)
  (let* ((box (make-box :orientation +orientation-vertical+ :spacing 0))
         (scroll (make-scrolled-window)))
    (box-append box (gobject (make-instance 'repl-item :parent self)))
    (setf (gobject self) scroll
          (repl-box self) box
          (scrolled-window-child scroll) box
          (widget-hexpand-p box) t)))

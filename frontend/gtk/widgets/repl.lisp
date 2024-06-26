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
   (lisp-entry
    :accessor repl-item-lisp-entry)
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
               (repl-next (repl-item-parent self)))
             (setf (repl-item-last-p self) nil)))

      (setf (lisp-entry-activate entry)
            (lambda (self) (declare (ignore self)) (repl-item-evaluate))))

    (setf (gobject self) box
          (repl-item-lisp-entry self) entry
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
   (box
    :accessor repl-box)
   (children
    :initform '()
    :accessor repl-children)))

(defmethod initialize-instance :after ((self repl) &key &allow-other-keys)
  (let* ((box (make-box :orientation +orientation-vertical+ :spacing 0))
         (scroll (make-scrolled-window))
         (first-item (make-instance 'repl-item :parent self)))
    (box-append box (gobject first-item))
    (push first-item (repl-children self))
    (setf (gobject self) scroll
          (repl-box self) box
          (scrolled-window-child scroll) box
          (widget-hexpand-p box) t)))

(defun repl-next (self)
  (let ((next (make-instance 'repl-item :parent self)))
    (box-append (repl-box self) (gobject next))
    (push next (repl-children self))
    (lisp-entry-grab-focus (repl-item-lisp-entry next))))

(defun repl-clear (self)
  (dolist (child (repl-children self))
    (box-remove (repl-box self) (gobject child)))
  (setf (repl-children self) nil)
  (repl-next self))

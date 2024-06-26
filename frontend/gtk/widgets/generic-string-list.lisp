(in-package :gtk-widgets)

(defclass generic-string-list (widget)
  ((internal
    :initform nil
    :accessor internal)
   (display
    :initarg :display
    :initform (lambda (item) (format nil "~a" item))
    :accessor display)
   (contents
    :initarg :contents
    :initform nil
    :accessor contents)
   (on-change
    :initarg :on-change
    :initform (lambda (val) (declare (ignore val)) (warn "no handler"))
    :accessor on-change)))

(defmethod initialize-instance :after ((self generic-string-list)
                                       &key &allow-other-keys)
  (let* ((string-list (make-string-list :strings (mapcar (display self)
                                                         (contents self))))
         (selection (make-single-selection :model string-list))
         (factory (make-signal-list-item-factory))
         (list-view (make-list-view :model selection :factory factory))
         (scrolled-window (make-scrolled-window)))

    (connect list-view "activate"
             (lambda (obj index)
               (declare (ignore obj))
               (funcall (on-change self)
                        (nth index (contents self)))))

    (connect factory "setup"
             (lambda (factory item)
               (declare (ignore factory))
               (let ((label (make-label :str "")))
                 (setf (list-item-child item) label
                       (widget-halign label) +align-start+)
                 label)))

    (connect factory "bind"
             (lambda (factory item)
               (declare (ignore factory))
               (setf (label-text (gobj:coerce (list-item-child item) 'label))
                     (string-object-string (gobj:coerce
                                            (list-item-item item)
                                            'string-object)))))

    (setf (gobject self) scrolled-window
          (internal self) string-list
          (list-view-single-click-activate-p list-view) t
          (widget-vexpand-p scrolled-window) t
          (widget-hexpand-p scrolled-window) t
          (scrolled-window-child scrolled-window) list-view)))

(defun generic-string-list-length (self)
  (gio:list-model-n-items (internal self)))

(defun generic-string-list-clear (self)
  (setf (contents self) '())
  (loop :while (not (= 0 (generic-string-list-length self)))
        :do (string-list-remove (internal self) 0)))

(defun generic-string-list-append (self list)
  (setf (contents self) (append (contents self) list))
  (loop :for it :in list
        :for str := (funcall (display self) it)
        :do (string-list-append (internal self) str)))

(defun list-insert-at (lst index value)
  "https://stackoverflow.com/questions/4387570/in-common-lisp-how-can-i-insert-an-element-into-a-list-in-place"
  (let ((retval nil))
    (loop :for i :from 0 :to (- (length lst) 1)
          :do (when (= i index)
                (push value retval))
              (push (nth i lst) retval))
    (when (>= index (length lst))
      (push value retval))
    (nreverse retval)))

(defmethod generic-string-list-insert (self index item)
  (setf (contents self) (list-insert-at (contents self) index item))
  (let ((str (funcall (display self) item)))
    (string-list-splice (internal self) index 0 (list str))))

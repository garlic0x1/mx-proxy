(in-package :gtk-widgets)

(defclass generic-string-list ()
  ((widget
    :initform nil
    :accessor widget)
   (internal
    :initform nil
    :accessor internal)
   (display
    :initarg :display
    :initform (lambda (item) (format nil "~a" item))
    :accessor display)
   (contents
    :initarg :contents
    :initform nil
    :accessor contents)))

(defmethod initialize-instance :after ((self generic-string-list)
                                       &key &allow-other-keys)
  (let* ((string-list (make-string-list :strings (mapcar (display self)
                                                         (contents self))))
         (selection (make-single-selection :model string-list))
         (factory (make-signal-list-item-factory))
         (list-view (make-list-view :model selection :factory factory))
         (scrolled-window (make-scrolled-window)))

    (connect factory "setup"
             (lambda (factory item)
               (declare (ignore factory))
               (setf (list-item-child item) (make-label :str ""))))

    (connect factory "bind"
             (lambda (factory item)
               (declare (ignore factory))
               (setf (label-text (gobj:coerce (list-item-child item) 'label))
                     (string-object-string (gobj:coerce
                                            (list-item-item item)
                                            'string-object)))))

    (setf (widget self) scrolled-window
          (internal self) string-list
          (widget-vexpand-p scrolled-window) t
          (widget-hexpand-p scrolled-window) t
          (scrolled-window-child scrolled-window) list-view)))

(defun generic-string-list-length (self)
  (gio:list-model-n-items (internal self)))

(defun generic-string-list-clear (self)
  (setf (contents self) '())
  (loop :while (not (= 0 (string-list-length self)))
        :do (string-list-remove (internal self) 0)))

(defun generic-string-list-append (self list)
  (setf (contents self) (append (contents self) list))
  (loop :for it :in list
        :for str := (funcall (display self) it)
        :do (string-list-append (internal self) str)))

(in-package :gtk-widgets)

(defclass string-list* (widget)
  ((widget
    :initform nil
    :accessor widget)
   (internal
    :initform nil
    :accessor internal)
   (strings
    :initarg :strings
    :initform nil
    :accessor strings)))

(defmethod initialize-instance :after ((self string-list*) &key &allow-other-keys)
  (let* ((scroll      (make-scrolled-window))
         (string-list (make-string-list :strings (strings self)))
         (selection   (make-single-selection :model string-list))
         (factory     (make-signal-list-item-factory))
         (list-view   (make-list-view :model selection :factory factory)))
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
    (setf (internal self) string-list
          (scrolled-window-child scroll) list-view
          (widget-hexpand-p scroll) t
          (widget-vexpand-p scroll) t
          (gobject self) scroll)))

(defmethod string-list*-length ((self string-list*))
  (gio:list-model-n-items (internal self)))

(defmethod string-list*-clear ((self string-list*))
  (loop :while (not (= 0 (string-list*-length self)))
        :do (string-list-remove (internal self) 0)))

(defmethod string-list*-append (self list)
  (loop :for it :in list
        :do (string-list-append (internal self) it)))

(defmethod string-list*-get-string (self index)
  (string-list-get-string (internal self) index))

(defmethod string-list*-insert (self index item)
  (string-list-splice (internal self) index 0 (list item)))

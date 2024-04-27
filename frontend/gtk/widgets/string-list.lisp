(in-package :gtk-widgets)

(defclass string-list* (widget)
  ((internal
    :initform nil
    :accessor internal)
   (strings
    :initarg :strings
    :initform nil
    :accessor strings)
   (selection
    :accessor selection)
   (scroll-p
    :initarg :scroll-p
    :initform t
    :accessor scroll-p)
   (separator-p
    :initarg :separator-p
    :initform nil
    :accessor separator-p)
   (single-click-p
    :initarg :single-click-p
    :initform nil
    :accessor single-click-p)
   (on-change
    :initarg :on-change
    :initform (lambda (i str) (declare (ignore i str)) (warn "No handler."))
    :accessor on-change)))

(defmethod initialize-instance :after ((self string-list*) &key &allow-other-keys)
  (let* ((string-list (make-string-list :strings (strings self)))
         (selection   (make-single-selection :model string-list))
         (factory     (make-signal-list-item-factory))
         (list-view   (make-list-view :model selection :factory factory)))
    (connect list-view "activate"
             (lambda (obj index)
               (declare (ignore obj))
               (funcall (on-change self) index (string-list*-get-string self index))))
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
    (setf (list-view-show-separators-p list-view) (separator-p self)
          (list-view-single-click-activate-p list-view) (single-click-p self))
    (if (scroll-p self)
        (let ((scroll (make-scrolled-window)))
          (setf (internal self) string-list
                (scrolled-window-child scroll) list-view
                (widget-hexpand-p scroll) t
                (widget-vexpand-p scroll) t
                (gobject self) scroll))
        (setf (internal self) string-list
              (widget-hexpand-p list-view) t
              (widget-vexpand-p list-view) t
              (selection self) selection
              (gobject self) list-view))))

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

(defmethod string-list*-set-index (self index)
  (setf (single-selection-selected (selection self)) index))

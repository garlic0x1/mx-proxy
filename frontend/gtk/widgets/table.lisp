(in-package :gtk-widgets)

(defclass string-table (widget)
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

(defmethod initialize-instance :after ((self string-table) &key &allow-other-keys)
  (let* ((string-list (make-string-list :strings (mapcar (display self)
                                                         (contents self))))
         (store (make-list-store :types '(string)))
         (selection (make-single-selection :model string-list))
         (factory (make-signal-list-item-factory))
         (list-view (make-list-view :model selection :factory factory))
         (scroll (make-scrolled-window)))

    (connect list-view "activate"
             (lambda (obj index)
               (declare (ignore obj))
               (funcall (on-change self)
                        (nth index (contents self)))))

    (connect factory "setup"
             (lambda (factory item)
               (declare (ignore factory))
               (let ((grid (make-grid)))
                 (setf (list-item-child item) grid
                       (widget-hexpand-p grid) t)
                 grid)))

    (connect factory "bind"
             (lambda (factory it)
               (declare (ignore factory))
               (loop :with strobj := (gobj:coerce (list-item-item it) 'string-object)
                     :with str := (string-object-string strobj)
                     :with i := 0
                     :with grid := (gobj:coerce (list-item-child it) 'grid)
                     :for word :in (str:words str)
                     :for label := (make-label :str word)
                     :for sep := (make-separator :orientation +orientation-vertical+)
                     :do (grid-attach grid label i 0 1 1)
                     :do (grid-attach grid sep (1+ i) 0 1 1)
                     :do (incf i 2))))

    (setf (gobject self) scroll
          (internal self) string-list
          (list-view-single-click-activate-p list-view) t
          (widget-vexpand-p scroll) t
          (widget-hexpand-p scroll) t
          (scrolled-window-child scroll) list-view)))

(defun string-table-append (self list)
  (setf (contents self) (append (contents self) list))
  (loop :for it :in list
        :for str := (funcall (display self) it)
        :do (string-list-append (internal self) str)))

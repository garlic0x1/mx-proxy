(in-package :mx-proxy/gtk)

(defclass traffic-list (widget)
  ((contents
    :initarg :contents
    :initform '()
    :accessor contents)
   (callback
    :initarg :callback
    :initform (lambda (value) (declare (ignore value)) (warn "No callback."))
    :accessor callback)
   (store
    :accessor traffic-list-store)))

(defun message-pair-row (mp)
  (let ((req (http:message-pair-request mp))
        (resp (http:message-pair-response mp)))
    (make-string-list
     :strings
     (list (format nil "~a" (mito.dao.mixin:object-id mp))
           (http:request-method req)
           (str:shorten 45 (format nil "~a" (http:request-url req)))
           (format nil "~a" (http:response-status-code resp))))))

(defmethod initialize-instance :before ((self traffic-list) &key &allow-other-keys)
  "Fix CFFI type nonsense"
  (make-string-list :strings nil)
  (values))

(defmethod initialize-instance :after ((self traffic-list) &key &allow-other-keys)
  (let*
      ((scroll (make-scrolled-window))
       (rows (mapcar #'message-pair-row (contents self)))
       (store (gio:make-list-store :item-type (gobj:type-from-name "GtkStringList")))
       (selection (make-single-selection :model store))
       (column-view (make-column-view :model selection))
       (id-factory (make-signal-list-item-factory))
       (id-col (make-column-view-column :title "ID" :factory id-factory))
       (method-factory (make-signal-list-item-factory))
       (method-col (make-column-view-column :title "Method" :factory method-factory))
       (url-factory (make-signal-list-item-factory))
       (url-col (make-column-view-column :title "URL" :factory url-factory))
       (status-factory (make-signal-list-item-factory))
       (status-col (make-column-view-column :title "Status" :factory status-factory))
       (cols (list id-col method-col url-col status-col))
       (factories (list id-factory method-factory url-factory status-factory)))
    (loop :for col :in cols
          :do (column-view-append-column column-view col))
    (loop :for row :in rows
          :do (gio:list-store-append store row))
    (setf (scrolled-window-child scroll) column-view
          (gobject self) scroll)
    (loop :for factory :in factories
          :for index :from 0
          :do (connect factory "setup"
                       (lambda (factory item)
                         (declare (ignore factory))
                         (let ((label (gtk:make-label :str "")))
                           (setf (widget-halign label) +align-start+
                                 (widget-hexpand-p label) t
                                 (label-wrap-p label) t
                                 (gtk:list-item-child item) label))))
          :do (connect factory "bind"
                       (let ((i index))
                         (lambda (factory item)
                           (declare (ignore factory))
                           (setf (gtk:label-text
                                  (gobj:coerce (gtk:list-item-child item)
                                               'gtk:label))
                                 (gtk:string-list-get-string
                                  (gobj:coerce (gtk:list-item-item item)
                                               'gtk:string-list)
                                  i))))))
    (connect column-view "activate"
             (lambda (widget index)
               (declare (ignore widget))
               (funcall (callback self) (traffic-list-get-message-pair self index))))
    (setf (gobject self) scroll
          (scrolled-window-child scroll) column-view
          (column-view-single-click-activate-p column-view) t
          (column-view-show-row-separators-p column-view) t
          (traffic-list-store self) store
          ;; (widget-vexpand-p column-view) t
          ;; (widget-hexpand-p column-view) t
          ;; (widget-vexpand-p scroll) t
          ;; (widget-hexpand-p scroll) t
          )))

(defmethod traffic-list-length ((self traffic-list))
  (gio:list-model-n-items (traffic-list-store self)))

(defmethod traffic-list-push ((self traffic-list) message-pair)
  (setf (contents self) (cons message-pair (contents self)))
  (let ((row (message-pair-row message-pair)))
    (gio:list-store-insert (traffic-list-store self) 0 row)))

(defmethod traffic-list-clear ((self traffic-list))
  (gio:list-store-remove-all (traffic-list-store self)))

(defmethod traffic-list-get-message-pair ((self traffic-list) index)
  (nth index (contents self)))

(defmethod traffic-list-append ((self traffic-list) items)
  (setf (contents self) (append (contents self) items))
  (loop :for item :in items
        :for row := (message-pair-row item)
        :do (gio:list-store-append (traffic-list-store self) row)))

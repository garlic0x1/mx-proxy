(in-package :mx-proxy/gtk)

(defclass traffic-list (widget)
  ((id-col
    :initform (make-instance 'string-list* :scroll-p nil)
    :accessor tl-id-col)
   (method-col
    :initform (make-instance 'string-list* :scroll-p nil)
    :accessor tl-method-col)
   (url-col
    :initform (make-instance 'string-list* :scroll-p nil)
    :accessor tl-url-col)
   (status-col
    :initform (make-instance 'string-list* :scroll-p nil)
    :accessor tl-status-col)
   (contents
    :initform '()
    :accessor contents)))

(defmethod initialize-instance :after ((self traffic-list) &key &allow-other-keys)
  (let* ((scroll (make-scrolled-window))
         (grid (make-grid)))
    (grid-attach grid (make-label :str "ID") 0 0 1 1)
    (grid-attach grid (gobject (tl-id-col self)) 0 1 1 1)
    (grid-attach grid (make-label :str "Method") 1 0 1 1)
    (grid-attach grid (gobject (tl-method-col self)) 1 1 1 1)
    (grid-attach grid (make-label :str "URL") 3 0 1 1)
    (grid-attach grid (gobject (tl-url-col self)) 3 1 1 1)
    (grid-attach grid (make-label :str "Status") 4 0 1 1)
    (grid-attach grid (gobject (tl-status-col self)) 4 1 1 1)
    (setf (gobject self) scroll
          (widget-hexpand-p scroll) t
          (widget-vexpand-p scroll) t
          (scrolled-window-child scroll) grid)))

(defmethod traffic-list-length ((self traffic-list))
  (string-list*-length (tl-id-col self)))

(defmethod traffic-list-clear ((self traffic-list))
  (setf (contents self) '())
  (string-list*-clear (tl-id-col self))
  (string-list*-clear (tl-method-col self))
  (string-list*-clear (tl-url-col self))
  (string-list*-clear (tl-status-col self)))

(defun stringify (x)
  (str:shorten 40 (format nil "~a" x) :ellipsis "..."))

(defmethod traffic-list-append-item ((self traffic-list) (item http:message-pair))
  (setf (contents self) (append (contents self) (list item)))
  (string-list*-append (tl-id-col self) (list "ID"))
  (string-list*-append (tl-method-col self)
                       (list
                        (stringify
                         (http:request-method
                          (http:message-pair-request item)))))
  (string-list*-append (tl-url-col self)
                       (list
                        (stringify
                         (http:request-url
                          (http:message-pair-request item)))))
  (string-list*-append (tl-status-col self)
                       (list
                        (stringify
                         (http:response-status-code
                          (http:message-pair-response item))))))

(defmethod traffic-list-append ((self traffic-list) list)
  (loop :for it :in list
        :do (traffic-list-append-item self it)))


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

;; (defmethod traffic-list-insert ((self traffic-list) index (item message-pair))
;;   (setf (contents self) (list-insert-at (contents self) index item))
;;   (let ((str (funcall (display self) item)))
;;     (string-list-splice (internal self) index 0 (list str))))

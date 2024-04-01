(in-package :ng-widgets)

(defwidget inspector (frame)
  ((view
    :initform nil
    :accessor inspector-view)
   (stack
    :initform '()
    :accessor inspector-stack)
   (init-value
    :initform nil
    :initarg :value
    :accessor inspector-init-value))
  ((pop-button button
               :grid '(0 1 :sticky "e")
               :text "Pop"
               :command (curry 'inspector-pop self))
   (crumbs label
           :grid '(0 0 :sticky "w")))

  (grid-columnconfigure self 0 :weight 1)
  (grid-columnconfigure self 1 :weight 1)
  (grid-rowconfigure self 0 :minsize 32)
  (grid-rowconfigure self 1 :weight 1)
  (inspector-push self (inspector-init-value self)))

(defun inspector-pop (self)
  (when (< 1 (length (inspector-stack self)))
    (pop (inspector-stack self))
    (inspector-push self (pop (inspector-stack self)))))

(defun inspector-push (self value)
  (push value (inspector-stack self))
  (if (= 1 (length (inspector-stack self)))
      (grid-forget (pop-button self))
      (grid (pop-button self) 0 1 :sticky "e"))
  (when (inspector-view self)
    (destroy (inspector-view self)))
  (setf (text (crumbs self))
        (format nil " ~{ > ~a~}"
                (reverse (mapcar #'class-of-simple (inspector-stack self))))
        (inspector-view self)
        (make-instance (inspector-view-class value)
                       :grid '(1 0 :columnspan 2 :sticky "nsew")
                       :value value
                       :master self)))

(defun inspector-swap (self value)
  (setf (inspector-init-value self) value
        (inspector-stack self) '())
  (inspector-push self value))

(defun inspector-value (self)
  (car (inspector-stack self)))

;;
;; View widgets per type.
;;

(defwidget inspector-class-view (frame)
  ((value
    :initarg :value
    :accessor inspector-class-view-value))
  ((class-view listbox*
               :pack (:fill :both :expand t)
               :double-click t
               :display (lambda (slot)
                          (format nil "~a = ~a" (car slot) (cdr slot)))
               :command (lambda (slots)
                          (when-let ((slot (car slots)))
                            (inspector-push (master self) (cdr slot))))
               :items (slots-alist (inspector-class-view-value self)))))

(defwidget inspector-list-view (frame)
  ((value
    :initarg :value
    :accessor inspector-list-view-value))
  ((list-view listbox*
              :pack (:fill :both :expand t)
              :double-click t
              :command (lambda (items)
                         (when-let ((item (car items)))
                           (inspector-push (master self) item)))))

  (let ((value (inspector-list-view-value self)))
    (listbox*-push list-view (if (listp (cdr value))
                                 value
                                 (list (car value) (cdr value))))))

(defwidget inspector-vector-view (frame)
  ((value
    :initarg :value
    :accessor inspector-vector-view-value))
  ((list-view listbox*
              :pack (:fill :both :expand t)
              :double-click t
              :display (lambda (item)
                         (format nil "~a. ~a" (car item) (cdr item)))
              :command (lambda (items)
                         (when-let ((item (car items)))
                           (inspector-push (master self) (cdr item))))
              :items (loop :with i := 0
                           :for item :across (inspector-vector-view-value self)
                           :collect (cons i item)
                           :do (incf i)))))

(defwidget inspector-primitive-view (frame)
  ((value
    :initarg :value
    :accessor inspector-list-view-value))
  ((list-view listbox*
              :pack (:fill :both :expand t)
              :items (str:lines
                      (format nil "~a"
                              (inspector-list-view-value self))))))

;;
;; Dispatch view on value type
;;

(defgeneric inspector-view-class (value)
  (:method ((value standard-object))  'inspector-class-view)
  (:method ((value structure-object)) 'inspector-class-view)
  (:method ((value list))             'inspector-list-view)
  (:method ((value vector))           'inspector-vector-view)
  (:method ((value string))           'inspector-primitive-view)
  (:method ((value t))                'inspector-primitive-view))

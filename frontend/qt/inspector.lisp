(in-package :mx-proxy/qt)
(in-readtable :qtools)

(define-widget generic-frame (QWidget)
  ((value
    :initarg :value
    :initform (error "Must provide :value")
    :accessor value)
   (parent
    :initarg :parent
    :initform (error "Must provide :parent")
    :accessor parent)))

(define-widget primitive-frame (QTextEdit generic-frame) ())

(define-initializer (primitive-frame setup)
  (setf (q+:text primitive-frame)
        (with-output-to-string (c)
          (describe (value primitive-frame) c))))

(define-widget list-frame (QListWidget generic-frame) ())

(define-initializer (list-frame setup)
  (loop :for item :in (value list-frame)
        :do (q+:add-item list-frame (format nil "~a" item))))

(define-override (list-frame mouse-press-event) (ev)
  (call-next-qmethod)
  (ignore-errors
    (let ((value (elt (value list-frame) (q+:current-row list-frame))))
      (push value (stack (parent list-frame)))
      (signal! (parent list-frame) (stack-changed)))))

(define-widget class-frame (QListWidget generic-frame)
  ((slots
    :initform '()
    :accessor slots)))

(define-initializer (class-frame setup)
  (loop :for slot :in (slots-alist (value class-frame))
        :do (q+:add-item class-frame (format nil "~a" slot))
        :do (setf slots (append slots (list (cdr slot))))))

(define-override (class-frame mouse-press-event) (ev)
  (call-next-qmethod)
  (ignore-errors
    (let ((value (elt (slots class-frame) (q+:current-row class-frame))))
      (push value (stack (parent class-frame)))
      (signal! (parent class-frame) (stack-changed)))))

(defgeneric frame-class (value)
  (:method ((value structure-object)) 'class-frame)
  (:method ((value standard-object))  'class-frame)
  (:method ((value list))             'list-frame)
  (:method ((value string))           'primitive-frame)
  (:method ((value t))                'primitive-frame))

(defun make-frame (value parent)
  (make-instance (frame-class value) :value value :parent parent))

(define-widget inspector (QWidget)
  ((value
    :initarg :value
    :initform nil
    :accessor value)
   (stack
    :initform nil
    :accessor stack)))

(define-signal (inspector stack-changed) ())

(define-initializer (inspector setup)
  (push (value inspector) (stack inspector))
  (signal! inspector (stack-changed)))

(define-subwidget (inspector crumbs) (q+:make-qlabel inspector))

(define-subwidget (inspector pop) (q+:make-qpushbutton "Pop" inspector))

(define-subwidget (inspector description) (q+:make-qtextedit inspector))

(define-subwidget (inspector frame) (make-frame (value inspector) inspector))

(define-subwidget (inspector tabs) (q+:make-qtabwidget)
  (q+:insert-tab tabs 0 frame "Value")
  (q+:insert-tab tabs 1 description "Class"))

(define-subwidget (inspector layout) (q+:make-qvboxlayout inspector)
  (let ((top (q+:make-qhboxlayout)))
    (q+:add-widget top crumbs)
    (q+:add-widget top pop)
    (q+:add-layout layout top))
  (q+:add-widget layout tabs))

(define-slot (inspector pop-item) ()
  (declare (connected pop (pressed)))
  (when (< 1 (length (stack inspector)))
    (setf (stack inspector) (cdr (stack inspector)))
    (signal! inspector (stack-changed))))

(define-slot (inspector stack-changed-handler) ()
  (declare (connected inspector (stack-changed)))
  (q+:close frame)
  (q+:remove-tab tabs 0)
  (if (= 1 (length (stack inspector)))
      (q+:set-visible pop nil)
      (q+:set-visible pop t))
  (setf frame (make-frame (car (stack inspector)) inspector))
  (q+:insert-tab tabs 0 frame "Value")
  (setf (q+:text description)
        (with-output-to-string (c)
          (describe (class-of (car (stack inspector))) c)))
  (q+:set-focus frame)
  (q+:set-current-index tabs 0)
  (setf (q+:text crumbs)
        (line-up-last (stack inspector)
                      (mapcar #'class-of)
                      (mapcar #'class-name)
                      (reverse)
                      (format nil  "~{~a~^ > ~}"))))

(defmethod swap ((self inspector) value)
  (setf (stack self) (list value))
  (setf (value self) value)
  (signal! self (stack-changed)))

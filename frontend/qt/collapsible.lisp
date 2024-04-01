(in-package :mx-proxy/qt)
(in-readtable :qtools)

(define-widget collapsible (QWidget)
  ((content
    :initarg :content
    :initform nil
    :accessor content)))

(define-subwidget (collapsible button) (q+:make-qpushbutton collapsible)
  (setf (q+:text button) "Toggle"))

(define-subwidget (collapsible layout) (q+:make-qgridlayout collapsible)
  (setf (q+:spacing layout) 0)
  (q+:add-widget layout button 0 0)
  (when (content collapsible)
    (q+:add-widget layout (content collapsible) 1 0)))

(define-slot (collapsible toggle-content) ()
  (declare (connected button (pressed)))
  (print *qapplication*)
  (if (q+:is-visible (content collapsible))
      (setf (q+:visible (content collapsible)) nil)
      (setf (q+:visible (content collapsible)) t)))

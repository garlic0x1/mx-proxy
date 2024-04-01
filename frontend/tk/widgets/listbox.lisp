(in-package :ng-widgets)

(defwidget listbox* (listbox)
  ((items
    :initform (make-array 128 :fill-pointer 0 :adjustable t)
    :accessor listbox*-items)
   (init-items
    :initarg :items
    :initform nil
    :accessor listbox*-init-items)
   (display
    :initarg :display
    :initform (lambda (it) (format nil "~a" it))
    :accessor listbox*-display)
   (command
    :initarg :command
    :initform #'identity
    :accessor listbox*-command)
   (double-click
    :initarg :double-click
    :initform nil
    :accessor listbox*-double-click))
  ()

  (listbox*-push self (listbox*-init-items self))

  (if (listbox*-double-click self)
      (bind self "<Double-1>"
        (lambda (e)
          (alexandria-2:line-up-last
           (event-y e)
           (listbox-nearest self)
           (listbox*-get self)
           (list)
           (funcall (listbox*-command self)))))
      (setf (command self)
            (lambda (indices)
              (funcall (listbox*-command self)
                       (mapcar (curry #'listbox*-get self)
                               indices))))))

(defun listbox*-get (widget index)
  (elt (listbox*-items widget) index))

(defun listbox*-append (widget values)
  (listbox-append widget (mapcar (listbox*-display widget) values))
  (dolist (val values)
    (vector-push-extend val (listbox*-items widget))))

(defun listbox*-insert (widget index values)
  (listbox-insert widget index (mapcar (listbox*-display widget) values))
  (vector-insert (listbox*-items widget) index values))

(defun listbox*-push (widget values)
  (listbox*-insert widget 0 values))

(defun listbox*-value (widget)
  (listbox*-get widget (car (listbox-get-selection widget))))

(defun listbox*-delete-all (widget)
  (listbox-delete widget 0 (listbox-size widget))
  (setf (listbox*-items widget) (make-array 128 :fill-pointer 0 :adjustable t)))

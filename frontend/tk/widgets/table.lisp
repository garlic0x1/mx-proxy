(in-package :ng-widgets)

(defwidget tablebox (frame)
  ((rows
    :initform '()
    :accessor tablebox-rows)
   (init-rows
    :initarg :rows
    :initform '()
    :accessor tablebox-init-rows)
   (col-names
    :initarg :col-names
    :initform '()
    :accessor tablebox-col-names)
   (col-widgets
    :initform '()
    :accessor tablebox-col-widgets)
   (index
    :initform nil
    :accessor tablebox-index)
   (command
    :initarg :command
    :initform #'identity
    :accessor tablebox-command)
   (double-click
    :initarg :double-click
    :initform nil
    :accessor tablebox-double-click))
  ()

  (dolist (name (tablebox-col-names self))
    (push (make-instance 'listbox :pack '(:fill :both :expand t :side :right))
          (tablebox-col-widgets self)))

  (tablebox-append self (tablebox-init-rows self)))

(defun tablebox-get (self index)
  (elt (tablebox-rows self) index))

(defun tablebox-append (self rows)
  (dolist (row rows)
    (setf (tablebox-rows self)
          (append (tablebox-rows self) (list row)))
    (loop :for col :in row
          :for widget :in (tablebox-col-widgets self)
          :do (listbox-append widget (list col)))))

(defun tablebox-push (self row)
  (push row (tablebox-rows self))
  (loop :for col :in row
        :for widget :in (tablebox-col-widgets self)
        :do (print col)
        :do (listbox-insert widget 0 (list col))))

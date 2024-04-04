(in-package :mx-proxy/tk)

(defwidget error-message (frame)
  ((value
    :initarg :value
    :initform nil
    :accessor error-message-value))
  ((inspector inspector
              :grid '(0 0 :sticky :nsew)
              :value (error-message-value self))
   (ok-button button
              :grid '(1 0 :sticky :nsew)
              :text "Okay"
              :command 'exit-nodgui))
  (grid-rowconfigure self 0 :weight 1)
  (grid-rowconfigure self 1 :minsize 32)
  (grid-columnconfigure self 0 :weight 1))

(defun tk-error (c)
  (with-nodgui (:title "Error")
    (make-instance 'error-message
                   :pack '(:fill :both :expand t)
                   :value c)))

(defmethod mx-proxy:show-error-message
    ((interface (eql :tk)) condition &key severity)
  (declare (ignore severity))
  (tk-error condition))

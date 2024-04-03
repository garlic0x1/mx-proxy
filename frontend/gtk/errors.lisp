(in-package :mx-proxy/gtk)

(defmethod mx-proxy:show-error-message
    ((interface (eql :gtk)) condition &key severity)
  (declare (ignore severity))
  (let ((widget))
    (setf widget
          (make-instance 'error-message
                         :value condition
                         :callback
                         (lambda ()
                           (grid-remove *top-grid* (gobject widget)))))
    (grid-attach *top-grid* (gobject widget) 0 2 1 1)))

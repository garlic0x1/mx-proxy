(in-package :mx-proxy/gtk)

(defmethod mx-proxy:prompt-for-string*
    ((interface (eql :gtk)) callback &key message completion validation start)
  (let ((widget))
    (setf widget
          (make-instance 'prompt
                         :message message
                         :start start
                         :validation validation
                         :completion completion
                         :cancel-callback
                         (lambda ()
                           (grid-remove *top-grid* (gobject widget)))
                         :callback
                         (lambda (val)
                           (funcall callback val)
                           (grid-remove *top-grid* (gobject widget)))))
    (grid-attach *top-grid* (gobject widget) 0 2 1 1)))

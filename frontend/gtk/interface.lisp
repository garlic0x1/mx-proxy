(in-package :mx-proxy/gtk)

(defmethod mx-proxy/interface:prompt-for-string*
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
                           (setf *in-prompt* nil)
                           (grid-remove *top-grid* (gobject widget)))
                         :callback
                         (lambda (val)
                           (funcall callback val)
                           (setf *in-prompt* nil)
                           (grid-remove *top-grid* (gobject widget)))))
    (setf *in-prompt* t)
    (grid-attach *top-grid* (gobject widget) 0 2 1 1)
    (gtk-widgets::prompt-grab-focus widget)))

(defmethod mx-proxy/interface:message* ((interface (eql :gtk)) value)
  (flet ((pretty-time ()
           (multiple-value-bind (s m h) (get-decoded-time)
             (format nil "~a:~a:~a" h m s))))
    (string-list*-insert *top-messages* 0 (format nil "~a ~a" (pretty-time) value))))

(in-package :mx-proxy/clog)

(defmethod mx-proxy/interface:prompt-for-string*
    ((interface (eql :clog)) callback &key message completion validation start)
  (prompt-dialog callback message completion validation start))

(defmethod mx-proxy/interface:message* ((interface (eql :clog)) value)
  (let ((msg (make-log-item :time (get-universal-time) :value value)))
    (push msg *messages*)
    (if:run-hook :update-messages msg)))

(defmethod mx-proxy/interface:show-error-message
    ((interface (eql :clog)) condition &key severity)
  (declare (ignore severity))
  (flet ()
    (alert-dialog *window* (format nil "~a ~a" (pretty-time (get-universal-time)) condition))))

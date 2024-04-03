(in-package :mx-proxy/tk)

(defmethod mx-proxy:prompt-for-string*
    ((interface (eql :tk)) callback &key message completion start)
  (let ((widget nil))
    (setf widget (make-instance 'prompt
                                :master *main-app*
                                :value start
                                :message message
                                :completion completion
                                :command (lambda (value)
                                           (funcall callback value)
                                           (destroy widget))))
    (grid widget 1 0 :sticky :nsew)))

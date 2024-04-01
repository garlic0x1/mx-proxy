(in-package :mx-proxy/lem)

(defun traffic-button (pair width)
  (let ((req (http:message-pair-request pair))
        (resp (http:message-pair-response pair))
        (w1 (- width (ceiling (/ width 4))))
        (w2 (ceiling (/ width 4))))
    (format nil (format nil "~~~aa~~~aa" w1 w2) ;"~64a~22:a"
            (str:shorten w1 (format nil "~a ~a"
                                    (http:request-method req)
                                    (http:request-uri req)))
            (str:shorten w2
                         (format nil "~a ~a"
                                 (http:response-status-code resp)
                                 (http:response-status resp))))))

(defun get-window-width (buffer)
  (let ((buffer (car (get-buffer-windows buffer))))
    (when buffer
      (1- (window-width buffer)))))

(defun render-traffic-list (list)
  (let ((buffer (get-traffic-buffer)))
    (clear-buffer buffer)
    (mapcar (lambda (pair)
              (lem/button:insert-button
               (buffer-end-point buffer)
               (traffic-button pair (or (get-window-width buffer) 86))
               (lambda () (inspect-pair pair))
               :attribute (make-attribute :underline t :bold t))
              (insert-character (buffer-end-point buffer) #\Newline))
            list)))

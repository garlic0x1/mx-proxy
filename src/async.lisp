(in-package :mx-proxy)

(defun async-connection-handler (conn data)
  (with-log-errors
    (let ((req (http:read-request-from-octets data)))
      (if (string-equal :connect (http:request-method req))
          (error "Not implemented.")
          (progn
            (run-hook :on-request req)
            (let ((resp (http:send)))))))))

(defun async-server-loop (host port handler)
  (as:start-event-loop
   (lambda ()
     (as:tcp-server host port handler))))

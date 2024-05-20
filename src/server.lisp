(in-package :mx-proxy)

(defvar *server* nil)

(defun ssl-connection-handler (conn host)
  "Handle connections upgraded to SSL."
  (with-ssl-server-stream (stream conn (first (str:split ":" host)))
    (let ((req (http:read-request stream :host host :ssl-p t)))
      (run-hook :on-request req)
      (let ((resp (send-request-ssl req :raw t)))
        (run-hook :on-response req resp)
        (db-insert-pair req resp)
        (http:write-raw-message stream resp)))))

(defun connection-handler (conn)
  "Handle incoming connections from the client."
  ;; (with-log-errors)
  (let* ((stream (us:socket-stream conn))
         (req (http:read-request stream)))
    (if (string-equal :connect (http:request-method req))
        (let ((host (puri:render-uri (http:request-uri req) nil)))
          (write-ssl-accept stream)
          (ssl-connection-handler conn host))
        (progn
          (run-hook :on-request req)
          (let ((resp (http:send-request req :raw t)))
            (run-hook :on-response req resp)
            (db-insert-pair req resp)
            (http:write-raw-message stream resp))))))

(defun replay (req edited)
  "Replay a request using the edited text of the raw message."
  (let ((req (http:read-request-from-string
              edited
              :host (http:request-host req)
              :ssl-p (http:request-ssl-p req))))
    (run-hook :on-request req)
    (let ((resp (if (http:request-ssl-p req)
                    (send-request-ssl req :raw t)
                    (http:send-request req :raw t))))
      (run-hook :on-response req resp)
      (db-insert-pair req resp :metadata '((:replay))))))

(define-command start-server (&optional (host "127.0.0.1") (port 5000)) ("sHost" "iPort")
  "Main function to start the backend, should be invoked from a frontend command."
  (with-ui-errors
    (connect-database)
    (setf *server*
          (http:start-server :host host :port port :handler 'connection-handler))))

(define-command start-default-server () ()
  (start-server))

(define-command stop-server () ()
  "Also to invoke from frontend command."
  (with-ui-errors
    (http:stop-server *server*)
    (setf *server* nil)))

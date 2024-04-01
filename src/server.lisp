(in-package :mx-proxy)

(defun ssl-connection-handler (conn host)
  "Handle connections upgraded to SSL."
  (with-ssl-server-stream (stream conn (first (str:split ":" host)))
    (let ((req (http:read-request stream :host host)))
      (proxy/hooks:run-hook :on-request req)
      (let ((resp (send-request-ssl req :raw t :host host)))
        (proxy/hooks:run-hook :on-response req resp)
        (proxy/db:insert-pair req resp)
        (http:write-raw-message stream resp)))))

(defun connection-handler (conn)
  "Handle incoming connections from the client."
  (ignore-errors
    (let* ((stream (us:socket-stream conn))
           (req (http:read-request stream)))
      (if (string-equal :connect (http:request-method req))
          (let ((host (puri:render-uri (http:request-uri req) nil)))
            (write-ssl-accept stream)
            (ssl-connection-handler conn host))
          (progn
            (proxy/hooks:run-hook :on-request req)
            (let ((resp (http:send-request req :raw t)))
              (proxy/hooks:run-hook :on-response req resp)
              (proxy/db:insert-pair req resp)
              (http:write-raw-message stream resp)))))))

(defun replay (req edited &key ssl host)
  "Replay a request using the edited text of the raw message."
  (let* ((req (proxy/util:copy req :raw edited))
         (resp (if ssl
                   (proxy/ssl:send-request-ssl req :raw t :host host)
                   (http:send-request req :raw t))))
    (values resp (proxy/db:insert-pair req resp :metadata '((:replay . t))))))

(defun start-server (&key (host "127.0.0.1") (port 5000))
  (proxy/db:connect)
  (http:start-server :host host :port port :handler 'connection-handler))

(defun stop-server (&key force)
  (http:stop-server :force force))

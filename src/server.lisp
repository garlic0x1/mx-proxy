(in-package :mx-proxy)

(defun ssl-connection-handler (conn host)
  "Handle connections upgraded to SSL."
  (with-ssl-server-stream (stream conn (first (str:split ":" host)))
    (let ((req (http:read-request stream :host host)))
      (run-hook :on-request req)
      (let ((resp (send-request-ssl req :raw t :host host)))
        (run-hook :on-response req resp)
        (db-insert-pair req resp)
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
            (run-hook :on-request req)
            (let ((resp (http:send-request req :raw t)))
              (run-hook :on-response req resp)
              (db-insert-pair req resp)
              (http:write-raw-message stream resp)))))))

(defun replay (req edited &key ssl host)
  "Replay a request using the edited text of the raw message."
  (declare (ignore req host ssl))
  (destructuring-bind (host port) (str:split ":" http:*host*)
    (let* ((conn (us:socket-connect host (parse-integer port)
                                    :element-type '(unsigned-byte 8)))
           (stream (us:socket-stream conn)))
      (unwind-protect
           (loop :for byte :across (flexi-streams:string-to-octets edited)
                 :do (write-byte byte stream)
                 :finally (force-output stream))
        (us:socket-close conn))))

  ;; bad, string to bin stream sucks
  ;; (with-input-from-string (stream edited)
  ;;   (let ((req (http:read-request stream :host host)))
  ;;     (run-hook :on-request req)
  ;;     (let ((resp (if ssl
  ;;                     (send-request-ssl req :raw t :host host)
  ;;                     (http:send-request req :raw t))))
  ;;       (run-hook :on-response req resp)
  ;;       (values resp (db-insert-pair req resp :metadata '((:replay . t)))))))

  ;; bad, doesnt update other slots
  ;; (let* ((req (copy req :raw edited))
  ;;        (resp (if ssl
  ;;                  (send-request-ssl req :raw t :host host)
  ;;                  (http:send-request req :raw t))))
  ;;   (values resp (db-insert-pair req resp :metadata '((:replay . t)))))
  )

(define-command start-server (&optional (host "127.0.0.1") (port 5000)) ("sHost" "iPort")
  "Main function to start the backend, should be invoked from a frontend command."
  (with-ui-errors
    (connect-database)
    (http:start-server :host host :port port :handler 'connection-handler)))

(define-command stop-server (&key force) ()
  "Also to invoke from frontend command."
  (with-ui-errors
    (http:stop-server :force force)))

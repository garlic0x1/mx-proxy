(in-package :mx-proxy)

(defun cert-file (name)
  (namestring
   (merge-pathnames
    (format nil "certs/~a" name)
    (asdf:system-source-directory :mx-proxy))))

(defun certificate (host &key create)
  "Retrieve or generate certificate and key for host."
  (let ((cert (cert-file (uiop:strcat host ".pem")))
        (key (cert-file (uiop:strcat host "-key.pem"))))
    (when create
      (unless (and (uiop:file-exists-p cert) (uiop:file-exists-p key))
        (uiop:with-current-directory ((cert-file ""))
          (uiop:run-program (uiop:strcat "mkcert " host)))))
    (values cert key)))

(defmacro with-ssl-server-stream ((stream conn host) &body body)
  "Wrap a server stream with SSL."
  `(multiple-value-bind (cert key) (certificate ,host :create t)
     (let ((,stream (ssl:make-ssl-server-stream
                     (if (integerp ,conn) ,conn (us:socket-stream ,conn))
                     :certificate cert
                     :key key)))
       (unwind-protect (progn ,@body)
         (close ,stream)))))

(defmacro with-ssl-client-stream ((stream conn host) &body body)
  "Wrap a client stream with SSL."
  `(let ((,stream (ssl:make-ssl-client-stream
                   (if (integerp ,conn) ,conn (us:socket-stream ,conn))
                   :hostname ,host)))
     (unwind-protect (progn ,@body)
       (close ,stream))))

(defun write-ssl-accept (stream)
  "Send a 200 response to accept the connection."
  (http:write-response stream (make-instance 'http:response)))

(defun send-request-ssl (req &key raw host)
  "Send a request with SSL."
  (multiple-value-bind (host port) (http:extract-host-and-port req :host host)
    (let ((conn (us:socket-connect host port :element-type '(unsigned-byte 8))))
      (with-ssl-client-stream (stream conn host)
        (if raw
            (http:write-raw-message stream req)
            (http:write-request stream req))
        (http:read-response stream)))))

(define-command purge-certs (sure) ("bAre you sure?")
  (when sure
    (dolist (file (uiop:directory-files (cert-file "")))
      (uiop:delete-file-if-exists file))))

(in-package :mx-proxy)

(defun request-url (req)
  "Might not be right, but it works for frontend displaying."
  (if-let ((host (http:request-host req)))
    (uiop:strcat "https://" host (puri:render-uri (http:request-uri req) nil))
    (http:request-uri req)))

(defun package-symbols (package)
  (let ((syms nil))
    (do-external-symbols (sym package)
      (push sym syms))
    syms))

(defun message-raw* (message &key decompress)
  "Get the raw message and optionally automagically decompress."
  (let* ((raw (http:message-raw message))
         (separator (http:crlf nil 2))
         (split (str:split separator raw :limit 2))
         (top (first split))
         (bottom (if decompress
                     (http:message-body message)
                     (second split))))
    (uiop:strcat top separator bottom)))

(defmethod copy ((req http:request) &key raw)
  (make-instance 'http:request
                 :method (http:request-method req)
                 :uri (http:request-uri req)
                 :protocol (http:request-protocol req)
                 :headers (http:message-headers req)
                 :body (http:message-body req)
                 :raw (or raw (http:message-raw req))
                 :host (http:request-host req)))

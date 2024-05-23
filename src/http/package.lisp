(uiop:define-package :http
  (:use :cl :alexandria-2)
  (:local-nicknames (:us :usocket))
  (:export
   ;; types.lisp
   :message
   :message-raw
   :message-headers
   :message-body
   :request
   :request-method
   :request-uri
   :request-protocol
   :request-host
   :request-ssl-p
   :response
   :response-protocol
   :response-status-code
   :response-status
   :message-pair
   :message-pair-metadata
   :message-pair-request
   :message-pair-response
   ;; read.lisp
   :read-request
   :read-request-from-octets
   :read-request-from-string
   :read-response
   ;; write.lisp
   :write-raw-message
   :write-request
   :write-response
   ;; server.lisp
   :server-thread
   :server-host
   :server-port
   :start-server
   :stop-server
   ;; client.lisp
   :send-request
   :extract-host-and-port
   ;; encoding.lisp
   :decompress-string
   ;; utils.lisp
   :crlf))

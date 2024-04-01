(defpackage :http
  (:use :cl :alexandria-2)
  (:local-nicknames (:us :usocket))
  (:import-from :cl-annot.class :export-class)
  (:export
   ;; read.lisp
   :read-request
   :read-response
   ;; write.lisp
   :write-raw-message
   :write-request
   :write-response
   ;; server.lisp
   :start-server
   :stop-server
   ;; client.lisp
   :send-request
   :extract-host-and-port
   ;; encoding.lisp
   :decompress-string
   ;; utils.lisp
   :crlf))

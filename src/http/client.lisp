(in-package :http)

(defun extract-host-and-port (message &key host)
  "If host is specified, extract from that."
  (let* ((host (or host (assoc-value (message-headers message) :host)))
         (split (str:split ":" host :limit 2)))
    (values (first split)
            (parse-integer (or (second split) "80")))))

(defun send-request (req &key raw)
  (multiple-value-bind (host port) (extract-host-and-port req)
    (let* ((conn (us:socket-connect host port :element-type '(unsigned-byte 8)))
           (stream (us:socket-stream conn)))
      (unwind-protect
           (progn (if raw
                      (http/write:write-raw-message stream req)
                      (http/write:write-request stream req))
                  (force-output stream)
                  (http/read:read-response stream))
        (us:socket-close conn)))))

(in-package :http)

(defvar *capture* nil
  "Lexical capture stream for raw message.")

(defmacro with-capture (&body body)
  "Capture `*capture*` dynamic variable to string."
  `(with-output-to-string (capture)
     (let ((*capture* capture))
       ,@body)))

(defun read-status-line (stream)
  "Get multiple values of status line elements."
  (let ((line (chunga:read-line* stream)))
    (write-line-cr line *capture*)
    (apply #'values (mapcar #'str:trim (str:words line :limit 3)))))

(defun read-headers (stream)
  "Read headers into an alist of keywords to strings."
  (flet ((split-header (line)
           (let ((split (mapcar #'str:trim (str:split ":" line :limit 2))))
             (cons (make-keyword* (first split)) (second split)))))
    (loop :with headers := '()
          :for line := (chunga:read-line* stream)
          :do (write-line-cr line *capture*)
          :while (not (str:emptyp (str:trim line)))
          :do (push (split-header line) headers)
          :finally (return headers))))

(defun read-length (stream length)
  "Read HTTP bodies with `Content-Length` header."
  (with-output-to-string (capture)
    (dotimes (i length)
      (write-char* (chunga:read-char* stream) capture *capture*))))

(defun read-chunked (stream headers)
  "Read HTTP bodies with `Content-Encoding: chunked` header."
  (with-output-to-string (capture)
    (loop :for line := (chunga:read-line* stream)
          :for length := (parse-integer (str:trim line) :radix 16)
          :do (write-line* line capture *capture*)
          :do (let ((chunk (read-length stream length)))
                (ignore-errors
                  (write-string (decompress-string chunk headers) capture)))
          :do (write-line* (chunga:read-line* stream) capture *capture*)
          :while (not (= 0 length)))))

(defun read-body (stream headers)
  "Read HTTP body, checks headers to determine style."
  (let ((length (assoc-value headers :content-length))
        (t-encode (assoc-value headers :transfer-encoding)))
    (cond (length
           (decompress-string (read-length stream (parse-integer length)) headers))
          ((string-equal "chunked" t-encode)
           (read-chunked stream headers))
          (t ""))))

(defun read-request (stream &key host ssl-p)
  "Read HTTP request from binary stream."
  (let ((req (make-instance 'request)))
    (setf (request-ssl-p req) ssl-p
          (message-raw req)
          (with-capture
            (multiple-value-bind (method uri protocol) (read-status-line stream)
              (setf (request-method req) method
                    (request-uri req) (puri:parse-uri uri)
                    (request-protocol req) protocol))
            (let ((headers (read-headers stream)))
              (setf (message-headers req) headers
                    (message-body req) (read-body stream headers)
                    (request-host req) (or host (assoc-value headers :host))))))
    req))

(defun read-request-from-octets (octets &key host ssl-p)
  (let ((stream (flexi-streams:make-in-memory-input-stream octets)))
    (unwind-protect (read-request stream :host host :ssl-p ssl-p)
      (close stream))))

(defun read-request-from-string (string &key host ssl-p)
  (read-request-from-octets (flexi-streams:string-to-octets string)
                            :host host
                            :ssl-p ssl-p))

(defun read-response (stream)
  "Read HTTP response from binary stream."
  (let ((resp (make-instance 'response)))
    (setf (message-raw resp)
          (with-capture
            (multiple-value-bind (protocol code status) (read-status-line stream)
              (setf (response-protocol resp) protocol
                    (response-status-code resp) (parse-integer code)
                    (response-status resp) status))
            (let ((headers (read-headers stream)))
              (setf (message-headers resp) headers
                    (message-body resp) (read-body stream headers)))))
    resp))

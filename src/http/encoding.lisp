(in-package :http)

(defun read-encoding (string)
  (cond ((string= "gzip" string) 'chipz:gzip)
        ((string= "deflate" string) 'chipz:deflate)))

(defun decompress-string (string headers)
  (let ((encodings (str:words (assoc-value headers :content-encoding))))
    (flexi-streams:octets-to-string
     (reduce (lambda (acc encoding) (chipz:decompress nil encoding acc))
             (mapcar #'read-encoding encodings)
             :initial-value (flexi-streams:string-to-octets string)))))

(in-package :mx-proxy/lem)

(defmacro get-unique-buffer (name mode)
  `(let ((buffer (make-buffer ,name)))
     (unless (eq ,mode (buffer-major-mode buffer))
       (change-buffer-mode buffer ,mode))
     buffer))

(defun get-traffic-buffer ()
  (get-unique-buffer "*proxy-traffic*" 'proxy-mode))

(defun get-request-buffer ()
  (get-unique-buffer "*proxy-request*" 'proxy-request-mode))

(defun get-response-buffer ()
  (get-unique-buffer "*proxy-response*" 'proxy-response-mode))

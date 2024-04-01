(in-package :mx-proxy/lem)

(defparameter *button* nil)
(defparameter *reqs* '())
(defparameter *resps* '())
(defparameter *pairs* '())
(defvar *current-request* nil)
(defvar *current-response* nil)
(defvar *traffic-lock* (bt:make-lock))

(mx-proxy:register-hook (:on-message-pair :traffic) (mp)
  (bt:with-lock-held (*traffic-lock*)
    (push mp *pairs*)
    (render-traffic-list *pairs*)))

(defun clear-buffer (buffer)
  (delete-between-points
   (buffer-start-point buffer)
   (buffer-end-point buffer)))

(defun shitty-inspect-object (obj)
  (let ((buffer (make-buffer "*shitty-inspector*")))
    (clear-buffer buffer)
    (insert-string
     (buffer-start-point buffer)
     (with-output-to-string (*standard-output*) (describe obj)))
    (pop-to-buffer buffer)))

(defun inspect-response (resp &key (split-action :sensibly))
  (setf *current-response* resp)
  (let ((buffer (get-response-buffer)))
    (clear-buffer buffer)
    (insert-string (buffer-start-point buffer) (http:message-raw resp))
    (pop-to-buffer buffer :split-action split-action)))

(defun inspect-request (req &key (split-action :sensibly))
  (setf *current-request* req)
  (let ((buffer (get-request-buffer)))
    (clear-buffer buffer)
    (insert-string (buffer-start-point buffer) (http:message-raw req))
    (pop-to-buffer buffer :split-action split-action)))

(defun inspect-pair (pair)
  (let ((req (http:message-pair-request pair))
        (resp (http:message-pair-response pair)))
    (inspect-response resp :split-action :negative)
    (inspect-request req)))

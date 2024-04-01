(in-package :mx-proxy/lem)

(define-command start-proxy () ()
  (mx-proxy:start-server)
  (pop-to-buffer (get-traffic-buffer)))

(define-command rerender-traffic () ()
  (render-traffic-list *pairs*)
  (redraw-display))

(define-command press-current-button () ()
  (line-up-first
   (current-point)
   (lem/button:button-at)
   (lem/button::button-callback)
   (funcall)))

(define-command replay () ()
  (setf (http:message-raw *current-request*) (buffer-text (get-request-buffer)))
  (inspect-response
   (if-let ((host (http:request-host *current-request*)))
     (mx-proxy:send-request-ssl *current-request* :raw t :host host)
     (http:send-request *current-request* :raw t)))
  (message "Replayed"))

(define-command request-ir () ()
  (shitty-inspect-object *current-request*))

(define-command response-ir () ()
  (shitty-inspect-object *current-response*))

(define-keys *proxy-mode-keymap*
  ("Return" 'press-current-button))
(define-keys *proxy-request-mode-keymap*
  ("C-c C-r" 'replay)
  ("C-c C-i" 'request-ir))
(define-keys *proxy-response-mode-keymap*
  ("C-c C-i" 'response-ir))
(define-keys *global-keymap*
  ("Return" 'press-current-button))
(define-keys lem-vi-mode:*normal-keymap*
  ("Return" 'press-current-button))

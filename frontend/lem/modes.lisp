(in-package :mx-proxy/lem)

(define-major-mode proxy-mode ()
    (:name "Proxy"
     :keymap *proxy-mode-keymap*))

(define-major-mode proxy-request-mode proxy-mode
    (:name "Request"
     :keymap *proxy-request-mode-keymap*))

(define-major-mode proxy-response-mode proxy-mode
    (:name "Response"
     :keymap *proxy-response-mode-keymap*))

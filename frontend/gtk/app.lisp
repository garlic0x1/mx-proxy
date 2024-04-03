(in-package :mx-proxy/gtk)

(define-application (:name main :id "garlic0x1.mx-proxy.main-window")
  (define-main-window (w (make-application-window :application *application*))
    (mx-proxy:connect-database)
    (setf (window-child w)
          (gobject (make-instance 'traffic)))
    ;; (setf
    ;;  (window-child w)
    ;;  (gobject (make-instance 'message-pair
    ;;                          :value (nth 4 (mito:select-dao 'http:message-pair)))))
    ;; (setf (window-child w)
    ;;       (gobject (make-instance 'gtk-widgets::settings)))
    ;; (let ((insp (make-instance 'inspector :value '(:hi :world))))
    ;;   (setf (window-child w) (widget insp)))
    (unless (widget-visible-p w)
      (window-present w))))

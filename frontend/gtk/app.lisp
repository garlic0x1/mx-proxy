(in-package :mx-proxy/gtk)

(defparameter mx-proxy:*interface* :gtk)

(defvar *top-grid* nil)
(defvar *top-window* nil)

(define-application (:name main :id "garlic0x1.mx-proxy.main-window")
  (define-main-window (w (make-application-window :application *application*))
    (mx-proxy:connect-database)
    (let* ((grid (make-grid))
           (traffic (make-instance 'traffic)))

      (grid-attach grid (gobject traffic) 0 0 1 1)

      (setf (window-child w) grid
            *top-grid* grid
            *top-window* w)

      (let ((controller (make-event-controller-key)))
        (connect controller "key-pressed"
                 (lambda (widget kval kcode state)
                   (declare (ignore widget kcode))
                   (if (and (= 8 state)
                            (= (char-code #\x) kval))
                       (mx-proxy:prompt-for-command
                        #'mx-proxy:call-with-prompts)
                       (values gdk4:+event-propagate+))))
        (widget-add-controller w controller)))

    (unless (widget-visible-p w)
      (window-present w))))

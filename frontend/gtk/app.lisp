(in-package :mx-proxy/gtk)

(defparameter *interface* :gtk)

(defvar *top-grid* nil)
(defvar *top-window* nil)
(defvar *top-modeline* nil)
(defvar *in-prompt* nil)

(define-application (:name test-widget :id "garlic0x1.mx-proxy.test-window")
  (define-main-window (w (make-application-window :application *application*))
    (let* ((string-table (make-instance 'traffic-list)))
      (traffic-list-append string-table (mito:select-dao 'http:message-pair))
      (setf (window-child w) (gobject string-table)))
    (unless (widget-visible-p w)
      (window-present w))))

(define-application (:name main :id "garlic0x1.mx-proxy.main-window")
  (define-main-window (w (make-application-window :application *application*))
    (mx-proxy:connect-database)
    (let* ((grid (make-grid))
           (modeline (make-instance 'modeline))
           (traffic (make-instance 'traffic))
           ;; (traffic-list (make-instance 'traffic-list))
           )

      (grid-attach grid (gobject traffic) 0 0 1 1)
      (grid-attach grid (gobject modeline) 0 3 1 1)

      (setf (window-child w) grid
            *top-modeline* modeline
            *top-grid* grid
            *top-window* w)

      (setf (modeline :project) mx-proxy:*db-file*
            (modeline :server) http:*host*)

      (let ((controller (make-event-controller-key)))
        (connect controller "key-pressed"
                 (lambda (widget kval kcode state)
                   (declare (ignore widget kcode))
                   (if (and (= 8 state)
                            (= (char-code #\x) kval))
                       (unless *in-prompt*
                         (prompt-for-command
                          #'call-with-prompts))
                       (values gdk4:+event-propagate+))))
        (widget-add-controller w controller))

      ;; load preferred theme on startup
      (connect w "show"
               (lambda (&rest rest)
                 (declare (ignore rest))
                 (prefer-dark-theme (string-equal :dark (mx-proxy:config :theme))))))

    (unless (widget-visible-p w)
      (window-present w))))

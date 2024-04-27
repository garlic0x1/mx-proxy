(in-package :mx-proxy/gtk)

(defparameter *interface* :gtk)

(defvar *top-grid* nil)
(defvar *top-notebook* nil)
(defvar *top-window* nil)
(defvar *top-modeline* nil)
(defvar *top-messages* nil)
(defvar *in-prompt* nil)

(define-application (:name test-widget :id "garlic0x1.mx-proxy.test-window")
  (define-main-window (w (make-application-window :application *application*))
    (let* ((string-table (make-instance 'traffic-list :contents (mito:select-dao 'http:message-pair))))
      (setf (window-child w) (gobject string-table)))
    (unless (widget-visible-p w)
      (window-present w))))

(define-application (:name main :id "garlic0x1.mx-proxy.main-window")
  (define-main-window (w (make-application-window :application *application*))
    (mx-proxy:connect-database)
    (let* ((grid (make-grid))
           (notebook (make-notebook))
           (modeline (make-instance 'modeline))
           (traffic-view (make-instance 'traffic))
           (repl-view (make-instance 'repl))
           (messages-view (make-instance 'string-list* :spearator-p t)))

      (notebook-append-page notebook
                            (gobject traffic-view)
                            (make-label :str "Traffic"))
      (notebook-append-page notebook
                            (gobject repl-view)
                            (make-label :str "REPL"))
      (notebook-append-page notebook
                            (gobject messages-view)
                            (make-label :str "Messages"))

      (grid-attach grid notebook 0 0 1 1)
      (grid-attach grid (gobject modeline) 0 3 1 1)

      (setf (window-child w) grid
            (widget-hexpand-p grid) t
            (widget-hexpand-p notebook) t
            *top-notebook* notebook
            *top-modeline* modeline
            *top-messages* messages-view
            *top-grid* grid
            *top-window* w)

      (set-default-modeline)

      (let ((controller (make-event-controller-key)))
        (connect controller "key-pressed"
                 (lambda (widget kval kcode state)
                   (declare (ignore widget))
                   ;; (format t "state: ~a, kval: ~a, kcode: ~a~%" state kval kcode)
                   (cond ((and (= 8 state) (= (char-code #\x) kval))
                          (unless *in-prompt*
                            (prompt-for-command #'call-with-prompts)))
                         ((and (= 8 state) (or (= 116 kcode) (= 114 kcode)))
                          (notebook-next-page *top-notebook*))
                         ((and (= 8 state) (or (= 111 kcode) (= 113 kcode)))
                          (notebook-prev-page *top-notebook*))
                         (t (values gdk4:+event-propagate+)))))
        (widget-add-controller w controller))

      ;; load preferred theme on startup
      (connect w "show"
               (lambda (&rest rest)
                 (declare (ignore rest))
                 (prefer-dark-theme (string-equal :dark (mx-proxy:config :theme))))))

    (unless (widget-visible-p w)
      (window-present w))))

(define-command toggle-tab-pos () ()
  (setf (notebook-tab-pos *top-notebook*)
        (cond ((= 2 (notebook-tab-pos *top-notebook*)) 0)
              ((= 0 (notebook-tab-pos *top-notebook*)) 2))))

(in-package :gtk-widgets)

(defvar +token-separators+
  '(#\  #\tab #\newline #\( #\) #\' #\"))

(defun read-token-from-string (string)
  (let ((token ""))
    (loop :for c :across string
          :until (find c +token-separators+)
          :do (setf token (format nil "~a~a" token c)))
    token))

(defun entry-replace-selected-token (self string)
  (let* ((buf (entry-buffer self))
         (ind (editable-position self))
         (start (subseq (entry-buffer-text buf) 0 ind))
         (rev-start (reverse start))
         (rev-str (read-token-from-string rev-start))
         (tok-len (length rev-str)))
    (setf (entry-buffer-text buf)
          (uiop:strcat
           (subseq (entry-buffer-text buf) 0 (- ind tok-len))
           string
           (subseq (entry-buffer-text buf) ind (length (entry-buffer-text buf))))
          )))

(defun entry-completions (self &key (limit 32) (package :cl-user))
  (handler-case
      (let* ((buf (entry-buffer self))
             (ind (editable-position self))
             (start (subseq (entry-buffer-text buf) 0 ind))
             (rev-start (reverse start))
             (rev-str (read-token-from-string rev-start))
             (str (reverse rev-str)))
        (if (string-equal "" str)
            '()
            (let ((completions (car (micros:simple-completions str package))))
              (subseq completions 0 (min limit (length completions))))))
    (error (c) (print c) nil)))

(defclass lisp-entry (widget)
  ((value
    :initarg :value
    :initform ""
    :accessor value)
   (entry
    :accessor lisp-entry-entry)
   (activate
    :initarg :activate
    :initform (lambda (self)
                (declare (ignore self))
                (warn "No activate callback."))
    :accessor lisp-entry-activate)))

(defmethod initialize-instance :after ((self lisp-entry) &key &allow-other-keys)
  (let* ((box (make-box :orientation +orientation-vertical+ :spacing 0))
         (entry-box (make-box :orientation +orientation-horizontal+ :spacing 0))
         (entry (make-entry))
         (entry-button (make-button :label "Eval"))
         (scroll (make-scrolled-window))
         (completions (make-instance 'string-list*)))

    (box-append entry-box entry)
    (box-append entry-box entry-button)
    (box-append box entry-box)
    (box-append box scroll)

    (connect entry "changed"
             (lambda (entry)
               (setf (value self) (entry-buffer-text (entry-buffer entry)))
               (string-list*-clear completions)
               (let ((new-cmps (entry-completions entry)))
                 (string-list*-append completions new-cmps)
                 (if new-cmps
                     (widget-show (gobject completions))
                     (widget-hide (gobject completions))))))

    (connect entry "activate"
             (lambda (entry)
               (declare (ignore entry))
               (widget-hide (gobject completions))
               (funcall (lisp-entry-activate self) self)))

    (connect entry-button "clicked"
             (lambda (button)
               (declare (ignore button))
               (widget-hide (gobject completions))
               (funcall (lisp-entry-activate self) self)))

    (let ((controller (make-event-controller-key)))
      (connect controller "key-pressed"
               (lambda (widget kval kcode state)
                 (declare (ignore widget kcode state))
                 (cond ((= kval gdk4:+key-tab+)
                        (alexandria:when-let ((new (string-list-get-string
                                                    (internal completions) 0)))
                          (entry-replace-selected-token entry new)
                          (lisp-entry-grab-focus self)
                          t))
                       (t gdk4:+event-propagate+))))
      (widget-add-controller entry controller))


    (setf (gobject self) box
          (scrolled-window-child scroll) (gobject completions)
          (widget-hexpand-p (gobject completions)) t
          (widget-hexpand-p entry-box) t
          (widget-hexpand-p entry) t
          (widget-hexpand-p box) t
          (lisp-entry-entry self) entry)))

(defun lisp-entry-grab-focus (self)
  (let ((entry (lisp-entry-entry self)))
    (widget-grab-focus entry)
    (setf (editable-position entry) -1)))

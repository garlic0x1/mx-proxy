(in-package :gtk-widgets)

(defclass prompt (widget)
  ((value
    :initarg :start
    :initform ""
    :accessor value)
   (message
    :initarg :message
    :initform "Prompt"
    :accessor message)
   (completion
    :initarg :completion
    :initform #'list
    :accessor completion)
   (validation
    :initarg :validation
    :initform (constantly t)
    :accessor validation)
   (callback
    :initarg :callback
    :initform (lambda (str) (declare (ignore str)) (warn "No callback."))
    :accessor callback)
   (cancel-callback
    :initarg :cancel-callback
    :initform (lambda () (warn "No callback."))
    :accessor cancel-callback)
   (entry-widget
    :accessor entry-widget)))

(defmethod initialize-instance :after ((self prompt) &key &allow-other-keys)
  (let* ((box (make-box :orientation +orientation-vertical+ :spacing 0))
         (bottom (make-box :orientation +orientation-horizontal+ :spacing 0))
         (label (make-label :str (message self)))
         (string-list (make-instance 'string-list*
                                     :strings (funcall (completion self)
                                                       (value self))))
         (entry (make-entry))
         (ok-button (make-button :label "Okay"))
         (cancel-button (make-button :label "Cancel")))
    (setf (entry-buffer-text (entry-buffer entry)) (value self)
          (widget-hexpand-p entry) t
          (widget-margin-all label) 4
          (label-markup label) (format nil "<big>~a</big>" (message self))
          (widget-size-request box) '(0 128)
          (gobject self) box
          (widget-focusable-p entry) t
          (entry-widget self) entry)
    (box-append box label)
    (box-append box (gobject string-list))
    (box-append bottom entry)
    (box-append bottom ok-button)
    (box-append bottom cancel-button)
    (box-append box bottom)
    (connect ok-button "clicked"
             (lambda (button)
               (declare (ignore button))
               (when (funcall (validation self) (value self))
                 (funcall (callback self) (value self)))))
    (connect cancel-button "clicked"
             (lambda (button)
               (declare (ignore button))
               (funcall (cancel-callback self))))
    (connect entry "changed"
             (lambda (entry)
               (setf (value self) (entry-buffer-text (entry-buffer entry)))
               (string-list*-clear string-list)
               (let ((new-list (funcall (completion self) (value self))))
                 (string-list*-append string-list new-list))))
    (connect entry "activate"
             (lambda (entry)
               (declare (ignore entry))
               (when (funcall (validation self) (value self))
                 (funcall (callback self) (value self)))))
    (let ((controller (make-event-controller-key)))
      (connect controller "key-pressed"
               (lambda (widget kval kcode state)
                 (declare (ignore widget kcode state))
                 (cond ((= kval gdk4:+key-escape+)
                        (funcall (cancel-callback self)))
                       (t gdk4:+event-propagate+))))
      (widget-add-controller entry controller))
    (let ((controller (make-event-controller-key)))
      (connect controller "key-pressed"
               (lambda (widget kval kcode state)
                 (declare (ignore widget kcode state))
                 (cond ((= kval gdk4:+key-tab+)
                        (alexandria:when-let ((new (string-list-get-string
                                                    (internal string-list) 0)))
                          (setf (entry-buffer-text (entry-buffer entry)) new
                                (value self) new)
                          (prompt-grab-focus self)
                          t))
                       (t gdk4:+event-propagate+))))
      (widget-add-controller entry controller))))

(defun prompt-grab-focus (widget)
  (let ((entry (entry-widget widget)))
    (widget-grab-focus entry)
    (setf (editable-position entry) -1)))

(in-package :mx-proxy/qt)
(in-readtable :qtools)

(define-widget prompt-entry (QLineEdit) ())

(define-signal (prompt-entry entry-changed) ())
(define-signal (prompt-entry return-pressed) ())
(define-signal (prompt-entry tab-pressed) ())

(define-override (prompt-entry focus-out-event) (ev)
  ;; (q+:set-focus prompt-entry)
  (signal! prompt-entry (tab-pressed)))

(define-override (prompt-entry key-press-event) (ev)
  (flet ((submit-event-p (ev)
           (or (= (q+:key ev) (q+:qt.key_enter))
               (= (q+:key ev) (q+:qt.key_return)))))
    (cond ((submit-event-p ev)
           (signal! prompt-entry (return-pressed)))
          (t
           (call-next-qmethod)
           (signal! prompt-entry (entry-changed))))))

(define-widget prompt (QWidget)
  ((message
    :initarg :message
    :initform nil
    :accessor message)
   (completion
    :initarg :completion
    :initform #'list
    :accessor completion-fn)
   (entry
    :initarg :init-entry
    :initform ""
    :accessor entry)
   (callback
    :initarg :callback
    :initform (lambda (x) (declare (ignore x)) (warn "No callback."))
    :accessor callback)))

(define-subwidget (prompt completion-list) (q+:make-qlistwidget prompt)
  (loop :for it :in (funcall (completion-fn prompt) (entry prompt))
        :do (q+:add-item completion-list it)))

(define-subwidget (prompt entry-field) (make-instance 'prompt-entry)
  (setf (q+:text entry-field) (entry prompt)))

(define-subwidget (prompt message-field) (q+:make-qlabel prompt)
  (when (message prompt)
    (setf (q+:text message-field) (message prompt))))

(define-subwidget (prompt layout) (q+:make-qvboxlayout prompt)
  (when (message prompt)
    (q+:add-widget layout message-field))
  (q+:add-widget layout completion-list)
  (q+:add-widget layout entry-field))

(define-initializer (prompt setup)
  (q+:set-focus entry-field))

(define-slot (prompt enter) ()
  (declare (connected entry-field (return-pressed)))
  (when (callback prompt)
    (funcall (callback prompt) (entry prompt))))

(defun next-trie (listwidget)
  (str:common-prefix
   (loop :for i :from 0 :to (1- (q+:count listwidget))
         :collect (q+:text (q+:item listwidget i)))))

(define-slot (prompt completion-event) ()
  (declare (connected entry-field (tab-pressed)))
  (setf (q+:text entry-field) (next-trie completion-list))
  (signal! entry-field (entry-changed)))

(define-slot (prompt update-completion) ()
  (declare (connected entry-field (entry-changed)))
  (q+:clear completion-list)
  (setf (entry prompt) (q+:text entry-field))
  (loop :for it :in (funcall (completion-fn prompt) (q+:text entry-field))
        :do (q+:add-item completion-list it)))

(defun prompt-for-string (callback &key message (completion 'list))
  (let ((widget nil))
    (setf widget (make-instance 'prompt
                                :message message
                                :completion completion
                                :callback (lambda (value)
                                            (funcall callback value)
                                            (q+:close widget))))
    (q+:add-widget *main-layout* widget 2 0)))

(defun prompt-for-integer (callback &key message completion)
  (let ((widget nil))
    (setf widget (make-instance 'prompt
                                :message message
                                :completion completion
                                :callback
                                (lambda (value)
                                  (when-let ((num (ignore-errors
                                                    (parse-integer value))))
                                    (funcall callback value)
                                    (q+:close widget)))))
    (q+:add-widget *main-layout* widget 2 0)))

(defun prompt-for-spec (callback spec)
  "Lem style prompt spec, with type as the first char
and message as the rest of the string. ex: \"fFile prompt\" \"sString prompt\""
  (funcall (case (elt spec 0)
             (#\i 'prompt-for-integer)
             (#\s 'prompt-for-string)
             ;; (#\f 'prompt-for-file)
             )
           callback
           :message (subseq spec 1)))

(defun prompt-for-specs (callback prompts)
  "Lem style prompt specs. ex: '(\"fSelect file\" \"iInt prompt\"). "
  (if (car prompts)
      (prompt-for-spec
       (lambda (value) (prompt-for-specs (curry callback value) (cdr prompts)))
       (car prompts))
      (funcall callback)))

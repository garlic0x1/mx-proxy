(in-package :ng-widgets)

(defun fuzzy-match-p (str elt &optional ignore-case)
  (loop :with start := 0
        :for c :across str
        :do (let ((pos (position c elt :start start :test (if ignore-case #'char-equal #'char=))))
              (if pos
                  (setf start pos)
                  (return nil)))
        :finally (return t)))

(defun completion (selection &key (test #'fuzzy-match-p))
  (lambda (str)
    (remove-if-not
     (curry test str)
     selection)))

(defwidget prompt (frame)
  ((message
    :initarg :message
    :initform nil
    :accessor prompt-message)
   (value
    :initarg :value
    :initform ""
    :accessor prompt-value)
   (command
    :initarg :command
    :initform nil
    :accessor prompt-command)
   (completion
    :initarg :completion
    :initform (lambda (val) (list val))
    :accessor prompt-completion))
  ((label label
          :grid '(0 0 :sticky :nsew :columnspan 3))
   (listbox listbox
            :grid '(1 0 :sticky :nsew :columnspan 3))
   (entry entry
          :grid '(2 0 :sticky :nsew)
          :text (prompt-value self))
   (cancel-button button
                  :grid '(2 2 :sticky :nsew)
                  :text "Cancel"
                  :command (lambda () (destroy self)))
   (ok-button button
              :grid '(2 1 :sticky :nsew)
              :text "Ok"
              :command (lambda () (funcall (prompt-command self) (prompt-value self)))))

  (if-let (msg (prompt-message self))
    (setf (text (label self)) msg)
    (grid-forget (label self)))

  (grid-rowconfigure self 0 :minsize 12)
  (grid-rowconfigure self 1 :weight 1)
  (grid-rowconfigure self 2 :minsize 32)
  (grid-columnconfigure self 0 :weight 2)
  (grid-columnconfigure self 1 :minsize 64)
  (grid-columnconfigure self 2 :minsize 64)

  (prompt-update-list self)
  (focus (entry self))

  (setf (command (listbox self))
        (lambda (indices)
          (when-let ((index (car indices)))
            (let ((value (nth index
                              (listbox-all-values
                               (listbox self)))))
              (prompt-swap self value)))))

  (bind entry "<Escape>"
    (lambda (e)
      (declare (ignore e))
      (destroy self)))

  (bind entry "<Tab>"
    (lambda (e)
      (declare (ignore e))
      (when-let ((item (car (listbox-all-values (listbox self)))))
        (prompt-swap self item))
      (focus (entry self))
      (set-cursor-index (entry self) :end)))

  (bind entry "<Return>"
    (lambda (e)
      (declare (ignore e))
      (funcall (prompt-command self) (prompt-value self))))

  (bind entry "<Key>"
    (lambda (e)
      (declare (ignore e))
      (prompt-swap self (text (entry self))))))

(defun prompt-swap (self value)
  (setf (prompt-value self) value
        (text (entry self)) value)
  (prompt-update-list self))

(defun prompt-update-list (self)
  (listbox-delete (listbox self) 0 (listbox-size (listbox self)))
  (listbox-insert (listbox self)
                  0
                  (funcall (prompt-completion self)
                           (text (entry self))))
  (set-cursor-index (entry self) :end)
  )

(defwidget file-prompt (prompt)
  ((path
    :initarg :value
    :initform (namestring (user-homedir-pathname))
    :accessor file-prompt-path))
  ()

  (setf (prompt-completion self)
        (lambda (path)
          (let ((dir (namestring (uiop:pathname-directory-pathname path))))
            (remove-if-not (curry #'str:starts-with-p path)
                           (mapcar #'namestring
                                   (append (uiop:subdirectories dir)
                                           (uiop:directory-files dir)))))))

  (prompt-swap self (file-prompt-path self))

  (bind (entry self) "<BackSpace>"
    (lambda (e)
      (declare (ignore e))
      (let* ((path (prompt-value self))
             (dir (namestring
                   (uiop:pathname-directory-pathname
                    (if (str:ends-with-p "/" path)
                        (str:substring 0 (1- (length path)) path)
                        path)))))
        (prompt-swap self dir)))))

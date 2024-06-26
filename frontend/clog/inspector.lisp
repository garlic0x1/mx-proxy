(in-package :mx-proxy/clog)

(defvar *capture*)

(defun create-primitive-inspector (obj value callback)
  (declare (ignore callback))
  (let ((obj (create-div obj)))
    (let ((str (with-output-to-string (*capture*) (describe value *capture*))))
      (create-description obj :content str)
      (create-div obj :content (hiccl:render nil (format nil "~a" value))))
    obj))

(defun create-condition-inspector (obj value callback)
  (declare (ignore callback))
  (let ((obj (create-div obj)))
    (let ((str (with-output-to-string (*capture*) (describe value *capture*)))
          (trace (with-output-to-string (*capture*)
                   (uiop:print-backtrace :condition value
                                         :stream *capture*))))
      (create-description obj :content str)
      (loop :for frame :in (str:lines trace)
            :do (create-div obj :content (hiccl:render nil frame))))
    obj))

(defun create-list-inspector (obj value callback)
  (let ((obj (create-div obj)))
    (create-primitive-inspector obj value callback)
    (create-br obj)
    (let ((ul (create-unordered-list obj :class "w3-ul w3-hoverable")))
      (dolist (it value)
        (let ((li (create-list-item ul :content (hiccl:render nil (format nil "~a" it)))))
          (on (click li) (funcall callback it))
          (on (mouse-right-click li) (create-inspector-window it)))))
    obj))

(defun create-vector-inspector (obj value callback)
  (let ((obj (create-div obj)))
    (create-primitive-inspector obj value callback)
    (create-br obj)
    (let* ((table (create-table obj :class *table-class*))
           (tbody (create-table-body table)))
      (loop :with i := 0
            :for x :across value
            :for row := (create-table-row tbody)
            :do (create-table-column row :content (hiccl:render nil (format nil "~a" i)))
            :do (create-table-column row :content (hiccl:render nil (format nil "~a" x)))
            :do (on (click row) (funcall callback x))
            :do (on (mouse-right-click row) (create-inspector-window x))))
    obj))

(defun create-object-inspector (obj value callback)
  (let ((obj (create-div obj)))
    (create-primitive-inspector obj value callback)
    (create-br obj)
    (let* ((table (create-table obj :class *table-class*))
           (tbody (create-table-body table)))
      (dolist (it (slots-alist value))
        (destructuring-bind (k . v) it
          (let ((row (create-table-row tbody)))
            (create-table-column row :content (hiccl:render nil (format nil "~a" k)))
            (create-table-column row :content (hiccl:render nil (format nil "~a" v)))
            (on (click row) (funcall callback v))
            (on (mouse-right-click row) (create-inspector-window it))))))
    obj))

(defgeneric create-inspector-view (obj value callback)
  (:method (obj (value t) callback)
    (create-primitive-inspector obj value callback))
  (:method (obj (value condition) callback)
    (create-condition-inspector obj value callback))
  (:method (obj (value standard-object) callback)
    (create-object-inspector obj value callback))
  (:method (obj (value structure-object) callback)
    (create-object-inspector obj value callback))
  (:method (obj (value list) callback)
    (create-list-inspector obj value callback))
  (:method (obj (value vector) callback)
    (create-vector-inspector obj value callback))
  (:method (obj (value string) callback)
    (create-primitive-inspector obj value callback)))

(defun create-cookies (obj stack)
  (let ((str (a:line-up-last
              (mapcar #'class-of-simple stack)
              (mapcar (lambda (sym) (format nil "~a" sym)))
              (reverse)
              (str:join " > "))))
    (create-label obj :content str :style "color:white")))

(defun create-inspector-window (value)
  (let* ((win (create-gui-window* *window* :title "Inspector"))
         (menu (create-div (window-content win) :style "background:black;height:40px"))
         (pop-button (create-div menu))
         (cookies (create-div (window-content win) :hidden t))
         (view (create-div (window-content win) :hidden t))
         (stack (list value))
         (push-cb)
         (pop-cb))
    (flet ((update-menu ()
             (destroy cookies)
             (setf cookies (create-cookies menu stack))
             (destroy pop-button)
             (setf pop-button
                   (if (< 1 (length stack))
                       (create-button menu
                                      :content "Pop"
                                      :style "position:absolute;right:0;top:0"
                                      :class "w3-button w3-blue")
                       (create-div menu :hidden t)))
             (on (click pop-button) (funcall pop-cb)))
           (update-view ()
             (if:message stack)
             (destroy view)
             (setf view (create-inspector-view (window-content win)
                                               (car stack)
                                               push-cb))))
      (flet ((pop-inspector ()
               (when (< 1 (length stack))
                 (setf stack (cdr stack))
                 (update-menu)
                 (update-view)))
             (push-inspector (value)
               (if:message "pushing")
               (if:message value)
               (push value stack)
               (update-menu)
               (update-view)))
        (setf push-cb #'push-inspector
              pop-cb #'pop-inspector)
        (update-menu)
        (update-view)
        win))))

(if:define-command div-by-zero () ()
  (if:with-log-errors (error "hi")))

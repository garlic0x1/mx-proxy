(in-package :mx-proxy/clog)

(defvar *capture*)

(defmethod make-inspector-window ((value t))
  (let ((win (create-gui-window* *window* :title "Inspector")))
    (create-element (window-content win) :p
                    :content (with-output-to-string (*capture*)
                               (describe value *capture*)))))

(defmethod make-inspector-window ((value list))
  (let ((win (create-gui-window* *window* :title "Inspector")))
    (create-element (window-content win) :p
                    :content (with-output-to-string (*capture*)
                               (describe value *capture*)))
    (create-br (window-content win))
    (let ((ul (create-unordered-list (window-content win) :class "w3-ul w3-hoverable")))
      (dolist (it value)
        (let ((li (create-list-item ul :content (format nil "~a" it))))
          (on (click li)
            (make-inspector-window it)))))))

(defmethod make-inspector-window ((value vector))
  (let ((win (create-gui-window* *window* :title "Inspector")))
    (create-element (window-content win) :p
                    :content (with-output-to-string (*capture*)
                               (describe value *capture*)))
    (create-br (window-content win))
    (let* ((table (create-table (window-content win) :class "w3-table w3-striped w3-bordered w3-border w3-hoverable"))
           (tbody (create-table-body table)))
      (loop :with i := 0
            :for x :across value
            :for row := (create-table-row tbody)
            :do (create-table-column row :content (format nil "~a" i))
            :do (create-table-column row :content (format nil "~a" x))
            :do (on (click row) (make-inspector-window x))))))

(defmethod make-inspector-window ((value standard-object))
  (make-inspector-window-class value))

(defmethod make-inspector-window ((value structure-object))
  (make-inspector-window-class value))

(defmethod make-inspector-window-class (value)
  (let ((win (create-gui-window* *window* :title "Inspector")))
    (create-element (window-content win) :p
                    :content (with-output-to-string (*capture*)
                               (describe value *capture*)))
    (create-br (window-content win))
    (let* ((table (create-table (window-content win) :class "w3-table w3-striped w3-bordered w3-border w3-hoverable"))
           (tbody (create-table-body table)))
      (dolist (it (slots-alist value))
        (destructuring-bind (k . v) it
          (let ((row (create-table-row tbody)))
            (create-table-column row :content (format nil "~a" k))
            (create-table-column row :content (format nil "~a" v))
            (on (click row) (make-inspector-window v))))))))

(if:define-command inspect-obj () ()
  (make-inspector-window (make-instance 'http:request)))

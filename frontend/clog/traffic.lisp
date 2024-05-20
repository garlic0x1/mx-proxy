(in-package :mx-proxy/clog)

(defun make-traffic-item (mp)
  (let ((req (http:message-pair-request mp))
        (resp (http:message-pair-response mp)))
    (hiccl:render nil
      `(:div :style ":hover {background: \"yellow\"}"
        (:span ,(http:request-method req))
        (:span ,(puri:render-uri (http:request-uri req) nil))
        (:span ,(http:response-status-code resp))))))

(defun push-traffic-item (win mp)
  (let ((child (create-div (window-content win) :content (make-traffic-item mp))))
    (on (click child) (create-inspector-window mp))
    child))

(defun create-table* (obj)
  (create-table obj :class *table-class*))

(defun create-traffic-headers (table)
  (let ((row (create-table-row table :class "w3-light-grey")))
    (create-table-heading row :content "Method")
    (create-table-heading row :content "URI")
    (create-table-heading row :content "Status")
    row))

(defun create-traffic-row (table mp)
  (let ((row (create-table-row table))
        (req (http:message-pair-request mp))
        (resp (http:message-pair-response mp)))
    (create-table-column row :content (http:request-method req))
    (create-table-column row :content (puri:render-uri (http:request-uri req) nil))
    (create-table-column row :content (http:response-status-code resp))
    (on (click row) (create-message-pair-window mp))
    row))

(defun create-traffic-window* (title pred obj)
  (let* ((win (create-gui-window* obj :title title))
         (table (create-table* (window-content win))))
    (create-traffic-headers table)
    (dolist (mp (mito:select-dao 'http:message-pair))
      (when (funcall pred mp)
        (create-traffic-row table mp)))
    win))

(defmethod create-traffic-window ((group (eql :all)) obj)
  (create-traffic-window*
   "All Traffic"
   (constantly t)
   obj))

(defmethod create-traffic-window ((group (eql :browser)) obj)
  (create-traffic-window*
   "Browser Traffic"
   (lambda (mp) (assoc :normal (http:message-pair-metadata mp)))
   obj))

(defmethod create-traffic-window ((group (eql :repeater)) obj)
  (create-traffic-window*
   "Repeater Traffic"
   (lambda (mp) (assoc :repeater (http:message-pair-metadata mp)))
   obj))

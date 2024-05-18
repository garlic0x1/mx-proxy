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
    (set-on-click child
                  (lambda (obj)
                    (declare (ignore obj))
                    (make-message-pair-window mp win)))))

(defun make-table (obj)
  (create-table obj :class "w3-table w3-striped w3-bordered w3-border w3-hoverable"))

(defun make-traffic-headers (table)
  (let ((row (create-table-row table :class "w3-light-grey")))
    (create-table-heading row :content "Method")
    (create-table-heading row :content "URI")
    (create-table-heading row :content "Status")))

(defun make-traffic-row (table mp)
  (let ((row (create-table-row table))
        (req (http:message-pair-request mp))
        (resp (http:message-pair-response mp)))
    (create-table-column row :content (http:request-method req))
    (create-table-column row :content (puri:render-uri (http:request-uri req) nil))
    (create-table-column row :content (http:response-status-code resp))
    (on (click row)
      (make-message-pair-window mp *window*))))

(defun make-traffic-window* (title pred obj)
  (let* ((win (create-gui-window obj :title title))
         (table (make-table (window-content win))))
    (make-traffic-headers table)
    (dolist (mp (mito:select-dao 'http:message-pair))
      (when (funcall pred mp)
        (make-traffic-row table mp)))))

(defmethod make-traffic-window ((group (eql :all)) obj)
  (make-traffic-window*
   "All Traffic"
   (constantly t)
   obj))

(defmethod make-traffic-window ((group (eql :browser)) obj)
  (make-traffic-window*
   "Browser Traffic"
   (lambda (mp) (assoc :normal (http:message-pair-metadata mp)))
   obj))

(defmethod make-traffic-window ((group (eql :repeater)) obj)
  (make-traffic-window*
   "Repeater Traffic"
   (lambda (mp) (assoc :repeater (http:message-pair-metadata mp)))
   obj))

(in-package :mx-proxy/clog)

(defun create-table* (obj)
  (create-table obj :class *table-class*))

(defun create-traffic-headers (table)
  (let* ((thead (create-table-head table))
         (row (create-table-row thead :class "w3-light-grey")))
    (create-table-heading row :content "Method")
    (create-table-heading row :content "URI")
    (create-table-heading row :content "Status")
    row))

(defun create-traffic-row (table mp)
  (let ((row (create-table-row table :auto-place :top))
        (req (http:message-pair-request mp))
        (resp (http:message-pair-response mp)))
    (create-table-column row :content (http:request-method req))
    (create-table-column row :content (puri:render-uri (http:request-uri req) nil))
    (create-table-column row :content (http:response-status-code resp))
    (on (click row) (create-repeater-window mp))
    (on (mouse-right-click row)
      (if:message *ev*)
      (let* ((menu (create-context-menu :x (getf *ev* :page-x)
                                        :y (getf *ev* :page-y)))
             (ul (create-unordered-list menu :class *list-class*)))
        (on (click (create-list-item ul :content "Repeater"))
          (destroy menu)
          (create-repeater-window mp))
        (on (click (create-list-item ul :content "Inspect"))
          (destroy menu)
          (create-inspector-window mp))))
    row))

(defun create-traffic-window* (title pred obj)
  (let* ((win (create-gui-window* obj :title title))
         (table (create-table* (window-content win)))
         (tbody (create-table-body table)))
    (create-traffic-headers table)
    (mxp/if:register-hook (:on-message-pair :traffic) (mp)
      (create-traffic-row tbody mp))
    (dolist (mp (mito:select-dao 'http:message-pair))
      (when (funcall pred mp)
        (create-traffic-row tbody mp)))
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

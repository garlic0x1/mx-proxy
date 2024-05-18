(in-package :mx-proxy/clog)

(defvar *logs-window* nil)

(defstruct log-item time value)

(defun pretty-time (time)
  (multiple-value-bind (s m h) (decode-universal-time time)
    (format nil "~a:~a:~a" h m s)))

(defun log-item-render (log-item)
  (hiccl:render nil
    `(:div.w3-border
      :style "text-wrap:no-wrap"
      (:span ,(log-item-time log-item))
      (:span ,(log-item-value log-item)))))

(if:define-command clear-logs (&optional obj) ()
  (declare (ignore obj))
  (setf *messages* nil)
  (if:run-hook :clear-messages))

(defun make-log-row (messages msg)
  (let ((row (create-table-row messages))
        (time (pretty-time (log-item-time msg)))
        (value (log-item-value msg)))
    (create-table-column row :content time)
    (create-table-column row :content value :style "text-wrap:nowrap")
    (on (click row)
      (make-inspector-window value))))

(defun make-log-headers (table)
  (let* ((head (create-table-head table))
         (row (create-table-row head :class "w3-light-grey")))
    (create-table-heading row :content "Time")
    (create-table-heading row :content "Message")))

(defun make-logs-window (obj)
  (when *logs-window* (window-close *logs-window*))
  (let* ((win (create-gui-window obj :title "Logs" :width 600 :height 400))
         (menu (create-gui-menu-bar (window-content win) :main-menu t))
         (table (create-table (window-content win) :class "w3-table w3-striped w3-bordered w3-border w3-hoverable"))
         (tbody (create-table-body table)))
    (create-gui-menu-item menu :on-click 'clear-logs :content "Clear")
    (make-log-headers table)
    (dolist (msg *messages*)
      (make-log-row tbody msg))
    (if:register-hook (:update-messages :logs-window) (msg)
      (make-log-row tbody msg))
    (if:register-hook (:clear-messages :logs-window) ()
      (destroy table)
      (setf table (create-table (window-content win) :class "w3-table w3-striped w3-bordered w3-border w3-hoverable")
            tbody (create-table-body table))
      (make-log-headers table))))

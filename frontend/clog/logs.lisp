(in-package :mx-proxy/clog)

(defvar *logs-window* nil)

(defstruct log-item time value)

(defun pretty-time (time)
  (multiple-value-bind (s m h) (decode-universal-time time)
    (format nil "~a:~a:~a" h m s)))

(if:define-command clear-logs (&optional obj) ()
  (declare (ignore obj))
  (setf *messages* nil)
  (if:run-hook :clear-messages))

(defun create-log-row (messages msg)
  (let ((row (create-table-row messages :auto-place :top))
        (time (pretty-time (log-item-time msg)))
        (value (log-item-value msg)))
    (create-table-column row :content time)
    (create-table-column row
                         :content (hiccl:render nil (format nil "~a" value))
                         :style "text-wrap:nowrap")
    (on (click row)
      (create-inspector-window value))))

(defun create-log-headers (table)
  (let* ((head (create-table-head table))
         (row (create-table-row head :class "w3-light-grey")))
    (create-table-heading row :content "Time")
    (create-table-heading row :content "Message")))

(defun create-logs-window (obj)
  (let* ((win (create-gui-window* obj :title "Logs"))
         (menu (create-gui-menu-bar (window-content win) :main-menu t))
         (table (create-table (window-content win) :class *table-class*))
         (tbody (create-table-body table)))
    (create-gui-menu-item menu :on-click 'clear-logs :content "Clear")
    (create-log-headers table)
    (dolist (msg *messages*)
      (create-log-row tbody msg))
    (if:register-hook (:update-messages :logs-window) (msg)
      (create-log-row tbody msg))
    (if:register-hook (:clear-messages :logs-window) ()
      (destroy table)
      (setf table (create-table (window-content win) :class *table-class*)
            tbody (create-table-body table))
      (create-log-headers table))))

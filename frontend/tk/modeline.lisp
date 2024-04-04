(in-package :mx-proxy/tk)

(defun redraw-modeline ()
  (setf (text (modeline *main-app*))
        (uiop:strcat
         ;; " Server: "
         ;; (if proxy/server::*server-state*
         ;;     (uiop:strcat
         ;;      (assoc-value proxy/server::*server-state* :host)
         ;;      ":"
         ;;      (format nil "~a" (assoc-value proxy/server::*server-state* :port)))
         ;;     (uiop:strcat "Offline"))
         " | Project: "
         mx-proxy:*db-file*)))

(register-hook (:on-command :redraw-modeline) (command)
  (declare (ignore command))
  (redraw-modeline))

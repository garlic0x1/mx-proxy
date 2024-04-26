(in-package :mx-proxy/tk)

(defun redraw-modeline ()
  (setf (text (modeline *main-app*))
        (uiop:strcat
         " Server: "
         (format nil "~a:~a"
                 (ignore-errors (http:server-host mx-proxy:*server*))
                 (ignore-errors (http:server-port mx-proxy:*server*)))
         " | Project: "
         mx-proxy:*db-file*)))

(register-hook (:on-command :redraw-modeline) (command)
  (declare (ignore command))
  (redraw-modeline))

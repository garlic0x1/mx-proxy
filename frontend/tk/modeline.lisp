(in-package :mx-proxy/tk)

(defun redraw-modeline ()
  (setf (text (modeline *main-app*))
        (format nil " Server: ~a:~a | Project: ~a"
                (ignore-errors (http:server-host mx-proxy:*server*))
                (ignore-errors (http:server-port mx-proxy:*server*))
                mx-proxy:*db-file*)))

(register-hook (:on-command :redraw-modeline) (command)
  (declare (ignore command))
  (redraw-modeline))

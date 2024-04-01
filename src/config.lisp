(in-package :mx-proxy)

(defun config-home ()
  "Find the location of your config directory."
  (let ((xdg (uiop:xdg-config-home "mx-proxy/"))
        (dot (merge-pathnames ".mx-proxy/" (user-homedir-pathname))))
    (or (uiop:getenv "MX_PROXY_HOME")
        (and (probe-file dot) dot)
        xdg)))

(defun config-pathname ()
  "File for persistent config db."
  (merge-pathnames "config.lisp" (config-home)))

(defun ensure-config-pathname ()
  (ensure-directories-exist (config-pathname)))

(defun config-plist ()
  "Get the persistent config db as a plist."
  (ignore-errors
    (uiop:read-file-form (ensure-config-pathname))))

(defun config (key &optional default)
  "Get a config value by key."
  (getf (config-plist) key default))

(defun (setf config) (value key)
  "Access config value by key."
  (let ((plist (config-plist)))
    (if (null plist)
        (setf plist (list key value))
        (setf (getf plist key) value))
    (with-open-file (out (ensure-config-pathname)
                         :direction :output
                         :if-exists :supersede
                         :if-does-not-exist :create)
      (pprint plist out)))
  value)

(defun site-init ()
  (with-open-file (i (merge-pathnames "init.lisp" (config-home)))
    (let ((*package* (find-package :cl-user)))
      (load i))))

(register-hook (:init :load-config) ()
  (site-init))

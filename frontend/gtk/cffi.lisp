(in-package :mx-proxy/gtk)

(cffi:defcfun ("g_object_set" g-object-set) :void
  (object :pointer)
  (property :string)
  (value :int)
  (terminator :pointer))

(cffi:defcfun ("gtk_settings_get_default" gtk-settings-get-default) :pointer)

(defun prefer-dark-theme (bool)
  (setf (mx-proxy:config :theme) (if bool "dark" "light"))
  (g-object-set (gtk-settings-get-default)
                "gtk-application-prefer-dark-theme"
                (if bool 1 0)
                (cffi:null-pointer)))

(define-command apply-theme () ()
  (prompt-for-string
   (lambda (val) (prefer-dark-theme (string-equal val "dark")))
   :message "Theme"
   :completion (make-completion '("dark" "light"))
   :validation (make-completion '("dark" "light"))))

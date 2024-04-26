(in-package :mx-proxy/gtk)

(cffi:defcfun ("gdk_display_get_default" gdk-display-get-default) :pointer)

(cffi:defcfun ("gdk_display_get_default_screen" gdk-display-get-default-screen)
    :pointer
  (display :pointer))

(cffi:defcfun ("g_object_unref" g-object-unref) :void
  (object :pointer))

(cffi:defcfun ("g_object_set" g-object-set) :void
  (object :pointer)
  (property :string)
  (value :int)
  (terminator :pointer))

(cffi:defcfun ("gtk_settings_get_default" gtk-settings-get-default) :pointer)

(defun default-screen ()
  (gdk-display-get-default-screen (gdk-display-get-default)))

(defun font-size-style (size)
  (format nil "* { font-size: ~apx }" size))

(define-command set-font-size (size) ("iSize")
  (let ((provider (gtk4:make-css-provider)))
    (unwind-protect
         (progn
           (gtk4:css-provider-load-from-string provider (font-size-style size))
           (gtk4:style-context-add-provider-for-display
            (gdk-display-get-default)
            provider
            gtk4:+style-provider-priority-application+)))))

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

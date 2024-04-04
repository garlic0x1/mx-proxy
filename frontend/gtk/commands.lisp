(in-package :mx-proxy/gtk)

(mx-proxy:define-command test () ()
  (print "hi"))

(mx-proxy:define-command divide-by-zero (num sure) ("iNumber" "bAre you sure?")
  "Really important stuff."
  (when sure (mx-proxy:with-ui-errors (/ num 0))))

(mx-proxy:define-command load-project (file) ("fProject file:")
  (print file))

(mx-proxy:define-command apply-theme () ()
  (mx-proxy:prompt-for-string
   (lambda (val) (prefer-dark-theme (string-equal val "dark")))
   :message "Theme"
   :completion (mx-proxy:make-completion '("dark" "light"))
   :validation (mx-proxy:make-completion '("dark" "light"))))

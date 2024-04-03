(in-package :mx-proxy/gtk)

(mx-proxy:define-command test () ()
  (print "hi"))

(mx-proxy:define-command divide-by-zero (num) ("iNumber to divide by zero:")
  (/ num 0))

(mx-proxy:define-command load-project (file) ("fProject file:")
  (print file))

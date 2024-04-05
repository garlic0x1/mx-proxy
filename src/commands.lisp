(in-package :mx-proxy)

(define-command divide-by-zero (num sure) ("iNumber" "bAre you sure?")
  "Really important stuff."
  (when sure (with-ui-errors (/ num 0))))

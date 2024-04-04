(in-package :mx-proxy)

(define-command divide-by-zero (num sure) ("iNumber" "bAre you sure?")
  "Really important stuff."
  (when sure (with-ui-errors (/ num 0))))

(define-command load-project (path) ("fSelect file")
  "Pick a SQLite file to work with."
  (mito:disconnect-toplevel)
  (with-ui-errors (mx-proxy:connect-database :file path))
  (run-hook :on-load-project))


(define-command save-project (path) ("fSave path")
  "Copy current project database to file."
  (uiop:copy-file *db-file* path))

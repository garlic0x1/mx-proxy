(in-package :mx-proxy/tk)

(defun execute-command ()
  (mx-proxy:prompt-for-string
   'mx-proxy:call-with-prompts
   :completion (completion (mx-proxy:all-command-names))
   :message "Command"))

;; user interaction stuff

(define-command apropos-command (str) ("cApropos Command")
  "Get info about a command."
  (alert (gethash str mx-proxy:*commands*)))

(define-command apropos-function () ()
  "Get info about a function."
  (mx-proxy:prompt-for-string
   (lambda (str)
     (with-tk-error
       (alert
        (with-output-to-string (c)
          (describe (read-from-string str) c)))))
   :completion (completion
                (mapcar (lambda (sym) (format nil "~(~s~)" sym))
                        (mx-proxy:package-symbols :mx-proxy)))
   :message "Apropos function"))

(define-command start-server (port) ("iPort")
  "Start the proxy server on port."
  (mx-proxy:with-ui-errors (mx-proxy:start-server :port port)))

(define-command stop-server () ()
  "Stop the proxy server"
  (mx-proxy:stop-server))

(define-command load-project (path) ("fSelect file")
  "Pick a SQLite file to work with."
  (mito:disconnect-toplevel)
  (mx-proxy:with-ui-errors (mx-proxy:connect-database :file path))
  (mx-proxy:run-hook :on-load-project))

(define-command save-project (path) ("fSave path")
  "Copy current project database to file."
  (uiop:copy-file mx-proxy:*db-file* path))

(define-command divide-by-zero (num sure) ("iNumber" "bAre you sure?")
  "Really important stuff."
  (when sure (mx-proxy:with-ui-errors (/ num 0))))

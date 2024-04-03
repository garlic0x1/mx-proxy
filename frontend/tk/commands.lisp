(in-package :mx-proxy/tk)

;; frontend shim stuff

(defmethod call-with-prompts ((command mx-proxy:command))
  (prompt-for-specs
   (lambda (&rest args)
     (apply (mx-proxy:command-symbol command) args)
     (mx-proxy:run-hook :on-command command))
   (mx-proxy:command-prompts command)))

(defmethod call-with-prompts ((str string))
  (when-let ((cmd (gethash str mx-proxy:*commands*)))
    (call-with-prompts cmd)))

(defmethod call-with-prompts ((sym symbol))
  (when-let ((cmd (gethash (format nil "~(~a~)" sym) mx-proxy:*commands*)))
    (call-with-prompts cmd)))

(defun execute-command ()
  (prompt-for-string
   'call-with-prompts
   :completion (completion (mx-proxy:all-command-names))
   :message "Command"))

;; user interaction stuff

(define-command apropos-command () ()
  "Get info about a command."
  (prompt-for-string
   (lambda (str) (alert (gethash str mx-proxy:*commands*)))
   :completion (completion (mx-proxy:all-command-names))
   :message "Apropos command"))

(define-command apropos-function () ()
  "Get info about a function."
  (prompt-for-string
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
  (with-tk-error (mx-proxy:start-server :port port)))

(define-command stop-server () ()
  "Stop the proxy server"
  (mx-proxy:stop-server))

(define-command load-project (path) ("fSelect file")
  "Pick a SQLite file to work with."
  (mito:disconnect-toplevel)
  (with-tk-error (mx-proxy:connect-database :file path))
  (mx-proxy:run-hook :on-load-project))

(define-command save-project (path) ("fSave path")
  "Copy current project database to file."
  (uiop:copy-file mx-proxy:*db-file* path))

(define-command divide-by-zero (num) ("iNumber")
  "Really important stuff."
  (prompt-for-yes-or-no
   (lambda (value) (when value (with-tk-error (/ num 0))))
   :message "Are you sure?"))

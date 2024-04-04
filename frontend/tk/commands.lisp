(in-package :mx-proxy/tk)

(defun execute-command ()
  (prompt-for-string
   'call-with-prompts
   :completion (make-completion
                (all-command-names))
   :message "Command"))

;; user interaction stuff
;; TODO move to src/commands.lisp once gtk implements alert message

(define-command apropos-command (cmd) ("cApropos Command")
  "Get info about a command."
  (alert cmd))

(define-command apropos-function () ()
  "Get info about a function."
  (prompt-for-string
   (lambda (str)
     (with-ui-errors
       (alert
        (with-output-to-string (c)
          (describe (read-from-string str) c)))))
   :completion (make-completion
                (mapcar (lambda (sym) (format nil "~(~s~)" sym))
                        (mx-proxy:package-symbols :mx-proxy)))
   :message "Apropos function"))

(in-package :mx-proxy/tk)

(defun execute-command ()
  (mx-proxy:prompt-for-string
   'mx-proxy:call-with-prompts
   :completion (completion (mx-proxy:all-command-names))
   :message "Command"))

;; user interaction stuff
;; TODO move to src/commands.lisp once gtk implements alert message

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

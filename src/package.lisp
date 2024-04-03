(defpackage :mx-proxy
  (:use :cl :alexandria-2)
  (:local-nicknames (:us :usocket) (:ssl :cl+ssl))
  (:export
   ;; commands.lisp
   :*commands*
   :command
   :command-symbol
   :command-prompts
   :command-namestring
   :command-docstring
   :all-command-names
   :all-commands
   :define-command

   ;; interface.lisp
   :*interface*
   :*default-completion-test*
   :show-error-message
   :with-ui-errors
   :make-completion
   :fuzzy-match-p
   :file-completion
   :prompt-for-string*
   :prompt-for-string
   :prompt-for-file
   :prompt-for-integer
   :prompt-for-command
   :prompt-for-specs
   :call-with-prompts

   ;; hooks.lisp
   :run-hook
   :register-hook

   ;; database.lisp
   :*db-file*
   :connect-database

   ;; server.lisp
   :start-server
   :stop-server
   :replay

   ;; ssl.lisp
   :send-request-ssl

   ;; config.lisp
   :config
   :config-plist
   :config-home

   ;; utils.lisp
   :message-raw*
   :package-symbols
   ))

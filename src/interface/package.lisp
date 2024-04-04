(defpackage :mx-proxy/interface
  (:use :cl :alexandria-2)
  (:export
   ;; interface.lisp
   :*interface*
   :*default-completion-test*
   :show-error-message
   :with-ui-errors
   :fuzzy-match-p
   :make-completion
   :file-completion
   :prompt-for-string*
   :prompt-for-string
   :prompt-for-file
   :prompt-for-integer
   :prompt-for-command
   :prompt-for-specs
   :call-with-prompts

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

   ;; hooks.lisp
   :run-hook
   :register-hook))

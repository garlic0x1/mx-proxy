(defpackage :mx-proxy/interface
  (:nicknames :mxp/if)
  (:use :cl :alexandria-2)
  (:export
   ;; interface.lisp
   :*interface*
   :*default-completion-test*
   :message*
   :message
   :show-error-message
   :with-ui-errors
   :prompt-for-string*

   ;; utils
   :fuzzy-match-p
   :make-completion
   :file-completion
   :call-with-prompts

   ;; prompts.lisp
   :prompt-for-string
   :prompt-for-file
   :prompt-for-integer
   :prompt-for-command
   :prompt-for-specs

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

(uiop:define-package :mx-proxy/tk
  (:use :cl :alexandria :nodgui :ng-widgets)
  (:import-from :mx-proxy :define-command)
  (:import-from :mx-proxy/interface
                :register-hook
                :run-hook
                :prompt-for-string
                :call-with-prompts
                :make-completion
                :*commands*
                :with-ui-errors
                :all-command-names)
  (:export :main))

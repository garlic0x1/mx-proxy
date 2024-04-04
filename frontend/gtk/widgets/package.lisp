(defpackage :gtk-widgets
  (:use :cl :gtk4)
  (:import-from :alexandria-2 :when-let)
  (:export
   ;; widget.lisp
   :gobject
   ;; string-list.lisp
   :string-list*
   :string-list*-length
   :string-list*-clear
   :string-list*-append
   :string-list*-get-string
   :string-list*-insert
   ;; generic-string-list.lisp
   :generic-string-list
   :generic-string-list-clear
   :generic-string-list-length
   :generic-string-list-append
   :generic-string-list-insert
   ;; prompt.lisp
   :prompt
   ;; error-message.lisp
   :error-message
   ;; modeline.lisp
   :modeline
   :update-modeline
   ))

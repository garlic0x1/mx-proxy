(defpackage :gtk-widgets
  (:use :cl :gtk4)
  (:import-from :alexandria-2 :when-let)
  (:export
   ;; widget.lisp
   :gobject
   ;; string-list.lisp
   :string-list*
   :string-list*-length
   :string-list*-append
   ;; generic-string-list.lisp
   :generic-string-list
   :generic-string-list-length
   :generic-string-list-append
   ;; prompt.lisp
   :prompt
   ;; error-message.lisp
   :error-message
   ))

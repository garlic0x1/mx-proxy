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
   ;; prompt.lisp
   :prompt
   ))

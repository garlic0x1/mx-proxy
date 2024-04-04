(defpackage :mx-proxy/gtk
  (:use :cl :gtk4 :gtk-widgets :mx-proxy/interface)
  (:import-from :alexandria-2 :when-let)
  (:export :main))

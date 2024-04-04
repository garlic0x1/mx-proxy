(in-package :mx-proxy/tk)

(defun theme-file (name)
  (namestring
   (merge-pathnames
    (format nil "themes/tk/~a" name)
    (asdf:system-source-directory :mx-proxy))))

(defun apply-theme (file name)
  "Filename, not full path."
  (eval-tcl-file (theme-file file))
  (format-wish "ttk::style theme use ~a" name))

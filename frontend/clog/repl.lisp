(in-package :mx-proxy/clog)

(defun evaluate (string)
  (handler-case (eval (read-from-string string))
    (error (c) c)))

(defun create-lisp-entry (ul)
  (let* ((form (create-form ul))
         (entry (create-form-element form :input))
         (submit (create-button form :content "Eval")))
    (on (click submit)
      (create-result-item (value entry) ul)
      (create-lisp-entry ul))))

(defun create-result-item (sexpr ul)
  (let* ((result (evaluate sexpr))
         (it (create-list-item ul :content (hiccl:render nil (format nil "~a" result)))))
    (on (click it) (create-inspector-window result))))

(defun create-repl-window (&optional obj (package "MX-PROXY"))
  (declare (ignore obj))
  (let* ((win (create-gui-window* *window* :title "Lisp REPL"))
         (repl (clog-tools::create-clog-builder-repl (window-content win))))
    (setf (text-value (clog-tools::package-div repl)) package))
  ;; (clog-tools::on-repl *window*)
  ;; (let* ((win (create-gui-window* *window* :title "Lisp REPL"))
  ;;        (menu (create-gui-menu-bar (window-content win)))
  ;;        (ul (create-unordered-list (window-content win) :class "w3-ul")))
  ;;   (flet ((clear (&optional obj)
  ;;            (declare (ignore obj))
  ;;            (destroy ul)
  ;;            (setf ul (create-unordered-list (window-content win) :class "w3-ul"))
  ;;            (create-lisp-entry ul)))
  ;;     (create-gui-menu-item menu :on-click #'clear :content "Clear")
  ;;     (create-lisp-entry ul)
  ;;     ))
  )

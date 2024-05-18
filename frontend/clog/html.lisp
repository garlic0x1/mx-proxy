(in-package :mx-proxy/clog)

(defun prompt-window (html-id content size default-value placeholder-value)
  (declare (ignorable size))
  (flet ((input ()
           `(:input
             :style "width:80%"
             :type "text"
             :id ,(format nil "~a-input" html-id)
             :value ,default-value
             :placeholder ,placeholder-value))
         (button (id content)
           `(:button.w3-button.w3-black
             :style "width:10%"
             :id ,id
             ,content)))
    `(:div
      ,(or content "")
      (:form :onsubmit "return false;"
       ,(input)
       ,(button (format nil "~a-ok" html-id) "Okay")
       ,(button (format nil "~a-cancel" html-id) "Cancel")))))

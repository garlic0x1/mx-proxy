(in-package :mx-proxy/clog)

(defparameter *prompt-height* 200)

(defun create-prompt-window (title)
  (create-gui-window *window*
                     :title title
                     :left 0
                     :top (- (inner-height (window *window*)) *prompt-height*)
                     :width (inner-width (window *window*))
                     :height *prompt-height*
                     :keep-on-top t
                     :client-movement nil))

(defun prompt-dialog (callback message completion validation start)
  (let* ((win (create-prompt-window message))
         (form (create-form (window-content win) :style "width:100%"))
         (entry (create-form-element form :input :name "entry" :style "width:80%"))
         (ok (create-button form :content "Okay" :style "width:10%"))
         (cancel (create-button form :content "Cancel" :style "width:10%"))
         (ul (create-unordered-list (window-content win) :class "w3-ul w3-hoverable"))
         (completion-items '()))
    (setf (value entry) start
          (attribute entry "autocomplete") "off")
    (flet ((refresh-completions ()
             (let ((new (create-unordered-list (window-content win)
                                               :class "w3-ul w3-hoverable"
                                               :auto-place nil)))
               (setf completion-items '())
               (dolist (it (funcall completion (value entry)))
                 (setf completion-items (append completion-items (list it)))
                 (let ((li (create-list-item new :content it)))
                   (on (click li)
                     (setf (value entry) it)
                     (focus entry))))
               (destroy ul)
               (setf ul new)
               (place-inside-bottom-of (window-content win) ul))
             (focus entry)))
      (refresh-completions)
      (on (click ok)
        (when (funcall validation (value entry))
          (funcall callback (value entry))
          (window-close win)))
      (on (click cancel) (window-close win))
      (on (key-down entry)
        (let ((key (getf *ev* :key)))
          (cond ((equal "Escape" key)
                 (window-close win))
                ((equal "Tab" key)
                 (setf (value entry) (car completion-items))
                 (refresh-completions))))
        (refresh-completions)))))

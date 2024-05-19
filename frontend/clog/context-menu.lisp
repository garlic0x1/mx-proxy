(in-package :mx-proxy/clog)

(defparameter *context-menu-width* 128)
(defparameter *context-menu-height* 256)

(defun below-p (y)
  (< (- (inner-height (window *window*)) *context-menu-height*) y))

(defun right-p (x)
  (< (- (inner-width (window *window*)) *context-menu-width*) x))

(defun create-context-menu (x y items callback)
  (let* ((panel (create-panel *window*
                              :width *context-menu-width*
                              :style (format nil "max-height:~apx;"
                                             *context-menu-height*)
                              :left x
                              :top y :class "w3-bordered w3-black"))
         (ul (create-unordered-list panel :class "w3-ul w3-hoverable")))
    (setf (overflow panel) :auto
          (overflow ul) :auto)
    (dolist (it items)
      (let* ((content (hiccl:render nil (format nil "~a" it)))
             (li (create-list-item ul :content content)))
        (on (click li)
          (destroy panel)
          (funcall callback it))))
    panel))

(if:define-command test-menu () ()
  (create-context-menu 100 100 '("hi" :world (1 2 3) 1 1 1 1 1 1 11 1 1 1 1 1  a aa a a a a a1) #'if:message))

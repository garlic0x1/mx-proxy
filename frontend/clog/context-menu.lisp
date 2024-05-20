(in-package :mx-proxy/clog)

(defparameter *context-menu-width* 128)
(defparameter *context-menu-height* 256)

(defun below-p (y)
  (< (- (inner-height (window *window*)) *context-menu-height*) y))

(defun right-p (x)
  (< (- (inner-width (window *window*)) *context-menu-width*) x))

(defun create-context-menu (&key x y)
  (let* ((panel (create-panel
                 *window*
                 :width *context-menu-width*
                 :style (format nil "max-height:~apx;" *context-menu-height*)
                 :left (1- x)
                 :top (1- y)
                 :class "w3-bordered w3-black")))
    (setf (overflow panel) :auto)
    (on (blur panel) (destroy panel))
    (on (focus-out panel) (destroy panel))
    (on (mouse-leave panel) (destroy panel))
    (focus panel)
    panel))

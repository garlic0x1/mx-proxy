(in-package :mx-proxy/clog)

(defparameter *table-class* "w3-table w3-striped w3-bordered w3-border w3-hoverable")
(defparameter *list-class* "w3-ul w3-hoverable")

(defvar *obj*)
(defvar *ev*)

(defmacro on ((event obj &rest keys &key &allow-other-keys) &body body)
  (let ((set-on (intern (string-upcase (format nil "set-on-~a" event)))))
    `(,set-on ,obj
              (lambda (obj &optional ev)
                (let ((*obj* obj)
                      (*ev* ev))
                  ,@body))
              ,@keys)))

; ??????????????????
;; (defmacro orient-win (win top left width height)
;;   `(progn (unless ,top
;;             (setf (,top ,win) (unit :px (- (/ (inner-height (window *window*)) 2.0)
;;                                            (/ (,height ,win) 2.0)))))
;;           (unless ,left
;;             (setf (,left ,win) (unit :px (- (/ (inner-width (window *window*)) 2.0)
;;                                             (/ (,width ,win) 2.0)))))))

(defun slot-names (obj)
  (mapcar #'sb-mop:slot-definition-name
          (sb-mop:class-slots (class-of obj))))

(defun slot-values (obj)
  (mapcar (lambda (slot) (ignore-errors (slot-value obj slot)))
          (slot-names obj)))

(defun slots-alist (obj)
  (loop :for name :in (slot-names obj)
        :for val :in (slot-values obj)
        :collect (cons name val)))

(defun type-of-simple (obj)
  (let ((type (type-of obj)))
    (if (listp type)
        (car type)
        type)))

(defun class-of-simple (obj)
  (class-name (class-of obj)))

(defun orient-win (win top left width height)
  (if:message (format nil "orienting ~a" (list top left width height)))
  (setf (top win) top
        (left win) left
        (width win) width
        (height win) height))

(defun split-window-vertically (win new-win)
  (let ((new-width (floor (/ (width win) 2))))
    (orient-win win
                (offset-top win)
                (offset-left win)
                new-width
                (height win))
    (orient-win new-win
                (offset-top win)
                (+ new-width (offset-left win))
                new-width
                (height win))))

(defun split-window-horizontally (win new-win)
  (let ((new-height (floor (/ (height win) 2))))
    (orient-win win
                (offset-top win)
                (offset-left win)
                (width win)
                new-height)
    (orient-win new-win
                (+ new-height (offset-top win))
                (offset-left win)
                (width win)
                new-height)))

(defun non-modal-windows ()
  (let* ((app (connection-data-item *window* "clog-gui"))
         (raw (a:hash-table-values (clog-gui::windows app)))
         (modal-p (< 0 (clog-gui::modal-count app))))
    (if modal-p (cdr raw) raw)))

(if:define-command tile-windows (&optional obj (n 5)) ()
  (declare (ignore obj))
  (let* ((windows (non-modal-windows))
         (last (car windows))
         (index 0))
    (window-maximize last)
    (loop :for w :in (cdr windows)
          :while (< index n)
          :do (if (evenp index)
                  (split-window-vertically last w)
                  (split-window-horizontally last w))
          :do (incf index))))

(defparameter *default-width* 480)
(defparameter *default-height* 480)
(defparameter *auto-balancing* t)

(defun create-gui-window* (obj &rest rest &key &allow-other-keys)
  (prog1 (apply (a:curry #'create-gui-window
                         obj
                         :width *default-width*
                         :height *default-height*)
                rest)
    (when *auto-balancing* (tile-windows))))

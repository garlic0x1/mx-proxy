(in-package :mx-proxy/gtk)

(defclass settings (widget) ())

(defmethod initialize-instance :after ((self settings) &key &allow-other-keys)
  (let* ((box (make-box :orientation +orientation-vertical+ :spacing 16))
         (grid (make-grid))
         (scroll (make-scrolled-window))
         (title (make-label :str "Settings"))
         (entries '())
         (save-button (make-button :label "Save")))
    (loop :with i := 0
          :for (k v) :on (mx-proxy:config-plist) :by #'cddr
          :for label := (make-label :str (string-capitalize k))
          :for entry := (make-entry)
          :do (setf (entry-buffer-text (entry-buffer entry)) (format nil "~s" v)
                    (widget-hexpand-p entry) t)
          :do (push (cons k entry) entries)
          :do (grid-attach grid label 0 i 1 1)
          :do (grid-attach grid entry 1 i 1 1)
          :do (incf i))
    (box-append box title)
    (box-append box scroll)
    (box-append box save-button)
    (connect save-button "clicked"
             (lambda (button)
               (declare (ignore button))
               (print "saving")
               (loop :for e :in entries
                     :do (let ((k (car e))
                               (entry (cdr e)))
                           (print "e")
                           (print e)
                           (handler-case
                               (print
                                (setf (mx-proxy:config k)
                                      (read-from-string
                                       (entry-buffer-text
                                        (entry-buffer entry)))))
                             (error (c)
                               (print c)
                               ))))))
    (setf (label-markup title) "<big><big>Settings</big></big>"
          (widget-vexpand-p scroll) t
          (widget-margin-all box) 16
          (grid-column-spacing grid ) 16
          (grid-row-spacing grid ) 8
          (scrolled-window-child scroll) grid
          (gobject self) box)))

(in-package :mx-proxy/qt)
(in-readtable :qtools)

(defun meta-x-p (ev)
  (and (= 134217728 (q+:modifiers ev))
       (= 88 (q+:key ev))))

(define-widget main-widget (QWidget) ())

(define-subwidget (main-widget traffic) (make-instance 'traffic))

(define-subwidget (main-widget repl) (make-instance 'qtools-ui:repl))

(define-subwidget (main-widget tabs) (q+:make-qtabwidget)
  (q+:add-tab tabs traffic "Traffic")
  (q+:add-tab tabs repl "REPL"))

(define-subwidget (main-widget layout) (q+:make-qgridlayout main-widget)
  (q+:add-widget layout tabs 1 0))

(define-override (main-widget key-press-event) (ev)
  (if (meta-x-p ev)
      (execute-command)
      (call-next-qmethod)))

(defvar *main-layout* nil)

(define-initializer (main-widget setup)
  (apply-dark-theme main-widget)
  (setf *main-layout* layout))

(defun main ()
  (with-main-window (make-instance 'main-widget)))

(define-command test-cmd (str) ("sString") (print str))
(define-command test-cmd2 () () (print "hi"))

(defun apply-dark-theme (widget)
  (setf (q+:style-sheet widget) "
    /* Dark theme stylesheet */
    QWidget {
        background-color: #333333;
        color: #ffffff;
    }

    QPushButton {
        background-color: #555555;
        color: #ffffff;
    }

    QLineEdit {
        background-color: #555555;
        color: #ffffff;
    }"))

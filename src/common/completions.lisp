(defpackage :mx-proxy/common/completions
  (:use :cl :alexandria-2))
(in-package :mx-proxy/common/completions)

(defparameter *default-completion-test* 'search)

(defun fuzzy-match-p (sub str &optional ignore-case)
  (loop :with start := 0
        :for c :across sub
        :for test := (if ignore-case #'char-equal #'char=)
        :for pos := (position c str :start start :test test)
        :do (if pos (setf start pos) (return nil))
        :finally (return t)))

(defun make-completion (selection &key (test *default-completion-test*))
  (lambda (str) (remove-if-not (curry test str) selection)))

(defun file-completion (str)
  (let ((dir (namestring (uiop:pathname-directory-pathname str))))
    (remove-if-not (curry #'str:starts-with-p str)
                   (mapcar #'namestring
                           (append (uiop:subdirectories dir)
                                   (uiop:directory-files dir))))))

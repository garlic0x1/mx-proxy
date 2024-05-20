(defpackage :mx-proxy/common/trie
  (:use :cl :alexandria-2)
  (:export :path-trie
           :make-path-trie
           :path-trie-add))
(in-package :mx-proxy/common/trie)

(defclass path-trie ()
  ((path
    :initarg :path
    :initform nil
    :accessor path-trie-path)
   (nodes
    :initarg :nodes
    :initform (make-hash-table :test #'equal)
    :accessor path-trie-nodes)))

(defmethod path-trie-add (trie (path null)))

(defmethod path-trie-add (trie (path string))
  (path-trie-add trie (str:split #\/ path :omit-nulls t)))

(defmethod path-trie-add (trie (path list))
  (if-let ((next (gethash (car path) (path-trie-nodes trie))))
    (path-trie-add next (cdr path))
    (let ((next (make-instance 'path-trie :path (car path))))
      (setf (gethash (car path) (path-trie-nodes trie)) next)
      (path-trie-add next (cdr path)))))

(defun make-path-trie (paths)
  (let ((root (make-instance 'path-trie)))
    (dolist (path paths)
      (path-trie-add root path))
    root))

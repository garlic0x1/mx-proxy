(defpackage :mx-proxy/common/concurrency
  (:use :cl)
  (:export :wmap :wfilter :wforeach))
(in-package :mx-proxy/common/concurrency)

(defun list->simple-cqueue (list)
  (let ((q (queues:make-queue :simple-cqueue)))
    (loop :for it :in list :do (queues:qpush q it))
    q))

(defun simple-cqueue->list (q)
  (loop :with it :and ok
        :do (setf (values it ok) (queues:qpop q))
        :while ok :collect it))

(defmacro join-workers (workers &body body)
  `(mapcar #'bt:join-thread
           (loop :repeat ,workers
                 :collect (bt:make-thread (lambda () ,@body)))))

(defmacro queue-consumer (q &body proc)
  `(loop :with it :and ok
         :do (setf (values it ok) (queues:qpop ,q))
         :while ok :do (funcall ,(car proc) it)))

(defmacro join-consumers (workers q &body proc)
  `(join-workers ,workers (queue-consumer ,q ,(car proc))))

(defgeneric wmap (workers proc in)
  (:documentation "Mapcar a list or cqueue with n workers")

  (:method (workers proc (in list))
    (wmap workers proc (list->simple-cqueue in)))

  (:method (workers proc (in queues:simple-cqueue))
    (let ((out (queues:make-queue :simple-cqueue)))
      (join-consumers workers in (lambda (it) (queues:qpush out (funcall proc it))))
      (simple-cqueue->list out))))

(defgeneric wfilter (workers proc in)
  (:documentation "Filter a list or cqueue with n workers")
  (:method (workers proc (in list))
    (wfilter workers proc (list->simple-cqueue in)))
  (:method (workers proc (in queues:simple-cqueue))
    (let ((out (queues:make-queue :simple-cqueue)))
      (join-consumers workers in (lambda (it) (when (funcall proc it) (queues:qpush out it))))
      (simple-cqueue->list out))))

(defgeneric wforeach (workers proc in)
  (:documentation "Apply proc to input with n workers")
  (:method (workers proc (in list))
    (wforeach workers proc (list->simple-cqueue in)))
  (:method (workers proc (in queues:simple-cqueue))
    (join-consumers workers in (lambda (it) (funcall proc it)))))

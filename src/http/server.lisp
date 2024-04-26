(in-package :http)

(defstruct server
  thread
  host
  port)

(define-condition stop () ())

(defun accept-connection (sock handler)
  (let ((conn (us:socket-accept sock :element-type '(unsigned-byte 8))))
    (bt:make-thread
     (lambda ()
       (unwind-protect (funcall handler conn)
         (us:socket-close conn))))))

(defun server-loop (host port handler)
  (let ((sock (us:socket-listen host port :element-type '(unsigned-byte 8))))
    (unwind-protect (handler-case (loop (accept-connection sock handler))
                      (stop () (print "interrupted")))
      (print "exiting")
      (us:socket-close sock))))

(defun stop-server (server)
  "Kill the thread if this isn't enough."
  (bt:interrupt-thread (server-thread server) (lambda () (signal 'stop))))

(defun start-server (&key (host "127.0.0.1")
                          (port 5000)
                          (handler (error "Must provide handler.")))
  (make-server
   :host host
   :port port
   :thread (bt:make-thread (lambda () (server-loop host port handler)))))

(in-package :http)
(cl-annot:enable-annot-syntax)

@export-class
(mito:deftable message ()
  ((raw
    :col-type :text
    :initarg :raw
    :initform ""
    :accessor message-raw)
   (headers
    :col-type :jsonb
    :initarg :headers
    :initform '()
    :accessor message-headers
    :inflate #'http/util:inflate-alist
    :deflate #'http/util:deflate-alist)
   (body
    :col-type (or :null :text)
    :initarg :body
    :initform nil
    :accessor message-body)))

@export-class
(mito:deftable request (message)
  ((method
    :col-type (:varchar 32)
    :initarg :method
    :initform :GET
    :accessor request-method)
   (uri
    :col-type (:varchar 2048)
    :initarg :uri
    :initform "/"
    :accessor request-uri
    :inflate #'http/util:inflate-uri
    :deflate #'http/util:deflate-uri)
   (protocol
    :col-type (:varchar 32)
    :initarg :protocol
    :initform "HTTP/1.1"
    :accessor request-protocol)
   (host
    :col-type (or :null (:varchar 1024))
    :initarg :host
    :initform nil
    :accessor request-host)))

@export-class
(mito:deftable response (message)
  ((protocol
    :col-type (:varchar 32)
    :initarg :protocol
    :initform "HTTP/1.1"
    :accessor response-protocol)
   (status-code
    :col-type :integer
    :initarg :status-code
    :initform 200
    :accessor response-status-code)
   (status
    :col-type (:varchar 256)
    :initarg :status
    :initform "OK"
    :accessor response-status)))

@export-class
(mito:deftable message-pair ()
  ((metadata
    :col-type (or :null :jsonb)
    :initarg :metadata
    :initform nil
    :accessor message-pair-metadata
    :inflate #'http/util:inflate-alist
    :deflate #'http/util:deflate-alist)
   (request
    :col-type request
    :initarg :request
    :initform nil
    :accessor message-pair-request)
   (response
    :col-type response
    :initarg :response
    :initform nil
    :accessor message-pair-response)))

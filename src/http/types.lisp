(in-package :http)

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
    :inflate #'inflate-alist
    :deflate #'deflate-alist)
   (body
    :col-type (or :null :text)
    :initarg :body
    :initform nil
    :accessor message-body)))

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
    :inflate #'inflate-uri
    :deflate #'deflate-uri)
   (protocol
    :col-type (:varchar 32)
    :initarg :protocol
    :initform "HTTP/1.1"
    :accessor request-protocol)
   (host
    :col-type (or :null (:varchar 1024))
    :initarg :host
    :initform nil
    :accessor request-host)
   (ssl-p
    :col-type :boolean
    :initarg :ssl-p
    :initform nil
    :accessor request-ssl-p)))

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

(mito:deftable message-pair ()
  ((metadata
    :col-type (or :null :jsonb)
    :initarg :metadata
    :initform nil
    :accessor message-pair-metadata
    :inflate #'inflate-alist
    :deflate #'deflate-alist)
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

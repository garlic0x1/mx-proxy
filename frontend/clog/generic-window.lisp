(in-package :mx-proxy/clog)

(defmethod create-generic-window ((value t))
  (create-inspector-window value))

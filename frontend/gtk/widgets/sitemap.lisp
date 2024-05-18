(in-package :mx-proxy/gtk)

(defclass sitemap (widget)
  ((host
    :initarg :host
    :initform nil
    :accessor sitemap-host)
   (path-trie
    :initarg :path-trie
    :initform nil
    :accessor sitemap-path-trie)))

(gir-wrapper:define-gir-namespace "GFlow" "0.10")
(gir-wrapper:define-gir-namespace "GtkFlow" "0.10")

(defmethod initialize-instance :after ((self sitemap) &key &allow-other-keys)
  (let* ((overlay (make-overlay)))))

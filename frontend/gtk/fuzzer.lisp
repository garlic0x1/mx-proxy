(in-package :mx-proxy/gtk)

(defclass fuzzer (widget)
  ((req
    :initarg :req
    :initform nil
    :accessor fuzzer-req)
   (resps
    :accessor fuzzer-resps)
   (selected
    :initform nil
    :accessor fuzzer-selected)
   (req-buf
    :accessor req-buf)
   (resps-box
    :accessor resps-box)
   (wordlist
    :initform ""
    :accessor fuzzer-wordlist)
   (wordlist-label
    :initform nil
    :accessor wordlist-label)))

(defmethod initialize-instance :after ((self fuzzer) &key &allow-other-keys)
  (let* ((paned (make-paned :orientation +orientation-horizontal+))
         (req-box (make-box :orientation +orientation-vertical+ :spacing 0))
         (resps-box (make-box :orientation +orientation-vertical+ :spacing 0))
         (fuzz-button (make-button :label "Fuzz"))
         (wordlist-box (make-box :orientation +orientation-horizontal+ :spacing 0))
         (wordlist-button (make-button :label "Select wordlist"))
         (wordlist-label (make-label :str "NIL"))
         (req-pane (make-text-view))
         (req-scroll (make-scrolled-window))
         (resps-list (make-instance 'generic-string-list
                                    :display #'display-response
                                    :on-change (lambda (val)
                                                 (swap (fuzzer-selected self) val)
                                                 (fuzzer-rerender self)
                                                 (widget-show
                                                  (gobject
                                                   (fuzzer-selected self))))))
         (selected (make-instance 'message-pair)))
    (box-append req-box req-scroll)
    (box-append req-box fuzz-button)
    (box-append req-box wordlist-box)
    (box-append wordlist-box wordlist-label)
    (box-append wordlist-box wordlist-button)
    (box-append resps-box (gobject resps-list))
    (box-append resps-box (gobject selected))
    (setf (paned-start-child paned) req-box
          (paned-end-child paned) resps-box)

    (widget-hide resps-box)
    (widget-hide (gobject selected))

    (connect fuzz-button "clicked"
             (lambda (button)
               (declare (ignore button))
               (fuzzer-fuzz self
                            (text-buffer-text (req-buf self))
                            (fuzzer-wordlist self))))

    (connect wordlist-button "clicked"
             (lambda (button)
               (declare (ignore button))
               (mx-proxy/interface:prompt-for-file
                (lambda (file)
                  (setf (fuzzer-wordlist self) file)
                  (fuzzer-rerender self))
                :message "Select wordlist")))

    (setf (gobject self) paned
          (widget-size-request resps-box) '(300 0)
          (widget-hexpand-p req-box) t
          (widget-hexpand-p resps-box) t
          (widget-hexpand-p wordlist-box) t
          (widget-hexpand-p wordlist-button) t
          (widget-vexpand-p req-scroll) t
          (widget-vexpand-p (gobject resps-list)) t
          (wordlist-label self) wordlist-label
          (req-buf self) (text-view-buffer req-pane)
          (fuzzer-selected self) selected
          (resps-box self) resps-box
          (fuzzer-resps self) resps-list
          (scrolled-window-child req-scroll) req-pane)
    (fuzzer-rerender self)))

(defun display-response (pair)
  (let ((resp (http:message-pair-response pair)))
    (format nil "~a ~a ~a"
            (http:response-protocol resp)
            (http:response-status-code resp)
            (http:response-status resp))))

(defun fuzzer-rerender (self)
  (setf (label-text (wordlist-label self)) (fuzzer-wordlist self))
  (when (fuzzer-req self)
    (setf (text-buffer-text (req-buf self)) (http:message-raw (fuzzer-req self)))))

(defmethod swap ((self fuzzer) value)
  (setf (fuzzer-req self) value)
  (swap (fuzzer-selected self) nil)
  (generic-string-list-clear (fuzzer-resps self))
  (widget-hide (resps-box self))
  (fuzzer-rerender self))

(defun templated-request (req edited word)
  (mx-proxy::copy req :raw (str:replace-all "~FUZZ" word edited)))

(defun fuzzer-fuzz (self edited wordlist)
  (widget-show (resps-box self))
  (bt:make-thread
   (lambda ()
     (mx-proxy/common/concurrency:wforeach
      12
      (lambda (word)
        (let* ((req (templated-request (fuzzer-req self) edited word))
               (resp (http:send-request req :raw t))
               (pair (make-instance 'http:message-pair :request req :response resp)))
          (idle-add
           (lambda ()
             (generic-string-list-append (fuzzer-resps self) (list pair))))))
      (str:lines (uiop:read-file-string wordlist))))))

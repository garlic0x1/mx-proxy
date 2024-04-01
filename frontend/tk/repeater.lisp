(in-package :mx-proxy/tk)

(defwidget repeater (frame)
  ((message-pair
    :initarg :value
    :initform nil
    :accessor repeater-value)
   (decompress-p
    :initarg :decompress
    :initform nil
    :accessor repeater-decompress-p))
  ((buttons frame
            :pack (:fill :x)
            (replay button
                    :pack (:anchor "w" :side :left)
                    :text "Replay"
                    :command (lambda () (repeater-replay self)))
            (insp-toggle button
                         :pack (:anchor "w" :side :left)
                         :text "Toggle Inspector"
                         :command (lambda ()
                                    (message-pair-view-toggle-inspector
                                     (pair self))))
            (decomp-toggle check-button
                           :pack (:anchor "w" :side :left)
                           :text "Decompress"
                           :command (lambda (value)
                                      (let ((decompress (not (= 0 value))))
                                        (setf (repeater-decompress-p self) decompress)
                                        (repeater-swap self (repeater-value self))))))
   (pair message-pair-view
         :value (repeater-value self)
         :pack (:expand t :fill :both))))

(defun repeater-swap (self value)
  (setf (repeater-value self) value)
  (message-pair-view-swap (pair self) value
                          :decompress (repeater-decompress-p self)))

(defun repeater-replay (self)
  (let* ((req (http:message-pair-request (repeater-value self)))
         (edited (text (req (pair self))))
         (host (http:request-host req)))
    (multiple-value-bind (resp pair) (mx-proxy:replay req edited :ssl host :host host)
      (declare (ignore resp))
      (repeater-swap self pair))))

(defwidget message-pair-view (frame)
  ((message-pair
    :initarg :value
    :initform nil
    :accessor message-pair-view-value)
   (inspector-p
    :initarg :inspector-p
    :initform nil
    :accessor message-pair-view-inspector-p))
  ((insp inspector
         :relief :ridge
         :borderwidth 1
         :value (message-pair-view-value self))
   (panes paned-window
          :grid '(1 0 :sticky "nsew"))
   (req text)
   (resp text))
  (add-pane panes req :weight 1)
  (add-pane panes resp :weight 1)
  (grid-columnconfigure self 0 :weight 1)
  (grid-rowconfigure self 1 :weight 1)
  (let ((val (message-pair-view-value self)))
    (when (message-pair-view-inspector-p self)
      (grid (insp self) 0 0 :sticky "nsew"))
    (message-pair-view-swap self val)))

(defun message-pair-view-swap (self val &key decompress)
  (configure (resp self) :state :normal)
  (inspector-swap (insp self) val)
  (when val
    (setf (message-pair-view-value self) val
          (text (req self)) (mx-proxy::message-raw*
                             (http:message-pair-request val)
                             :decompress decompress)
          (text (resp self)) (mx-proxy::message-raw*
                              (http:message-pair-response val)
                              :decompress decompress)))
  (configure (resp self) :state :disabled))

(defun message-pair-view-toggle-inspector (self)
  (setf (message-pair-view-inspector-p self)
        (not (message-pair-view-inspector-p self)))
  (if (message-pair-view-inspector-p self)
      (grid (insp self) 0 0 :sticky "nsew")
      (grid-forget (insp self))))

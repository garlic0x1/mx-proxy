(in-package :mx-proxy/clog)

(defmethod create-message-window ((msg http:request))
  (let ((win (create-gui-window* *window* :title "Request")))
    (create-text-area (window-content win) :value (http:message-raw msg))
    win))

(defmethod create-message-window ((msg http:response))
  (let ((win (create-gui-window* *window* :title "Response")))
    (create-text-area (window-content win) :value (http:message-raw msg))
    win))

(defun create-message-pair-view (obj mp)
  (let* ((div (create-div obj :style "height:100%;"))
         (req (http:message-pair-request mp))
         (resp (http:message-pair-response mp)))
    (create-text-area div
                      :value (http:message-raw req)
                      :style "width:100%;height:50%;border:solid;")
    (create-text-area div
                      :value (http:message-raw resp)
                      :style "width:100%;height:50%;border:solid;")
    div))

(defun create-message-pair-window (mp)
  (let ((win (create-gui-window* *window* :title "Message Pair")))
    (create-message-pair-view (window-content win) mp)
    win))

(in-package :mx-proxy/clog)

(defun create-repeater-window (mp)
  (let* ((win (create-gui-window* *window* :title "Repeater"))
         (menu (create-gui-menu-bar (window-content win)))
         (replay-button (create-button menu :content "Replay")))
    (multiple-value-bind (div req resp)
        (create-message-pair-view (window-content win) mp)
      (declare (ignore div))
      (on (click replay-button)
        (if:message (value req))
        (setf (text resp)
              (if:with-ui-errors
                (http:message-raw
                 (http:message-pair-response
                  (mx-proxy:replay
                   (http:message-pair-request mp)
                   (value req))))))))))

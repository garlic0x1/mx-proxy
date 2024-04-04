(in-package :mx-proxy/tk)

(defwidget traffic (frame)
  ()
  ((panes paned-window
          :orientation :horizontal
          :pack (:fill :both :expand t))
   (messages listbox*
             :items (reverse (mito:select-dao 'http:message-pair))
             :display 'display-message-pair
             :command (lambda (items)
                        (when-let ((item (car items)))
                          (repeater-swap (repeater self) item))))
   (repeater repeater))
  (add-pane panes messages :weight 1)
  (add-pane panes repeater :weight 1)
  (register-hook (:on-load-project :traffic-pane) ()
    (listbox*-delete-all messages)
    (listbox*-push messages (reverse (mito:select-dao 'http:message-pair))))
  (register-hook (:on-message-pair :traffic-pane) (message-pair)
    (let ((*wish* *wish-conn*))
      (handler-case (listbox*-push messages (list message-pair))
        (error (c) (warn c))))))

(defun display-message-pair (item)
  (let ((req (http:message-pair-request item))
        (resp (http:message-pair-response item)))
    (format nil "~a ~a ~a ~a"
            (ignore-errors (http:request-method req))
            (ignore-errors (http:request-uri req))
            (ignore-errors (http:response-status-code resp))
            (ignore-errors (http:response-status resp)))))

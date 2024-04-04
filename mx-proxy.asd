(asdf:defsystem "mx-proxy"
  :author "garlic0x1"
  :license "MIT"
  :depends-on (:alexandria :cl-annot :str :bordeaux-threads
               :usocket :chunga :flexi-streams :chipz :cl+ssl
               :yason :puri :mito :http)
  :components ((:module "src/http"
                :components ((:file "package")
                             (:file "utils")
                             (:file "types")
                             (:file "encodings")
                             (:file "read")
                             (:file "write")
                             (:file "server")
                             (:file "client")))
               (:module "src"
                :components ((:file "package")
                             (:file "utils")
                             (:file "hooks")
                             (:file "commands")
                             (:file "database")
                             (:file "ssl")
                             (:file "server")
                             (:file "config")
                             (:file "interface")))))

(asdf:defsystem "mx-proxy/gtk"
  :depends-on (:alexandria :str :cl-gtk4 :cl-gdk4 :cl-gtk4.adw)
  :components ((:module "frontend/gtk/widgets"
                :components ((:file "package")
                             (:file "widget")
                             (:file "string-list")
                             (:file "generic-string-list")
                             (:file "error-message")
                             (:file "prompt")))
               (:module "frontend/gtk"
                :components ((:file "package")
                             (:file "parameters")
                             (:file "cffi")
                             (:file "settings")
                             (:file "commands")
                             (:file "message-pair")
                             (:file "repeater")
                             (:file "traffic")
                             (:file "prompt")
                             (:file "errors")
                             (:file "app"))))
  :build-operation "program-op"
  :build-pathname "bin/mx-proxy"
  :entry-point "mx-proxy/gtk:main")

(asdf:defsystem "mx-proxy/tk"
  :depends-on (:alexandria :str :nodgui)
  :components ((:module "frontend/tk/widgets"
                :components ((:file "package")
                             (:file "utils")
                             (:file "listbox")
                             (:file "prompt")
                             (:file "inspector")))
               (:module "frontend/tk"
                :components ((:file "package")
                             (:file "errors")
                             (:file "prompt")
                             (:file "message")
                             (:file "commands")
                             (:file "repeater")
                             (:file "traffic")
                             (:file "modeline")
                             (:file "app"))))
  :build-operation "program-op"
  :build-pathname "bin/mx-proxy"
  :entry-point "mx-proxy/tk:main")

(asdf:defsystem "mx-proxy/lem"
  :components ((:module "frontend/lem"
                :components ((:file "package")
                             (:file "modes")
                             (:file "buffers")
                             (:file "render")
                             (:file "commands")
                             (:file "lem")))))

;; probably not going to use this one
(asdf:defsystem "mx-proxy/qt"
  :defsystem-depends-on (:qtools)
  :depends-on (:alexandria :str :qtools :qtcore :qtgui :qtools-ui-repl)
  :components ((:module "frontend/qt"
                :components ((:file "package")
                             (:file "utils")
                             (:file "collapsible")
                             (:file "inspector")
                             (:file "message-pair")
                             (:file "traffic")
                             (:file "prompt")
                             (:file "commands")
                             (:file "app"))))
  :build-operation "qt-program-op"
  :build-pathname "mx-proxy"
  :entry-point "mx-proxy/qt:main")

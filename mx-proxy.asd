(asdf:defsystem "mx-proxy"
  :author "garlic0x1"
  :license "MIT"
  :depends-on (:alexandria :str :bordeaux-threads :usocket :chunga :flexi-streams
               :chipz :cl+ssl :yason :puri :mito :queues.simple-cqueue)
  :components ((:module "src/common"
                :components ((:file "concurrency")))
               (:module "src/http"
                :components ((:file "package")
                             (:file "utils")
                             (:file "types")
                             (:file "encodings")
                             (:file "read")
                             (:file "write")
                             (:file "server")
                             (:file "client")))
               (:module "src/interface"
                :components ((:file "package")
                             (:file "interface")
                             (:file "hooks")
                             (:file "commands")
                             (:file "prompts")
                             (:file "utils")))
               (:module "src"
                :components ((:file "package")
                             (:file "utils")
                             (:file "database")
                             (:file "ssl")
                             (:file "server")
                             (:file "config")))))

(asdf:defsystem "mx-proxy/gtk"
  :depends-on (:alexandria :str :cl-gtk4 :cl-gdk4 :micros)
  :components ((:module "frontend/gtk/widgets"
                :components ((:file "package")
                             (:file "widget")
                             (:file "string-list")
                             (:file "generic-string-list")
                             (:file "error-message")
                             (:file "lisp-entry")
                             (:file "repl")
                             (:file "prompt")))
               (:module "frontend/gtk"
                :components ((:file "package")
                             (:file "parameters")
                             (:file "styles")
                             (:file "settings")
                             (:file "message-pair")
                             (:file "repeater")
                             (:file "traffic")
                             (:file "traffic-list")
                             (:file "fuzzer")
                             (:file "interface")
                             (:file "errors")
                             (:file "modeline")
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

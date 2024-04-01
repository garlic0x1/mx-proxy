(asdf:defsystem "mx-proxy"
  :author "garlic0x1"
  :license "MIT"
  :depends-on (:alexandria
               :cl-annot
               :str
               :usocket
               :chunga
               :flexi-streams
               :chipz
               :yason
               :puri
               :bordeaux-threads
               :cl+ssl
               :http
               :mito)
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
                             (:file "server")))))

(asdf:defsystem "mx-proxy/qt"
  :defsystem-depends-on (:qtools)
  :depends-on (:alexandria :str :qtools :qtcore :qtgui :qtools-ui-repl)
  :components ((:module "frontend/qt"
                :components ((:file "package")
                             (:file "utils"))))
  :build-operation "qt-program-op"
  :build-pathname "proxy"
  :entry-point "proxy/qt:main")

(asdf:defsystem "proxy/tk"
  :depends-on (:alexandria :str :nodgui :ng-widgets)
  :components ((:module "frontend/tk"
                :components ((:file "package")
                             (:file "errors")
                             (:file "prompt")
                             (:file "message")
                             (:file "repeater")
                             (:file "traffic")
                             (:file "modeline")
                             (:file "app"))))
  :build-operation "program-op"
  :build-pathname "bin/proxy"
  :entry-point "proxy/tk:main")

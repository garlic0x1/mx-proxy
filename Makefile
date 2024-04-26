LISP ?= ${shell which sbcl}

clean:
	-rm bin/*

tk: clean
	$(LISP) --load mx-proxy.asd \
		--eval "(ql:quickload '(:mx-proxy :mx-proxy/tk))" \
		--eval "(asdf:make :mx-proxy/tk)" \
		--eval "(quit)"

gtk: clean
	$(LISP) --load mx-proxy.asd \
		--eval "(ql:quickload '(:mx-proxy :mx-proxy/gtk))" \
		--eval "(asdf:make :mx-proxy/gtk)" \
		--eval "(quit)"

qt: clean
	$(LISP) --load mx-proxy.asd \
		--eval "(ql:quickload '(:mx-proxy :mx-proxy/qt))" \
		--eval "(asdf:make :mx-proxy/qt)" \
		--eval "(quit)"

embed:
	objcopy --add-section mkcert=`which mkcert` ./bin/mx-proxy ./bin/mx-proxy.loader

extract:
	objcopy --dump-section mkcert=./bin/mkcert ./bin/mx-proxy.loader
	objcopy --remove-section mkcert ./bin/mx-proxy.loader ./bin/mx-proxy

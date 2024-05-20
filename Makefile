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

clog: clean
	$(LISP) --load mx-proxy.asd \
		--eval "(ql:quickload '(:mx-proxy :mx-proxy/clog))" \
		--eval "(asdf:make :mx-proxy/clog)" \
		--eval "(quit)"

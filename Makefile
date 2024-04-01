LISP ?= ${shell which sbcl}

clean:
	-rm bin/*

tk: clean
	$(LISP) --load mx-proxy.asd \
		--eval "(ql:quickload '(:mx-proxy :mx-proxy/tk))" \
		--eval "(asdf:make :mx-proxy/tk)" \
		--eval "(quit)"

qt: clean
	$(LISP) --load mx-proxy.asd \
		--eval "(ql:quickload '(:mx-proxy :mx-proxy/qt))" \
		--eval "(asdf:make :mx-proxy/qt)" \
		--eval "(quit)"

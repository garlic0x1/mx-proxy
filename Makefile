LISP ?= ${shell which sbcl}

clean:
	rm bin/*

tk: clean
	$(LISP) --load proxy.asd \
		--eval "(ql:quickload '(:proxy :proxy/tk))" \
		--eval "(asdf:make :proxy/tk)" \
		--eval "(quit)"

qt: clean
	$(LISP) --load proxy.asd \
		--eval "(ql:quickload '(:proxy :proxy/qt))" \
		--eval "(asdf:make :proxy/qt)" \
		--eval "(quit)"

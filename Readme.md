An interactive web proxy.

# Tk frontend

Depends on:
- SBCL + Quicklisp
- FiloSottile/mkcert
- SQLite
- Tk/Tcl

```bash
make tk
```

![Tk](screenshots/tk-frontend.png)　

# Lem frontend

Depends on:
- Lem
- FiloSottile/mkcert
- SQLite

```lisp
(ql:quickload '(:mx-proxy :mx-proxy/lem))
```

![Lem](screenshots/lem-frontend.png)　

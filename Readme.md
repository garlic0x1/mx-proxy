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

# Hooks

The proxy server uses the following hooks which you can attach functions to:
- :on-request      - args: http:request
- :on-response     - args: http:request http:response
- :on-message-pair - args: http:message-pair

# Commands

In Tk and Qt frontends, use `define-command` to add interactive functionality.

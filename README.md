An interactive web proxy.

# Tk frontend

Depends on:
- SBCL + Quicklisp
- [FiloSottile/mkcert](https://github.com/FiloSottile/mkcert)
- SQLite
- Tk/Tcl

```bash
make tk
```

![Tk](screenshots/tk-frontend.png)　

# Lem frontend

Depends on:
- Lem
- [FiloSottile/mkcert](https://github.com/FiloSottile/mkcert)
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
- :init            - args: (none)

# Commands

Use `define-command` to add interactive functionality. The `mx-proxy` namespace
exports this macro in Tk and Qt frontends, Lem has its own implementation which
behaves the same.

# Installation notes

Make sure `mkcert` is in your path and you have run `mkcert -install` and restarted your browser.

An interactive web proxy for debugging and testing HTTP servers.
Automatically generates certificates to intercept and decrypt SSL messages.

# Dependencies

- SBCL + [Ultralisp](https://ultralisp.org)
- [FiloSottile/mkcert](https://github.com/FiloSottile/mkcert)
- SQLite
- GTK4 or Tcl/Tk

# GTK frontend

This is the best looking frontend, but still has some missing features.

```bash
make gtk
```

![GTK](screenshots/gtk-frontend.png)　

# Tk frontend

NOTE: Currently unmaintained, I like GTK more.  It should still work for basic stuff.

```bash
make tk
```

![Tk](screenshots/tk-frontend.png)　

# Hooks

The proxy server uses the following hooks which you can attach functions to:
| Hook               | Args               |
| ------------------ | ------------------ |
| :on-request        | request            |
| :on-response       | request response   |
| :on-message-pair   | message-pair       |
| :init              | (none)             |
| :on-command        | command            |
| :on-load-project   | (none)             |

# Commands

The `mx-proxy` namespace exports a macro called `define-command` which you can
use to add your own interactive functionality.  Example:

```lisp
(define-command divide-by-zero (num sure) ("iNumber" "bAre you sure?")
  (when sure (with-ui-errors (/ num 0))))
```

# Configuration

The configuration directory is one of the following, in descending priority:
- `~/.config/mx-proxy/`
- `~/.mx-proxy/`
- `$MX_PROXY_HOME`

Persistent settings are stored in `config.lisp` as a plist dictionary.
After the program has loaded, it will also load `init.lisp`, you can load
any external packages you want from here.

# Installation notes

Make sure `mkcert` is in your path and you have run `mkcert -install` and restarted your browser.

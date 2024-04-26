Features:
- Qt (or GTK?) frontend
- server global status variable, for modeline and restarting
- widgets for messages, maybe flash on modeline too
- GTK focus entry on prompt

Bugs:
- Google SSL stopped working (wtf?)
- server concurrency feels slow
- chunked encoding decompression is weird
- Tk: make all prompts/messages close on escape/cancel
- port left open on stop-server (need to panic out of the server loop)

Done:
- parse headers again on replay (might have added bugs :{)

# TODO

## Features:
- CLOG modeline

## Bugs:
- server concurrency feels slow
- chunked encoding decompression is weird

# Done:

## Bugs:
- parse headers again on replay (might have added bugs :{) (fixed)
- Google SSL stopped working (wtf?) (now it works?)
- port left open on stop-server (need to panic out of the server loop)
- Tk: make all prompts/messages close on escape/cancel (dont care)
- SSL replays are broken (fixed)

## Features:
- widgets for messages, maybe flash on modeline too (buggy rn)
- GTK focus entry on prompt
- server global status variable, for modeline and restarting

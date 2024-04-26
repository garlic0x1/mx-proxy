# TODO

## Features:
- widgets for messages, maybe flash on modeline too (buggy rn)

## Bugs:
- server concurrency feels slow
- chunked encoding decompression is weird
- Tk: make all prompts/messages close on escape/cancel

# Done:

## Bugs:
- parse headers again on replay (might have added bugs :{)
- Google SSL stopped working (wtf?) (now it works?)
- port left open on stop-server (need to panic out of the server loop)

## Features:
- GTK focus entry on prompt
- server global status variable, for modeline and restarting

import std/strformat
import sdl

const
    WinW = 1280
    WinH = 800

echo fmt"Nim version: {NimVersion}"
echo fmt"SDL version: {sdl.get_version()}"

init(ifVideo or ifEvents)
let window = create_window("SDL + BGFX", WinW, WinH, wfResizable)

var running = true
while running:
    for event in get_events():
        case event.kind
        of ekQuit:
          running = false
        of ekKeyDown:
            case event.key.keysym.sym
            of Key_Escape: running = false
            else: discard
        else: discard

destroy_window window
sdl.quit()

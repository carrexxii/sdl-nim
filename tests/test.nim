import std/strformat
import sdl

const
    WinW = 1280
    WinH = 800

echo fmt"Nim version: {NimVersion}"
echo fmt"SDL version: {sdl.get_version()}"

init(VideoFlag, EventsFlag)
let window = sdl.create_window("SDL + BGFX", WinW, WinH, sdl.WindowResizable)

var running = true
while running:
    for event in get_event():
        case event.kind
        of Quit: running = false
        of KeyUp: discard
        of KeyDown:
            case event.key.keysym.sym
            of Key_Escape: running = false
            else: discard

close_window window
sdl.quit()

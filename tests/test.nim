import std/[strformat, options]
import nsdl

const
    WinW = 1280
    WinH = 800

echo fmt"Nim version: {NimVersion}"
echo fmt"SDL version: {nsdl.get_version()}"

init(Video or Events)
let (window, renderer) = create_window_and_renderer("SDL + BGFX", WinW, WinH, Resizable)
set_draw_colour(renderer, Colour(r: 0, g: 77, b: 33, a: 255))
clear renderer

var running = true
while running:
    for event in get_events():
        case event.kind
        of Quit:
          running = false
        of KeyDown:
            case event.key.keysym.sym
            of Key_Escape: running = false
            else: discard
        else: discard

    # clear renderer
    fill renderer
    present renderer

destroy_window window
nsdl.quit()

import std/[strformat, options]
import nsdl, nsdl/ttf

const
    WinW = 1280
    WinH = 800

echo fmt"Nim version    : {NimVersion}"
echo fmt"SDL version    : {nsdl.get_version()}"
echo fmt"SDL_ttf version: {ttf.get_version()}"

if not init(Video or Events, should_init_ttf = true):
    echo "Failed to initialize SDL"
    quit 1

let (window, renderer) = create_window_and_renderer("SDL Tests", WinW, WinH, Resizable)
renderer.set_draw_colour Olive

let font = open_font "tests/fonts/fantasque.ttf"
let msg = get font.render("Hello, World!", Black)
let tex = get renderer.create_texture msg

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

    fill renderer
    renderer.texture tex
    present renderer

close font
destroy window
nsdl.quit()

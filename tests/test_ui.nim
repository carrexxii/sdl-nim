import std/[strformat, options]
import nsdl, nsdl/ttf, nsdl/ui
from std/sugar import `=>`

const
    WinW = 1280
    WinH = 800
    FontName = "fantasque"

echo fmt"Nim version    : {NimVersion}"
echo fmt"SDL version    : {sdl_version()}"
echo fmt"SDL_ttf version: {ttf_version()}"

init(Video or Events, should_init_ttf = true)

let (window, renderer) = create_window_and_renderer("SDL UI Tests", WinW, WinH, Resizeable)
renderer.set_draw_colour Olive

let font = open_font fmt"tests/fonts/{FontName}.ttf"
font.set_size 16

var ui_ctx = ui.create_context(renderer, font)

var p = ui_ctx.add_panel(100, 100, 300, 700)
discard p.add_object(Button, 0, 50 , 75, 35, text = "Button1", cb = (_: UIObject) => echo 1)
discard p.add_object(text = "Button2", cb = (_: UIObject) => echo 2)
discard p.add_object(text = "Button3", cb = (_: UIObject) => echo 3)

var p2 = ui_ctx.add_panel(500, 100, 300, 700)
p2.add_objects(Button, 10, 10, 100, 40, dir = Horizontal, padding = 15, objs = [
    ("Button4", CallbackFn (_: UIObject) => echo 4),
    ("Button5", CallbackFn (_: UIObject) => echo 5),
    ("Button6", CallbackFn (_: UIObject) => echo 6),
])

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

    update ui_ctx

    renderer.set_draw_colour Black
    fill renderer

    draw ui_ctx

    present renderer

close font
destroy window
nsdl.quit()

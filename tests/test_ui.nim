import std/[strformat, options]
import nsdl, nsdl/ttf, nsdl/ui

const
    WinW = 1280
    WinH = 800
    FontName = "fantasque"

echo fmt"Nim version    : {NimVersion}"
echo fmt"SDL version    : {nsdl.get_version()}"
echo fmt"SDL_ttf version: {ttf.get_version()}"

init(Video or Events, should_init_ttf = true)

let (window, renderer) = create_window_and_renderer("SDL UI Tests", WinW, WinH, Resizeable)
renderer.set_draw_colour Olive

let font = open_font fmt"tests/fonts/{FontName}.ttf"
font.set_size 16

var ui_ctx = ui.create_context(renderer, font)
ui_ctx.add_object(Button, 50, 50 , 75, 35, text = "Button1")
ui_ctx.add_object(Button, 50, 100, 75, 35, text = "Button2")

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

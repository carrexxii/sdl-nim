import std/[strformat, sugar]
import sdl, sdl/[renderer, ttf, pixels, ui]

const
    WinW = 1280
    WinH = 800
    FontName = "fantasque"

echo &"Nim version    : {NimVersion}"
echo &"SDL version    : {sdl.version()}"
echo &"SDL_ttf version: {ttf.version()}"

assert init(initVideo or initEvents)
assert ttf.init()

let (win, ren) = create_window_and_renderer("SDL UI Tests", WinW, WinH, winResizeable)
ren.draw_colour = Olive

let font = open_font &"tests/fonts/{FontName}.ttf"
font.sz = 16

var ui_ctx = ren.create_context font

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
    for event in events():
        case event.kind
        of eventQuit:
            running = false
        of eventKeyDown:
            case event.kb.key
            of kcEscape: running = false
            else: discard
        else: discard

    update ui_ctx

    ren.draw_colour = Black
    fill ren

    draw ui_ctx

    present ren

sdl.quit()

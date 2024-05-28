import
    std/options,
    common, rect, pixels, renderer, events, ttf
from std/sugar import `->`

type
    UIID* = tuple[panel, index: int16]

    Triple = object
        default: Colour
        hovered: Colour
        clicked: Colour
    UITheme* = object
        font_size* = 18
        font*   = colour(225, 225, 225)
        bg*     = colour(45 , 45 , 45 )
        panel*  = colour(45 , 45 , 45 )
        button* = Triple(default: colour(30 , 70 , 155),
                         hovered: colour(50 , 90 , 205),
                         clicked: colour(70 , 110, 235))

    UIPanelKind* = enum
        Absolute
        Relative
    UIPanel* = ref object
        z*      : int
        hovered*: bool
        case kind*: UIPanelKind
        of Absolute: recti*: Rect
        of Relative: rectf*: FRect

    UIObjectKind* = enum
        Button
    UIObject* = ref object
        rect*   : Rect
        z*      : int
        hovered*: bool
        clicked*: bool
        case kind*: UIObjectKind
        of Button:
            cb*       : UIObject -> void
            has_text* : bool
            text*     : Texture
            text_rect*: FRect

    UIContext* = object
        renderer*: Renderer
        theme*   : UITheme
        objs*    : seq[UIObject]
        panels*  : seq[UIPanel]
        font*    : Font

func create_context*(renderer: Renderer; font: Font; theme = UITheme()): UIContext =
    assert(ttf.was_init() != 0, "UI needs TTF initialized")
    font.set_size theme.font_size
    result = UIContext(
        renderer: renderer,
        theme   : theme,
        objs    : @[],
        font    : font
    )

proc add_object*(ctx: var UIContext; kind: UIObjectKind; x, y, w, h: int; text = ""; cb: (UIObject -> void) = nil): UIObject =
    case kind
    of Button:
        if text != "":
            let text_surf = ctx.font.render_blended(text, ctx.theme.font)
            let text_tex  = ctx.renderer.create_texture text_surf
            let (tw, th)  = ctx.font.size text
            let trect = frect((float x) + w/2 - tw/2,
                              (float y) + h/2 - th/2,
                              float tw, float th)
            result = UIObject(kind: kind, rect: rect(x, y, w, h), cb: cb,
                              has_text: true, text_rect: trect, text: text_tex)

    ctx.objs.add result

var
    hot_obj: UIObject
    lmb_prev = false
proc update*(ctx: UIContext) =
    let (btns, x, y) = get_mouse_state()
    let lmb_state = if Left in btns: true else: false
    let lmb_changed = lmb_state != lmb_prev

    for obj in ctx.objs:
        if (x, y) in obj.rect:
            obj.hovered = true
            obj.clicked = lmb_state
            if lmb_changed:
                if obj == hot_obj and not lmb_state:
                    hot_obj = nil
                    if not is_nil obj.cb:
                        obj.cb obj
                elif lmb_state:
                    hot_obj = obj
        else:
            obj.hovered = false
            obj.clicked = false

    lmb_prev = lmb_state

proc draw*(ctx: UIContext) =
    template get_colour(obj, cset): Colour =
        if   obj.clicked: cset.clicked
        elif obj.hovered: cset.hovered
        else: cset.default

    let ren = ctx.renderer
    for obj in ctx.objs:
        let colour = obj.get_colour ctx.theme.button
        ren.set_draw_colour colour
        ren.draw_fill_rect obj.rect
        case obj.kind
        of Button:
            if not obj.has_text:
                continue
            ren.draw_texture(obj.text, obj.text_rect)

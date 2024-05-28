import
    std/options,
    common, rect, pixels, renderer, events, ttf
from std/sugar import `->`

type
    CallbackFn* = UIObject -> void

    UIDirection* = enum
        Horizontal
        Vertical

    UITheme* = tuple[default: Colour,
                     hovered: Colour,
                     clicked: Colour]
    UIThemeSet* = object
        font_size* = 18
        font*   = colour(225, 225, 225)
        bg*     = colour(45 , 45 , 45 )
        panel*  = colour(45 , 45 , 45 )
        button*: UITheme =
            (default: colour(30 , 70 , 155),
             hovered: colour(50 , 90 , 205),
             clicked: colour(70 , 110, 235))

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
            text_rect*: Rect

    UIPanel* = ref object
        ctx*    : UIContext
        hovered*: bool
        rect*   : Rect
        z*      : int
        objs*   : seq[UIObject]

    UIContext* = ref object
        renderer*: Renderer
        theme*   : UIThemeSet
        rect*    : Rect
        panels*  : seq[UIPanel]
        font*    : Font

func create_context*(renderer: Renderer; font: Font; theme = UIThemeSet(); rect = Rect()): UIContext =
    assert(ttf.was_init() != 0, "UI needs TTF initialized")
    font.set_size theme.font_size

    var ui_rect: Rect
    if rect.w == 0 or rect.h == 0:
        let (w, h) = get_output_size renderer
        ui_rect = rect(0, 0, w, h)
    else:
        ui_rect = rect

    result = UIContext(
        renderer: renderer,
        theme   : theme,
        rect    : ui_rect,
        panels  : @[],
        font    : font,
    )

proc add_panel*(ctx: var UIContext; x, y, w, h: Natural): UIPanel =
    result = UIPanel(
        ctx : ctx,
        rect: rect(x, y, w, h),
        z   : ctx.panels.len,
        objs: @[],
    )
    ctx.panels.add result

proc add_object*(panel: var UIPanel; kind: UIObjectKind; x, y, w, h: int; text = ""; cb: CallbackFn = nil; z = -1): UIObject =
    let ctx  = panel.ctx
    let objz = if z == -1: panel.z else: z
    case kind
    of Button:
        if text != "":
            let text_surf = ctx.font.render_blended(text, ctx.theme.font)
            let text_tex  = ctx.renderer.create_texture text_surf
            let (tw, th)  = ctx.font.size text
            let trect = rect((float panel.rect.x + x) + w/2 - tw/2,
                             (float panel.rect.y + y) + h/2 - th/2,
                             float tw, float th)
            result = UIObject(kind: kind, rect: rect(panel.rect.x + x, panel.rect.y + y, w, h), z: objz,
                              cb: cb, has_text: true, text_rect: trect, text: text_tex)

    panel.objs.add result

## Automatic positioning based off of the previous object added
proc add_object*(panel: var UIPanel; dir: UIDirection = Vertical; padding = 5; text = ""; cb: CallbackFn = nil; z = -1): UIObject =
    assert(panel.objs.len > 0, "Automatic positioning requires at least one object")
    let
        last = panel.objs[panel.objs.len - 1]
        x = (if dir == Horizontal: last.rect.x + last.rect.w + padding else: last.rect.x) - panel.rect.x
        y = (if dir == Vertical  : last.rect.y + last.rect.h + padding else: last.rect.y) - panel.rect.y
    panel.add_object(last.kind, x, y, last.rect.w, last.rect.h, text, cb, z)

## Automatic positioning for a list of objects
proc add_objects*(panel: var UIPanel; kind: UIObjectKind; x, y, w, h: int; objs: openArray[tuple[text: string, cb: CallbackFn]]; dir: UIDirection = Vertical; padding = 5; z = -1) =
    discard panel.add_object(kind, x, y, w, h, text = objs[0].text, cb = objs[0].cb, z = z)
    for obj in objs[1..^1]:
        discard panel.add_object(dir, padding, obj.text, obj.cb, z)

var
    hot_obj: UIObject
    lmb_prev = false
proc update*(ctx: UIContext) =
    if ctx.panels.len < 1 or ctx.panels[0].objs.len < 1:
        return

    let (btns, mx, my) = get_mouse_state()
    let lmb_state   = if Left in btns: true else: false
    let lmb_changed = lmb_state != lmb_prev

    var target: UIObject
    for panel in ctx.panels:
        if (mx, my) notin panel.rect:
            continue

        for obj in panel.objs:
            if (target != nil and target.z > obj.z) or (mx, my) notin obj.rect:
                obj.hovered = false
                obj.clicked = false
                continue

            # This object overrides the previous via z-level
            if target != nil:
                target.hovered = false
                target.clicked = false
            target = obj

            obj.hovered = true
            obj.clicked = lmb_state
            if lmb_changed:
                if obj == hot_obj and not lmb_state:
                    hot_obj = nil
                    if not is_nil obj.cb:
                        obj.cb obj
                elif lmb_state:
                    hot_obj = obj

    lmb_prev = lmb_state

proc draw*(ctx: UIContext) =
    template get_colour(obj, cset): Colour =
        if   obj.clicked: cset.clicked
        elif obj.hovered: cset.hovered
        else: cset.default

    let ren = ctx.renderer
    for panel in ctx.panels:
        for obj in panel.objs:
            let colour = obj.get_colour ctx.theme.button
            ren.set_draw_colour colour
            ren.draw_fill_rect obj.rect
            case obj.kind
            of Button:
                if not obj.has_text:
                    continue
                ren.draw_texture(obj.text, frect obj.text_rect)

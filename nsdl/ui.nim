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
        panel*: UITheme =
            (default: colour(15, 15, 55),
             hovered: colour(15, 15, 95),
             clicked: colour(15, 15, 125))
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
        clicked*: bool
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
            let trect = rect(w/2 - tw/2, h/2 - th/2, float tw, float th)
            result = UIObject(kind: kind, rect: rect(x, y, w, h), z: objz, cb: cb,
                              has_text: true, text_rect: trect, text: text_tex)

    panel.objs.add result

## Automatic positioning based off of the previous object added
proc add_object*(panel: var UIPanel; dir: UIDirection = Vertical; padding = 5; text = ""; cb: CallbackFn = nil; z = -1): UIObject =
    assert(panel.objs.len > 0, "Automatic positioning requires at least one previous object")
    let
        last = panel.objs[panel.objs.len - 1]
        x = if dir == Horizontal: last.rect.x + last.rect.w + padding else: last.rect.x
        y = if dir == Vertical  : last.rect.y + last.rect.h + padding else: last.rect.y
    panel.add_object(last.kind, x, y, last.rect.w, last.rect.h, text, cb, z)

## Automatic positioning for a list of objects
proc add_objects*(panel: var UIPanel; kind: UIObjectKind; x, y, w, h: int; objs: openArray[tuple[text: string, cb: CallbackFn]]; dir: UIDirection = Vertical; padding = 5; z = -1) =
    discard panel.add_object(kind, x, y, w, h, text = objs[0].text, cb = objs[0].cb, z = z)
    for obj in objs[1..^1]:
        discard panel.add_object(dir, padding, obj.text, obj.cb, z)

var
    target : UIObject
    hot_obj: UIObject
    lmb_prev = false
proc update*(ctx: UIContext) =
    if ctx.panels.len < 1 or ctx.panels[0].objs.len < 1:
        return

    let (btns, mx, my) = get_mouse_state()
    let lmb_state   = if Left in btns: true else: false
    let lmb_changed = lmb_state != lmb_prev

    var no_panel_hit = true
    for panel in ctx.panels:
        panel.hovered = (mx, my) in panel.rect
        if not panel.hovered:
            continue

        no_panel_hit = false
        target = nil
        for obj in panel.objs:
            let relx = mx - panel.rect.x
            let rely = my - panel.rect.y
            if (target != nil and target.z > obj.z) or (relx, rely) notin obj.rect:
                obj.hovered = false
                obj.clicked = false
                continue

            # This object overrides the previous via z-level
            if target != nil:
                target.hovered = false
                target.clicked = false
            target = obj

            # Check if the object is hot/the one originally clicked on
            if lmb_changed:
                if obj == hot_obj and not lmb_state:
                    hot_obj = nil
                    if not is_nil obj.cb:
                        obj.cb obj
                elif lmb_state:
                    hot_obj = obj

            obj.hovered = true
            obj.clicked = lmb_state and hot_obj == obj

    if target != nil and no_panel_hit:
        target.hovered = false
        target.clicked = false
    lmb_prev = lmb_state

proc draw*(ctx: UIContext) =
    template get_colour(obj, cset): Colour =
        if   obj.clicked: cset.clicked
        elif obj.hovered: cset.hovered
        else: cset.default

    let ren = ctx.renderer
    for panel in ctx.panels:
        let colour = panel.get_colour ctx.theme.panel
        ren.set_draw_colour colour
        ren.draw_fill_rect panel.rect
        for obj in panel.objs:
            # Clipping
            let w = if obj.rect.x + obj.rect.w > panel.rect.w: panel.rect.w - obj.rect.x else: obj.rect.w
            let h = if obj.rect.y + obj.rect.h > panel.rect.h: panel.rect.h - obj.rect.y else: obj.rect.h
            ren.set_draw_colour (obj.get_colour ctx.theme.button)
            ren.draw_fill_rect frect(panel.rect.x + obj.rect.x, panel.rect.y + obj.rect.y, w, h)

            case obj.kind
            of Button:
                if not obj.has_text:
                    continue

                let
                    tx = panel.rect.x + obj.rect.x + obj.text_rect.x
                    ty = panel.rect.y + obj.rect.y + obj.text_rect.y
                    tw = if obj.text_rect.x + obj.text_rect.w > w: w - obj.text_rect.x else: obj.text_rect.w
                    th = if obj.text_rect.y + obj.text_rect.h > h: h - obj.text_rect.y else: obj.text_rect.h
                ren.draw_texture(obj.text, dst_rect = frect(tx, ty, tw, th),
                                           src_rect = frect(0 , 0 , tw, th))


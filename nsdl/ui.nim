import common, rect, pixels, renderer, ttf

type
    UITheme* = object
        font_size* = 18
        font*   = colour(225, 225, 225)
        bg*     = colour(45 , 45 , 45)
        button* = colour(30 , 70 , 155)

    UIObjectKind* = enum
        Button
    UIObject* = ref object
        rect*   : Rect
        hovered*: bool
        clicked*: bool
        hot*    : bool
        case kind*: UIObjectKind
        of Button:
            has_text* : bool
            text*     : Texture
            text_rect*: FRect

    UIContext* = object
        renderer*: Renderer
        theme*   : UITheme
        objs*    : seq[UIObject]
        font*    : Font

func create_context*(renderer: Renderer; font: Font; theme = UITheme()): UIContext =
    assert(ttf.was_init() != 0, "UI needs TTF initialized")
    font.set_size theme.font_size
    result = UIContext(
        renderer: renderer,
        theme   : theme,
        objs    : new_seq_of_cap[UIObject] 32,
        font    : font
    )

proc add_object*(ctx: var UIContext; kind: UIObjectKind; x, y, w, h: int; text = "") =
    var obj: UIObject
    case kind
    of Button:
        if text != "":
            let text_surf = ctx.font.render_lcd(text, ctx.theme.font, ctx.theme.button)
            let text_tex  = ctx.renderer.create_texture text_surf
            let (tw, th)  = ctx.font.size text
            let trect = frect((float x) + w/2 - tw/2,
                              (float y) + h/2 - th/2,
                              float tw, float th)
            obj = UIObject(kind: kind, rect: rect(x, y, w, h),
                           has_text: true, text_rect: trect, text: text_tex)

    ctx.objs.add obj

proc update*(ctx: UIContext) =
    

proc draw*(ctx: UIContext) =
    let ren = ctx.renderer
    for obj in ctx.objs:
        ren.set_draw_colour ctx.theme.button
        ren.draw_fill_rect obj.rect
        case obj.kind
        of Button:
            if not obj.has_text:
                continue
            ren.draw_texture(obj.text, obj.text_rect)

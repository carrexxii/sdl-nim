import std/options, common, pixels, rect, surface, video

const SoftwareRenderer* = "software"

type RendererFlag* {.size: sizeof(uint32).} = enum
    # renSoftware      = 0x0000_0001
    # renAccelerated   = 0x0000_0002
    renPresentVSync  = 0x0000_0004
    # renTargetTexture = 0x0000_0008
func `or`*(a, b: RendererFlag): RendererFlag =
    RendererFlag (a.ord or b.ord)

type
    TextureAccess* {.size: sizeof(int32).} = enum
        texAccessStatic
        texAccessStreaming
        texAccessTarget

    LogicalPresent* {.size: sizeof(int32).} = enum
        presentDisabled
        presentStretch
        presentLetterbox
        presentOverscan
        presentIntegerScale

type
    Renderer* = distinct pointer
    Texture*  = distinct pointer

    RendererInfo* = object
        name*         : cstring
        flags*        : RendererFlag
        tex_fmt_count*: int32
        tex_fmts*     : ptr UncheckedArray[PixelFormat]
        max_tex_w*    : int32
        max_tex_h*    : int32

    Vertex* = object
        pos*      : FPoint
        colour*   : FColour
        tex_coord*: FPoint

func vertex*(x, y, r, g, b, a, u, v: float32 = 0.0): Vertex =
    Vertex(pos      : FPoint(x: x, y: y),
           colour   : FColour(r: r, g: g, b: b, a: a),
           tex_coord: FPoint(x: u, y: v))

func vertex*(x, y: float32 = 0.0; rgba = FColour(); u, v: float32 = 0.0): Vertex =
    vertex x, y, rgba.r, rgba.g, rgba.b, rgba.a, u, v

func vertex*(xy = FPoint(); rgba = FColour(); uv = FPoint()): Vertex =
    vertex xy.x, xy.y, rgba.r, rgba.g, rgba.b, rgba.a, uv.x, uv.y

#[ -------------------------------------------------------------------- ]#

type
    BlendMode* {.size: sizeof(uint32).} = enum
        blendNone    = 0x0000_0000
        blendBlend   = 0x0000_0001
        blendAdd     = 0x0000_0002
        blendMod     = 0x0000_0004
        blendMul     = 0x0000_0008
        blendInvalid = 0x7FFF_FFFF

    BlendOperation* {.size: sizeof(int32).} = enum
        blendAdd         = 0x1
        blendSubtract    = 0x2
        blendRevSubtract = 0x3
        blendMinimum     = 0x4
        blendMaximum     = 0x5

    BlendFactor* {.size: sizeof(int32).} = enum
        blendZero              = 0x1
        blendOne               = 0x2
        blendSrcColour         = 0x3
        blendOneMinusSrcColour = 0x4
        blendSrcAlpha          = 0x5
        blendOneMinusSrcAlpha  = 0x6
        blendDstColour         = 0x7
        blendOneMinusDstColour = 0x8
        blendDstAlpha          = 0x9
        blendOneMinusDstAlpha  = 0xA

proc compose_custom_blendmode*(src_colour, dst_colour: BlendFactor; colour_op: BlendOperation;
                               src_alpha , dst_alpha : BlendFactor; alpha_op : BlendOperation): BlendMode
    {.importc: "SDL_ComposeCustomBlendMode".}

#[ -------------------------------------------------------------------- ]#

from properties import PropertyId

using
    ren      : Renderer
    win      : Window
    win_flags: WindowFlag
    ren_flags: RendererFlag
    surf     : Surface
    tex      : Texture

{.push dynlib: SdlLib.}
proc sdl_get_num_render_drivers*(): cint                                                    {.importc: "SDL_GetNumRenderDrivers"       .}
proc sdl_get_render_driver*(index: cint): cstring                                           {.importc: "SDL_GetRenderDriver"           .}
proc sdl_create_renderer*(win; name: cstring; ren_flags): pointer                           {.importc: "SDL_CreateRenderer"            .}
proc sdl_create_software_renderer*(surf): pointer                                           {.importc: "SDL_CreateSoftwareRenderer"    .}
proc sdl_get_renderer*(win): pointer                                                        {.importc: "SDL_GetRenderer"               .}
proc sdl_get_renderer_window*(ren): pointer                                                 {.importc: "SDL_GetRenderWindow"           .}
proc sdl_get_renderer_name*(ren): cstring                                                   {.importc: "SDL_GetRendererName"           .}
proc sdl_get_renderer_properties*(ren): PropertyID                                          {.importc: "SDL_GetRendererProperties"     .}
proc sdl_get_renderer_output_size*(ren; w, h: ptr cint): SdlBool                            {.importc: "SDL_GetRenderOutputSize"       .}
proc sdl_get_current_renderer_output_size*(ren; w, h: ptr cint): SdlBool                    {.importc: "SDL_GetCurrentRenderOutputSize".}
proc sdl_get_renderer_from_texture*(tex): pointer                                           {.importc: "SDL_GetRendererFromTexture"    .}
proc sdl_create_texture*(ren; fmt: PixelFormat; access: TextureAccess; w, h: cint): pointer {.importc: "SDL_CreateTexture"             .}
proc sdl_create_texture_from_surface*(ren; surf): pointer                                   {.importc: "SDL_CreateTextureFromSurface"  .}
proc sdl_set_render_scale*(ren; x, y: cfloat): SdlBool                                      {.importc: "SDL_SetRenderScale"            .}
proc sdl_get_render_scale*(ren; x, y: ptr cfloat): SdlBool                                  {.importc: "SDL_GetRenderScale"            .}
proc sdl_set_render_draw_colour*(ren; r, g, b, a: uint8): SdlBool                           {.importc: "SDL_SetRenderDrawColor"        .}
proc sdl_get_render_draw_colour*(ren; r, g, b, a: ptr uint8): SdlBool                       {.importc: "SDL_GetRenderDrawColor"        .}
proc sdl_set_render_draw_colour_float*(ren; r, g, b, a: cfloat): SdlBool                    {.importc: "SDL_SetRenderDrawColorFloat"   .}
proc sdl_get_render_draw_colour_float*(ren; r, g, b, a: ptr cfloat): SdlBool                {.importc: "SDL_GetRenderDrawColorFloat"   .}
proc sdl_set_render_colour_scale*(ren; scale: cfloat): SdlBool                              {.importc: "SDL_SetRenderColorScale"       .}
proc sdl_get_render_colour_scale*(ren; scale: ptr cfloat): SdlBool                          {.importc: "SDL_GetRenderColorScale"       .}
proc sdl_set_render_draw_blend_mode*(ren; mode: BlendMode): SdlBool                         {.importc: "SDL_SetRenderDrawBlendMode"    .}
proc sdl_get_render_draw_blend_mode*(ren; mode: ptr BlendMode): SdlBool                     {.importc: "SDL_GetRenderDrawBlendMode"    .}

proc sdl_render_clear*(ren): SdlBool                                     {.importc: "SDL_RenderClear"    .}
proc sdl_render_point*(ren; x, y: cfloat): SdlBool                       {.importc: "SDL_RenderPoint"    .}
proc sdl_render_points*(ren; points: ptr FPoint; count: cint): SdlBool   {.importc: "SDL_RenderPoints"   .}
proc sdl_render_line*(ren; x1, y1, x2, y2: cfloat): SdlBool              {.importc: "SDL_RenderLine"     .}
proc sdl_render_lines*(ren; points: ptr FPoint; count: cint): SdlBool    {.importc: "SDL_RenderLines"    .}
proc sdl_render_rect*(ren; rect: ptr FRect): SdlBool                     {.importc: "SDL_RenderRect"     .}
proc sdl_render_rects*(ren; rects: ptr FRect; count: cint): SdlBool      {.importc: "SDL_RenderRects"    .}
proc sdl_render_fill_rect*(ren; rect: ptr FRect): SdlBool                {.importc: "SDL_RenderFillRect" .}
proc sdl_render_fill_rects*(ren; rects: ptr FRect; count: cint): SdlBool {.importc: "SDL_RenderFillRects".}
proc sdl_render_texture*(ren; tex; src, dst: ptr FRect): SdlBool         {.importc: "SDL_RenderTexture"  .}
proc sdl_create_window_and_renderer*(title: cstring; w, h: cint; win_flags; win: ptr Window; ren: ptr Renderer): SdlBool     {.importc: "SDL_CreateWindowAndRenderer".}
proc sdl_render_texture_rotated*(ren; tex; src, dst: ptr FRect; angle: cdouble; center: ptr FPoint; flip: FlipMode): SdlBool {.importc: "SDL_RenderTextureRotated"   .}
proc sdl_render_geometry*(ren; tex; vertices: ptr Vertex; vertex_count: cint; indices: ptr cint; index_count: cint): SdlBool {.importc: "SDL_RenderGeometry"         .}
proc sdl_render_geometry_raw*(ren; tex; xys    : ptr cfloat; xy_stride    : cint;
                                        colours: ptr Colour; colour_stride: cint;
                                        uvs    : ptr cfloat; uv_stride    : cint;
                              vert_count: cint; inds: pointer; idx_count: cint; inds_sz: cint): SdlBool {.importc: "SDL_RenderGeometryRaw".}
proc sdl_render_geometry_raw_float*(ren; tex;
                                    xys    : ptr cfloat ; xy_stride    : cint;
                                    colours: ptr FColour; colour_stride: cint;
                                    uvs    : ptr cfloat ; uv_stride    : cint;
                                    vert_count: cint; inds: pointer; idx_count: cint; inds_sz: cint): SdlBool {.importc: "SDL_RenderGeometryRawFloat".}
proc sdl_render_read_pixels*(ren; rect: ptr Rect): pointer {.importc: "SDL_RenderReadPixels"             .} # TODO: this needs to be free'd
proc sdl_render_present*(ren): SdlBool                     {.importc: "SDL_RenderPresent"   , discardable.}
proc sdl_destroy_texture*(tex)                             {.importc: "SDL_DestroyTexture"               .}
proc sdl_destroy_renderer*(ren)                            {.importc: "SDL_DestroyRenderer"              .}
proc sdl_flush_renderer*(ren): SdlBool                     {.importc: "SDL_FlushRenderer"   , discardable.}

proc sdl_set_render_viewport*(ren; rect: ptr Rect): SdlBool {.importc: "SDL_SetRenderViewport".}
proc sdl_set_render_vsync*(ren; vsync: cint): SdlBool       {.importc: "SDL_SetRenderVSync"   .}
proc sdl_get_render_vsync*(ren; vsync: ptr cint): SdlBool   {.importc: "SDL_GetRenderVSync"   .}
proc sdl_set_render_target*(ren; tex): SdlBool              {.importc: "SDL_SetRenderTarget"  .}
{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}

proc `=destroy`*(tex) = sdl_destroy_texture tex
proc `=destroy`*(ren) = sdl_destroy_renderer ren

proc create_renderer*(surf): (Renderer, bool) =
    let ren = sdl_create_software_renderer surf
    result[0] = Renderer ren
    result[1] = ren != nil

proc create_renderer*(win; name = ""; flags = renPresentVSync): (Renderer, bool) =
    let name = if name != "": cstring name else: nil
    let ren = sdl_create_renderer(win, name, flags)
    result[0] = Renderer ren
    result[1] = ren != nil

proc create_window_and_renderer*(title: string; w, h: int; win_flags = winNone): (Window, Renderer, bool) =
    result[2] = sdl_create_window_and_renderer(cstring title, cint w, cint h, win_flags, result[0].addr, result[1].addr)

proc name*(ren): cstring =
    sdl_get_renderer_name ren

proc sz*(ren): tuple[x, y: int32] =
    assert not sdl_get_renderer_output_size(ren, result.x.addr, result.y.addr)

proc create_texture*(ren; w, h: int32; fmt = pxFmtRgba8; access = texAccessStatic): (Texture, bool) =
    let tex = sdl_create_texture(ren, fmt, access, w, h)
    result[0] = Texture tex
    result[1] = tex != nil

proc create_texture*(ren; surf): (Texture, bool) =
    let tex = sdl_create_texture_from_surface(ren, surf)
    result[0] = Texture tex
    result[1] = tex != nil

proc vsync*(ren): int32                = assert sdl_get_render_vsync(ren, result.addr)
proc scale*(ren): tuple[x, y: float32] = assert sdl_get_render_scale(ren, result.x.addr, result.y.addr)
proc draw_colour*(ren): Colour         = assert sdl_get_render_draw_colour(ren, result.r.addr, result.g.addr, result.b.addr, result.a.addr)
proc colour_scale*(ren): float32       = assert sdl_get_render_colour_scale(ren, result.addr)
proc blend_mode*(ren): BlendMode       = assert sdl_get_render_draw_blend_mode(ren, result.addr)

proc `viewport=`*(ren; rect: Rect)         = assert sdl_set_render_viewport(ren, rect.addr)
proc `vsync=`*(ren; vsync: int32)          = assert sdl_set_render_vsync(ren, vsync)
proc `target=`*(ren; tex)                  = assert sdl_set_render_target(ren, tex)
proc `scale=`*(ren; x = 0.0; y = 0.0)      = assert sdl_set_render_scale(ren, x, y)
proc `draw_colour=`*(ren; colour: Colour)  = assert sdl_set_render_draw_colour(ren, colour.r, colour.g, colour.b, colour.a)
proc `draw_colour=`*(ren; colour: FColour) = assert sdl_set_render_draw_colour_float(ren, colour.r, colour.g, colour.b, colour.a)
proc `colour_scale=`*(ren; scale: float32) = assert sdl_set_render_colour_scale(ren, scale)
proc `blend_mode=`*(ren; mode: BlendMode)  = assert sdl_set_render_draw_blend_mode(ren, mode)

proc reset_target*(ren) = assert sdl_set_render_target(ren, cast[Texture](nil))
proc clear*(ren)        = assert sdl_render_clear(ren)
proc fill*(ren)         = assert sdl_render_fill_rect(ren, nil)
proc present*(ren)      = assert sdl_render_present(ren)
proc flush*(ren)        = assert sdl_flush_renderer(ren)

proc draw_point*(ren; x, y: float32)          = assert sdl_render_point(ren, x, y)
proc draw_points*(ren; points: seq[FPoint])   = assert sdl_render_points(ren, points[0].addr, cint points.len)
proc draw_line*(ren; p1, p2: FPoint)          = assert sdl_render_line(ren, p1.x, p1.y, p2.x, p2.y)
proc draw_lines*(ren; points: seq[FPoint])    = assert sdl_render_lines(ren, points[0].addr, cint points.len)
proc draw_rect*(ren; rect: FRect)             = assert sdl_render_rect(ren, rect.addr)
proc draw_rects*(ren; rects: seq[FRect])      = assert sdl_render_rects(ren, rects[0].addr, cint rects.len)
proc draw_fill_rect*(ren; rect: FRect)        = assert sdl_render_fill_rect(ren, rect.addr)
proc draw_fill_rects*(ren; rects: seq[FRect]) = assert sdl_render_fill_rects(ren, rects[0].addr, cint rects.len)

proc draw_rect*(ren; rect: Rect)      = draw_rect(ren, frect(rect))
proc draw_fill_rect*(ren; rect: Rect) = draw_fill_rect(ren, frect(rect))

proc draw_texture*(ren; tex; dst_rect, src_rect = FRect()) =
    let src = if src_rect.w != 0.0 and src_rect.h != 0.0: src_rect.addr else: nil
    let dst = if dst_rect.w != 0.0 and dst_rect.h != 0.0: dst_rect.addr else: nil
    assert sdl_render_texture(ren, tex, src, dst), $get_error()

proc draw_texture*(ren; tex; angle: float; src_rect = FRect(); dst_rect = FRect(); centre = FPoint(); flip: FlipMode = flipNone) =
    let src = if src_rect.w != 0.0 and src_rect.h != 0.0: src_rect.addr else: nil
    let dst = if dst_rect.w != 0.0 and dst_rect.h != 0.0: dst_rect.addr else: nil
    assert sdl_render_texture_rotated(ren, tex, src, dst, angle, centre.addr, flip), $get_error()

proc draw_geometry*(ren; verts: openArray[Vertex]; inds: openArray[int32] = []; tex = none Texture) =
    let tex   = if is_some tex: cast[pointer](get tex) else: nil
    let vertc = cint verts.len
    let indc  = cint inds.len
    let inds  = if indc > 0: inds[0].addr else: nil
    assert sdl_render_geometry(ren, cast[Texture](tex), verts[0].addr, vertc, inds, indc), $get_error()

proc read_pixels*(ren; rect = Rect()): (Surface, bool) =
    let src = if rect.w != 0 and rect.h != 0: rect.addr else: nil
    let surf = sdl_render_read_pixels(ren, src)
    result[0] = cast[ptr Surface](surf)[]
    result[1] = surf != nil

{.pop.} # inline

import std/options, common, pixels, rect, blendmode, properties

const SoftwareRenderer* = "software"

type RendererFlag* {.size: sizeof(uint32).} = enum
    # renSoftware      = 0x0000_0001
    # renAccelerated   = 0x0000_0002
    renPresentVSync  = 0x0000_0004
    # renTargetTexture = 0x0000_0008
func `or`*(a, b: RendererFlag): RendererFlag =
    RendererFlag (a.ord or b.ord)

type
    TextureAccess* {.size: sizeof(cint).} = enum
        texAccessStatic
        texAccessStreaming
        texAccessTarget

    LogicalPresent* {.size: sizeof(cint).} = enum
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
        pos*      : SdlPointF
        colour*   : SdlColourF
        tex_coord*: SdlPointF

converter `Renderer -> bool`*(ren: Renderer): bool = cast[pointer](ren) != nil
converter `Texture -> bool`*(tex: Texture)  : bool = cast[pointer](tex) != nil

func vertex*(x, y, r, g, b, a, u, v: float32 = 0.0): Vertex =
    Vertex(pos      : SdlPointF(x: x, y: y),
           colour   : SdlColourF(r: r, g: g, b: b, a: a),
           tex_coord: SdlPointF(x: u, y: v))

func vertex*(x, y: float32 = 0.0; rgba = SdlColourF(); u, v: float32 = 0.0): Vertex =
    vertex x, y, rgba.r, rgba.g, rgba.b, rgba.a, u, v

func vertex*(xy = SdlPointF(); rgba = SdlColourF(); uv = SdlPointF()): Vertex =
    vertex xy.x, xy.y, rgba.r, rgba.g, rgba.b, rgba.a, uv.x, uv.y

#[ -------------------------------------------------------------------- ]#

import surface, video

using
    ren      : Renderer
    win      : Window
    win_flags: WindowFlag
    ren_flags: RendererFlag
    surf     : Surface
    tex      : Texture

{.push dynlib: SdlLib.}
proc sdl_get_num_render_drivers*(): cint                                  {.importc: "SDL_GetNumRenderDrivers"       .}
proc sdl_get_render_driver*(index: cint): cstring                         {.importc: "SDL_GetRenderDriver"           .}
proc sdl_create_renderer*(win; name: cstring; ren_flags): Renderer        {.importc: "SDL_CreateRenderer"            .}
proc sdl_create_software_renderer*(surf): Renderer                        {.importc: "SDL_CreateSoftwareRenderer"    .}
proc sdl_get_renderer*(win): Renderer                                     {.importc: "SDL_GetRenderer"               .}
proc sdl_get_renderer_window*(ren): Window                                {.importc: "SDL_GetRenderWindow"           .}
proc sdl_get_renderer_name*(ren): cstring                                 {.importc: "SDL_GetRendererName"           .}
proc sdl_get_renderer_properties*(ren): PropertiesId                      {.importc: "SDL_GetRendererProperties"     .}
proc sdl_get_renderer_output_size*(ren; w, h: ptr cint): bool             {.importc: "SDL_GetRenderOutputSize"       .}
proc sdl_get_current_renderer_output_size*(ren; w, h: ptr cint): bool     {.importc: "SDL_GetCurrentRenderOutputSize".}
proc sdl_set_render_scale*(ren; x, y: cfloat): bool                       {.importc: "SDL_SetRenderScale"            .}
proc sdl_get_render_scale*(ren; x, y: ptr cfloat): bool                   {.importc: "SDL_GetRenderScale"            .}
proc sdl_set_render_draw_colour*(ren; r, g, b, a: uint8): bool            {.importc: "SDL_SetRenderDrawColor"        .}
proc sdl_get_render_draw_colour*(ren; r, g, b, a: ptr uint8): bool        {.importc: "SDL_GetRenderDrawColor"        .}
proc sdl_set_render_draw_colour_float*(ren; r, g, b, a: cfloat): bool     {.importc: "SDL_SetRenderDrawColorFloat"   .}
proc sdl_get_render_draw_colour_float*(ren; r, g, b, a: ptr cfloat): bool {.importc: "SDL_GetRenderDrawColorFloat"   .}
proc sdl_set_render_colour_scale*(ren; scale: cfloat): bool               {.importc: "SDL_SetRenderColorScale"       .}
proc sdl_get_render_colour_scale*(ren; scale: ptr cfloat): bool           {.importc: "SDL_GetRenderColorScale"       .}
proc sdl_set_render_draw_blend_mode*(ren; mode: BlendMode): bool          {.importc: "SDL_SetRenderDrawBlendMode"    .}
proc sdl_get_render_draw_blend_mode*(ren; mode: ptr BlendMode): bool      {.importc: "SDL_GetRenderDrawBlendMode"    .}

proc sdl_render_clear*(ren): bool                                         {.importc: "SDL_RenderClear"    .}
proc sdl_render_point*(ren; x, y: cfloat): bool                           {.importc: "SDL_RenderPoint"    .}
proc sdl_render_points*(ren; points: ptr SdlPointF; count: cint): bool    {.importc: "SDL_RenderPoints"   .}
proc sdl_render_line*(ren; x1, y1, x2, y2: cfloat): bool                  {.importc: "SDL_RenderLine"     .}
proc sdl_render_lines*(ren; points: ptr SdlPointF; count: cint): bool     {.importc: "SDL_RenderLines"    .}
proc sdl_render_rect*(ren; rect: ptr SdlRectF): bool                      {.importc: "SDL_RenderRect"     .}
proc sdl_render_rects*(ren; rects: ptr SdlRectF; count: cint): bool       {.importc: "SDL_RenderRects"    .}
proc sdl_render_fill_rect*(ren; rect: ptr SdlRectF): bool                 {.importc: "SDL_RenderFillRect" .}
proc sdl_render_fill_rects*(ren; rects: ptr SdlRectF; count: cint): bool  {.importc: "SDL_RenderFillRects".}
proc sdl_render_texture*(ren; tex; src, dst: ptr SdlRectF): bool          {.importc: "SDL_RenderTexture"  .}
proc sdl_create_window_and_renderer*(title: cstring; w, h: cint; win_flags; win: ptr Window; ren: ptr Renderer): bool           {.importc: "SDL_CreateWindowAndRenderer".}
proc sdl_render_texture_rotated*(ren; tex; src, dst: ptr SdlRectF; angle: cdouble; center: ptr SdlPointF; flip: FlipMode): bool {.importc: "SDL_RenderTextureRotated"   .}
proc sdl_render_geometry*(ren; tex; vertices: ptr Vertex; vertex_count: cint; indices: ptr cint; index_count: cint): bool       {.importc: "SDL_RenderGeometry"         .}
proc sdl_render_geometry_raw*(ren; tex; xys    : ptr cfloat; xy_stride       : cint;
                                        colours: ptr SdlColour; colour_stride: cint;
                                        uvs    : ptr cfloat; uv_stride       : cint;
                              vert_count: cint; inds: pointer; idx_count: cint; inds_sz: cint): bool {.importc: "SDL_RenderGeometryRaw".}
proc sdl_render_geometry_raw_float*(ren; tex;
                                    xys    : ptr cfloat ; xy_stride       : cint;
                                    colours: ptr SdlColourF; colour_stride: cint;
                                    uvs    : ptr cfloat ; uv_stride       : cint;
                                    vert_count: cint; inds: pointer; idx_count: cint; inds_sz: cint): bool {.importc: "SDL_RenderGeometryRawFloat".}
proc sdl_render_read_pixels*(ren; rect: ptr SdlRect): Surface {.importc: "SDL_RenderReadPixels".}
proc sdl_render_present*(ren): bool                           {.importc: "SDL_RenderPresent"   .}
proc sdl_destroy_texture*(tex)                                {.importc: "SDL_DestroyTexture"  .}
proc sdl_destroy_renderer*(ren)                               {.importc: "SDL_DestroyRenderer" .}
proc sdl_flush_renderer*(ren): bool                           {.importc: "SDL_FlushRenderer"   .}

proc sdl_set_render_viewport*(ren; rect: ptr SdlRect): bool {.importc: "SDL_SetRenderViewport".}
proc sdl_set_render_vsync*(ren; vsync: cint): bool          {.importc: "SDL_SetRenderVSync"   .}
proc sdl_get_render_vsync*(ren; vsync: ptr cint): bool      {.importc: "SDL_GetRenderVSync"   .}
proc sdl_set_render_target*(ren; tex): bool                 {.importc: "SDL_SetRenderTarget"  .}

proc sdl_get_renderer_from_texture*(tex): Renderer                                          {.importc: "SDL_GetRendererFromTexture"  .}
proc sdl_create_texture*(ren; fmt: PixelFormat; access: TextureAccess; w, h: cint): Texture {.importc: "SDL_CreateTexture"           .}
proc sdl_create_texture_from_surface*(ren; surf): Texture                                   {.importc: "SDL_CreateTextureFromSurface".}
proc sdl_update_texture*(tex; rect: ptr SdlRect; pxs: pointer; pitch: cint): bool           {.importc: "SDL_UpdateTexture"           .}
proc sdl_set_texture_blend_mode*(tex; mode: BlendMode): bool                                {.importc: "SDL_SetTextureBlendMode"     .}

proc sdl_get_texture_properties*(tex: ptr Texture): uint32 {.importc: "SDL_GetTextureProperties".}
{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}

proc properties*(tex: ptr Texture): PropertiesId =
    PropertiesId sdl_get_texture_properties tex

proc `=destroy`*(tex) = sdl_destroy_texture  tex
proc `=destroy`*(ren) = sdl_destroy_renderer ren

proc create_renderer*(surf): Renderer =
    result = sdl_create_software_renderer surf
    sdl_assert result, &"Failed to create renderer for surface"

proc create_renderer*(win; name = ""; flags = renPresentVSync): Renderer =
    let name = if name != "": cstring name else: nil
    result = sdl_create_renderer(win, name, flags)
    sdl_assert result, &"Failed to create renderer for window"

proc create_window_and_renderer*(title: string; w, h: SomeInteger; win_flags = winNone): (Window, Renderer) =
    let success = sdl_create_window_and_renderer(cstring title, cint w, cint h, win_flags, result[0].addr, result[1].addr)
    sdl_assert success, &"Failed to create window and renderer"

proc name*(ren): cstring = sdl_get_renderer_name ren

proc sz*(ren): tuple[x, y: int32] =
    var x, y: cint
    let success = sdl_get_renderer_output_size(ren, x.addr, y.addr)
    sdl_assert success, &"Failed to get renderer size"
    (int32 x, int32 y)

proc create_texture*(ren; w, h: int; fmt = Rgba8888; access = texAccessStatic): Texture =
    result = sdl_create_texture(ren, fmt, access, cint w, cint h)
    sdl_assert result, &"Failed to create texture ({w}x{h}, {fmt}, {access})"
proc create_texture*(ren; surf): Texture =
    result = sdl_create_texture_from_surface(ren, surf)
    sdl_assert result, &"Failed to create texture from surface"

proc update*(tex; pxs: pointer; x, y, w, h: SomeInteger; pitch: SomeInteger = 4 * w): bool {.discardable.} =
    let rect = sdl_rect(x, y, w, h)
    result = sdl_update_texture(tex, rect.addr, pxs, pitch)
    sdl_assert result, &"Failed to update texture ({rect}; pitch = {pitch})"

proc update*(tex; pxs: pointer; pitch: SomeInteger): bool {.discardable.} =
    result = sdl_update_texture(tex, nil, pxs, cint pitch)
    sdl_assert result, &"Failed to update texture (pitch = {pitch})"

proc vsync*(ren): int32 =
    let success = sdl_get_render_vsync(ren, result.addr)
    sdl_assert success, &"Failed to get renderer's vsync"
proc scale*(ren): tuple[x, y: float32] =
    let success = sdl_get_render_scale(ren, result.x.addr, result.y.addr)
    sdl_assert success, &"Failed to get renderer's scale"
proc draw_colour*(ren): SdlColour =
    let success = sdl_get_render_draw_colour(ren, result.r.addr, result.g.addr, result.b.addr, result.a.addr)
    sdl_assert success, &"Failed to get renderer's draw colour"
proc colour_scale*(ren): float32 =
    let success = sdl_get_render_colour_scale(ren, result.addr)
    sdl_assert success, &"Failed to get renderer's colour scale"
proc blend_mode*(ren): BlendMode =
    let success = sdl_get_render_draw_blend_mode(ren, result.addr)
    sdl_assert success, &"Failed to get renderer's blend mode"

proc `viewport=`*(ren; rect: SdlRect): bool {.discardable.} =
    let success = sdl_set_render_viewport(ren, rect.addr)
    sdl_assert success, &"Failed to set renderer's viewport to {rect}"
proc `vsync=`*(ren; vsync: SomeInteger): bool {.discardable.} =
    let success = sdl_set_render_vsync(ren, vsync)
    sdl_assert success, &"Failed to set renderer's vsync to {vsync}"
proc `target=`*(ren; tex): bool {.discardable.} =
    let success = sdl_set_render_target(ren, tex)
    sdl_assert success, &"Failed to set renderer's target"
proc `scale=`*(ren; x, y: SomeNumber = 0.0): bool {.discardable.} =
    let success = sdl_set_render_scale(ren, cfloat x, cfloat y)
    sdl_assert success, &"Failed to set renderer's scale to {x}x{y}"
proc `draw_colour=`*(ren; colour: SdlColour): bool {.discardable.} =
    let success = sdl_set_render_draw_colour(ren, colour.r, colour.g, colour.b, colour.a)
    sdl_assert success, &"Failed to set renderer's draw colour to {colour}"
proc `draw_colour=`*(ren; colour: SdlColourF): bool {.discardable.} =
    let success = sdl_set_render_draw_colour_float(ren, colour.r, colour.g, colour.b, colour.a)
    sdl_assert success, &"Failed to set renderer's draw colour to {colour}"
proc `colour_scale=`*(ren; scale: SomeNumber): bool {.discardable.} =
    let success = sdl_set_render_colour_scale(ren, cfloat scale)
    sdl_assert success, &"Failed to set renderer's scale to {scale}"
proc `blend_mode=`*(ren; mode: BlendMode): bool {.discardable.} =
    let success = sdl_set_render_draw_blend_mode(ren, mode)
    sdl_assert success, &"Failed to set renderer's blend mode to {mode}"
proc `blend_mode=`*(tex; mode: BlendMode): bool {.discardable.} =
    let success = sdl_set_texture_blend_mode(tex, mode)
    sdl_assert success, &"Failed to set texture's blend mode to {mode}"

proc reset_target*(ren): bool {.discardable.} =
    result = sdl_set_render_target(ren, cast[Texture](nil))
    sdl_assert result, &"Failed to reset renderer's target"
proc clear*(ren): bool {.discardable.} =
    result = sdl_render_clear(ren)
    sdl_assert result, &"Failed to clear renderer"
proc fill*(ren): bool {.discardable.} =
    result = sdl_render_fill_rect(ren, nil)
    sdl_assert result, &"Failed to fill renderer"
proc present*(ren): bool {.discardable.} =
    result = sdl_render_present(ren)
    sdl_assert result, &"Failed to present renderer"
proc flush*(ren): bool {.discardable.} =
    result = sdl_flush_renderer(ren)
    sdl_assert result, &"Failed to flush renderer"

proc draw_point*(ren; x, y: SomeNumber): bool {.discardable.} =
    result = sdl_render_point(ren, cfloat x, cfloat y)
    sdl_assert result, &"Failed to draw point ({x}, {y})"
proc draw_points*(ren; points: openArray[SdlPointF]): bool {.discardable.} =
    result = sdl_render_points(ren, points[0].addr, cint points.len)
    sdl_assert result, &"Failed to draw points ({points})"
proc draw_line*(ren; p1, p2: SdlPointF): bool {.discardable.} =
    result = sdl_render_line(ren, p1.x, p1.y, p2.x, p2.y)
    sdl_assert result, &"Failed to draw line from {p1} to {p2}"
proc draw_lines*(ren; points: openArray[SdlPointF]): bool {.discardable.} =
    result = sdl_render_lines(ren, points[0].addr, cint points.len)
    sdl_assert result, &"Failed to draw lines ({points})"
proc draw_rect*(ren; rect: SdlRectF): bool {.discardable.} =
    result = sdl_render_rect(ren, rect.addr)
    sdl_assert result, &"Failed to draw rect {rect}"
proc draw_rects*(ren; rects: openArray[SdlRectF]): bool {.discardable.} =
    result = sdl_render_rects(ren, rects[0].addr, cint rects.len)
    sdl_assert result, &"Failed to draw rects ({rects})"
proc draw_fill_rect*(ren; rect: SdlRectF): bool {.discardable.} =
    result = sdl_render_fill_rect(ren, rect.addr)
    sdl_assert result, &"Failed to draw filled rects {rect}"
proc draw_fill_rects*(ren; rects: openArray[SdlRectF]): bool {.discardable.} =
    result = sdl_render_fill_rects(ren, rects[0].addr, cint rects.len)
    sdl_assert result, &"Failed to draw filled rects ({rects})"

proc draw_rect*(ren; rect: SdlRect): bool {.discardable.}      = draw_rect      ren, rect
proc draw_fill_rect*(ren; rect: SdlRect): bool {.discardable.} = draw_fill_rect ren, rect

proc draw_texture*(ren; tex; dst_rect, src_rect = SdlRectF()): bool {.discardable.} =
    let src = if src_rect.w != 0.0 and src_rect.h != 0.0: src_rect.addr else: nil
    let dst = if dst_rect.w != 0.0 and dst_rect.h != 0.0: dst_rect.addr else: nil
    result = sdl_render_texture(ren, tex, src, dst)
    sdl_assert result, &"Failed to draw texture (dst: {dst_rect}; src: {src_rect})"

proc draw_texture*(ren; tex; angle: SomeNumber; dst_rect, src_rect = SdlRectF(); centre = SdlPointF(); flip: FlipMode = None): bool {.discardable.} =
    let src = if src_rect.w != 0.0 and src_rect.h != 0.0: src_rect.addr else: nil
    let dst = if dst_rect.w != 0.0 and dst_rect.h != 0.0: dst_rect.addr else: nil
    result = sdl_render_texture_rotated(ren, tex, src, dst, cdouble angle, centre.addr, flip)
    sdl_assert result, &"Failed to draw texture rotated (dst: {dst_rect}; src: {src_rect}; angle = {angle}; centre = {centre}; flip = {flip})"

proc draw_geometry*(ren; verts: openArray[Vertex]; inds: openArray[int32] = []; tex = none Texture): bool {.discardable.} =
    let tex   = if tex.is_some: cast[pointer](get tex) else: nil
    let vertc = cint verts.len
    let indc  = cint inds.len
    let inds  = if indc > 0: inds[0].addr else: nil
    result = sdl_render_geometry(ren, cast[Texture](tex), verts[0].addr, vertc, inds, indc)
    sdl_assert result, &"Failed to draw geometry ({vertc} verts; {indc} inds)"

proc read_pixels*(ren; rect = SdlRect()): Surface =
    let src = if rect.w != 0 and rect.h != 0: rect.addr else: nil
    result = sdl_render_read_pixels(ren, src)
    sdl_assert result, &"Failed to read renderer's pixels from {rect}"

{.pop.}

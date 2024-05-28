{.push raises: [].}

import common, pixels, rect, surface, video

const SoftwareRenderer* = "software"

type RendererFlag* {.size: sizeof(uint32).} = enum
    # Software      = 0x0000_0001
    # Accelerated   = 0x0000_0002
    PresentVSync  = 0x0000_0004
    # TargetTexture = 0x0000_0008
func `or`*(a, b: RendererFlag): RendererFlag =
    RendererFlag (a.ord or b.ord)

type
    TextureAccess* {.size: sizeof(int32).} = enum
        Static
        Streaming
        Target

    LogicalPresent* {.size: sizeof(int32).} = enum
        Disabled
        Stretch
        Letterbox
        Overscan
        IntegerScale

type
    Renderer* = distinct pointer
    Texture*  = distinct pointer

    RendererInfo* = object
        name*                : cstring
        flags*               : RendererFlag
        texture_format_count*: int32
        texture_formats*     : ptr UncheckedArray[PixelFormat]
        max_texture_width*   : int32
        max_texture_height*  : int32

    Vertex* = object
        position* : FPoint
        colour*   : FColour
        tex_coord*: FPoint

func vertex*(x, y, r, g, b, a, u, v: float32 = 0.0): Vertex =
    Vertex(position : FPoint(x: x, y: y),
           colour   : FColour(r: r, g: g, b: b, a: a),
           tex_coord: FPoint(x: u, y: v))
func vertex*(x, y: float32 = 0.0; rgba = FColour(); u, v: float32 = 0.0): Vertex =
    vertex(x, y, rgba.r, rgba.g, rgba.b, rgba.a, u, v)
func vertex*(xy = FPoint(); rgba = FColour(); uv = FPoint()): Vertex =
    vertex(xy.x, xy.y, rgba.r, rgba.g, rgba.b, rgba.a, uv.x, uv.y)

#[ -------------------------------------------------------------------- ]#

type
    BlendMode* {.size: sizeof(uint32).} = enum
        None    = 0x0000_0000
        Blend   = 0x0000_0001
        Add     = 0x0000_0002
        Mod     = 0x0000_0004
        Mul     = 0x0000_0008
        Invalid = 0x7FFF_FFFF

    BlendOperation* {.size: sizeof(int32).} = enum
        Add         = 0x1
        Subtract    = 0x2
        RevSubtract = 0x3
        Minimum     = 0x4
        Maximum     = 0x5

    BlendFactor* {.size: sizeof(int32).} = enum
        Zero              = 0x1
        One               = 0x2
        SrcColour         = 0x3
        OneMinusSrcColour = 0x4
        SrcAlpha          = 0x5
        OneMinusSrcAlpha  = 0x6
        DstColour         = 0x7
        OneMinusDstColour = 0x8
        DstAlpha          = 0x9
        OneMinusDstAlpha  = 0xA

proc compose_custom_blendmode*(src_colour, dst_colour: BlendFactor; colour_op: BlendOperation;
                               src_alpha , dst_alpha : BlendFactor; alpha_op : BlendOperation): BlendMode
    {.importc: "SDL_ComposeCustomBlendMode", dynlib: SDLPath.}

#[ -------------------------------------------------------------------- ]#

from properties import PropertyID

using
    ren   : Renderer
    win   : Window
    wflags: WindowFlag
    rflags: RendererFlag
    surf  : Surface
    tex   : Texture

{.push dynlib: SDLPath.}
proc get_num_render_drivers*(): cint                                                       {.importc: "SDL_GetNumRenderDrivers"       .}
proc get_render_driver*(index: cint): cstring                                              {.importc: "SDL_GetRenderDriver"           .}
proc create_renderer*(win; name: cstring; rflags): pointer                                 {.importc: "SDL_CreateRenderer"            .}
proc create_software_renderer*(surf): pointer                                              {.importc: "SDL_CreateSoftwareRenderer"    .}
proc get_renderer*(win): pointer                                                           {.importc: "SDL_GetRenderer"               .}
proc get_renderer_window*(ren): pointer                                                    {.importc: "SDL_GetRenderWindow"           .}
proc get_renderer_info*(ren; info: ptr RendererInfo): cint                                 {.importc: "SDL_GetRendererInfo"           .}
proc get_renderer_properties*(ren): PropertyID                                             {.importc: "SDL_GetRendererProperties"     .}
proc get_renderer_output_size*(ren; w, h: ptr cint): cint                                  {.importc: "SDL_GetRenderOutputSize"       .}
proc get_current_renderer_output_size*(ren; w, h: ptr cint): cint                          {.importc: "SDL_GetCurrentRenderOutputSize".}
proc get_renderer_from_texture*(tex): pointer                                              {.importc: "SDL_GetRendererFromTexture"    .}
proc create_texture*(ren; format: PixelFormat; access: TextureAccess; w, h: cint): pointer {.importc: "SDL_CreateTexture"             .}
proc create_texture_from_surface*(ren; surf): pointer                                      {.importc: "SDL_CreateTextureFromSurface"  .}
proc set_render_scale*(ren; x, y: cfloat): cint                                            {.importc: "SDL_SetRenderScale"            .}
proc get_render_scale*(ren; x, y: ptr cfloat): cint                                        {.importc: "SDL_GetRenderScale"            .}
proc set_render_draw_colour*(ren; r, g, b, a: uint8): cint                                 {.importc: "SDL_SetRenderDrawColor"        .}
proc get_render_draw_colour*(ren; r, g, b, a: ptr uint8): cint                             {.importc: "SDL_GetRenderDrawColor"        .}
proc set_render_draw_colour_float*(ren; r, g, b, a: cfloat): cint                          {.importc: "SDL_SetRenderDrawColorFloat"   .}
proc get_render_draw_colour_float*(ren; r, g, b, a: ptr cfloat): cint                      {.importc: "SDL_GetRenderDrawColorFloat"   .}
proc set_render_colour_scale*(ren; scale: cfloat): cint                                    {.importc: "SDL_SetRenderColorScale"       .}
proc get_render_colour_scale*(ren; scale: ptr cfloat): cint                                {.importc: "SDL_GetRenderColorScale"       .}
proc set_render_draw_blend_mode*(ren; mode: BlendMode): cint                               {.importc: "SDL_SetRenderDrawBlendMode"    .}
proc get_render_draw_blend_mode*(ren; mode: ptr BlendMode): cint                           {.importc: "SDL_GetRenderDrawBlendMode"    .}
proc render_clear*(ren): cint                                                              {.importc: "SDL_RenderClear"               .}
proc render_point*(ren; x, y: cfloat): cint                                                {.importc: "SDL_RenderPoint"               .}
proc render_points*(ren; points: ptr FPoint; count: cint): cint                            {.importc: "SDL_RenderPoints"              .}
proc render_line*(ren; x1, y1, x2, y2: cfloat): cint                                       {.importc: "SDL_RenderLine"                .}
proc render_lines*(ren; points: ptr FPoint; count: cint): cint                             {.importc: "SDL_RenderLines"               .}
proc render_rect*(ren; rect: ptr FRect): cint                                              {.importc: "SDL_RenderRect"                .}
proc render_rects*(ren; rects: ptr FRect; count: cint): cint                               {.importc: "SDL_RenderRects"               .}
proc render_fill_rect*(ren; rect: ptr FRect): cint                                         {.importc: "SDL_RenderFillRect"            .}
proc render_fill_rects*(ren; rects: ptr FRect; count: cint): cint                          {.importc: "SDL_RenderFillRects"           .}
proc render_texture*(ren; tex; src, dst: ptr FRect): cint                                  {.importc: "SDL_RenderTexture"             .}
proc create_window_and_renderer*(title: cstring; w, h: cint; wflags; window: ptr Window; renderer: ptr Renderer): cint
    {.importc: "SDL_CreateWindowAndRenderer".}
proc render_texture_rotated*(ren; tex; src, dst: ptr FRect; angle: cdouble; center: ptr FPoint; flip: FlipMode): cint
    {.importc: "SDL_RenderTextureRotated".}
proc render_geometry*(ren; tex; vertices: ptr Vertex; vertex_count: cint; indices: ptr cint; index_count: cint): cint
    {.importc: "SDL_RenderGeometry".}
proc render_geometry_raw*(ren; tex; xys    : ptr cfloat; xy_stride    : cint;
                                    colours: ptr Colour; colour_stride: cint;
                                    uvs    : ptr cfloat; uv_stride    : cint;
                          vertex_count: cint; indices: pointer; index_count: cint; indices_size: cint): cint
    {.importc: "SDL_RenderGeometryRaw".}
proc render_geometry_raw_float*(ren; tex; xys: ptr cfloat ; xy_stride    : cint;
                                    colours  : ptr FColour; colour_stride: cint;
                                    uvs      : ptr cfloat ; uv_stride    : cint;
                          vertex_count: cint; indices: pointer; index_count: cint; indices_size: cint): cint
    {.importc: "SDL_RenderGeometryRawFloat".}
proc render_read_pixels*(ren; rect: ptr Rect): pointer {.importc: "SDL_RenderReadPixels".} # this needs to be free'd
proc render_present*(ren): cint                        {.importc: "SDL_RenderPresent"   .}
proc destroy_texture*(tex)                             {.importc: "SDL_DestroyTexture"  .}
proc destroy_renderer*(ren)                            {.importc: "SDL_DestroyRenderer" .}
proc flush_renderer*(ren): cint                        {.importc: "SDL_FlushRenderer"   .}

proc set_render_viewport*(ren; rect: ptr Rect): cint {.importc: "SDL_SetRenderViewport".}
proc set_render_vsync*(ren; vsync: cint): cint       {.importc: "SDL_SetRenderVSync"   .}
proc get_render_vsync*(ren; vsync: ptr cint): cint   {.importc: "SDL_GetRenderVSync"   .}
proc set_render_target*(ren; tex): cint              {.importc: "SDL_SetRenderTarget"  .}
{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}

proc create_renderer*(surf): Renderer {.raises: SDLError.} =
    check_ptr[Renderer] "Failed to create software renderer":
        create_software_renderer surf
proc create_renderer*(win; name: string = ""; rflags = PresentVSync): Renderer {.raises: SDLError.} =
    check_ptr[Renderer] "Failed to create renderer":
        create_renderer(win, if name != "": cstring name else: nil, rflags)
proc create_window_and_renderer*(title: string; w, h: int; wflags: WindowFlag = None): (Window, Renderer) {.raises: SDLError.} =
    check_err "Failed to create window and renderer":
        create_window_and_renderer(cstring title, cint w, cint h, wflags, result[0].addr, result[1].addr)

proc get_info*(ren): RendererInfo {.raises: SDLError.} =
    check_err "Failed to get renderer info":
        get_renderer_info(ren, result.addr)
proc get_output_size*(ren): tuple[x, y: int] {.raises: SDLError.} =
    var x, y: cint
    check_err "Failed to get renderer ouput size":
        get_renderer_output_size(ren, x.addr, y.addr)

    result.x = x
    result.y = y
proc get_current_output_size*(ren): tuple[x, y: int] {.raises: SDLError.} =
    var x, y: cint
    check_err "Failed to get current renderer ouput size":
        get_current_renderer_output_size(ren, x.addr, y.addr)

    result.x = x
    result.y = y

proc create_texture*(ren; w, h: int; format = RGBA8888; access = Static): Texture {.raises: SDLError.} =
    check_ptr[Texture] "Failed to create texture":
        create_texture(ren, format, access, cint w, cint h)
proc create_texture*(ren; surf): Texture {.raises: SDLError.} =
    check_ptr[Texture] "Failed to create texture from surface":
        create_texture_from_surface(ren, surf)

proc set_viewport*(ren; rect: Rect) {.raises: SDLError.} =
    check_err "Failed to set the renderer's viewport":
        ren.set_render_viewport rect.addr

proc set_vsync*(ren; vsync: int) {.raises: SDLError.} =
    check_err "Failed to set renderer's vsync":
        ren.set_render_vsync cint vsync

proc get_vsync*(ren): int32 {.raises: SDLError.} =
    check_err "Failed to get renderer's vsync":
        ren.get_render_vsync result.addr

proc set_target*(ren; tex) {.raises: SDLError.} =
    check_err "Failed to set renderer's target":
        ren.set_render_target tex
proc reset_target*(ren) {.raises: SDLError.} =
    check_err "Failed to reset renderer's target":
        ren.set_render_target cast[Texture](nil)

proc set_scale*(ren; x = 0.0; y = 0.0) {.raises: SDLError.} =
    check_err "Failed to set renderer scale":
        set_render_scale(ren, x, y)
proc get_scale*(ren): tuple[x, y: float] {.raises: SDLError.} =
    var tmp: (cfloat, cfloat)
    check_err "Failed to get scale for renderer":
        get_render_scale(ren, tmp[0].addr, tmp[1].addr)

    result.x = tmp[0]
    result.y = tmp[1]

proc set_draw_colour*(ren; colour: Colour) {.raises: SDLError.} =
    check_err "Failed to set renderer's draw colour":
        set_render_draw_colour(ren, colour.r, colour.g, colour.b, colour.a)
proc set_draw_colour*(ren; colour: FColour) {.raises: SDLError.} =
    check_err "Failed to set renderer's draw colour":
        set_render_draw_colour_float(ren, colour.r, colour.g, colour.b, colour.a)
proc get_draw_colour*[T: Colour | FColour](ren): T {.raises: SDLError.} =
    check_err "Failed to get renderer's draw colour":
        get_render_draw_colour(ren, result.r.addr, result.g.addr, result.b.addr, result.a.addr)

proc set_colour_scale*(ren; scale: float) {.raises: SDLError.} =
    check_err "Failed to set renderer's colour scale":
        set_render_colour_scale(ren, cfloat scale)
proc get_colour_scale*(ren): float32 {.raises: SDLError.} =
    check_err "Failed to get renderer's colour scale":
        get_render_colour_scale(ren, result.addr)

proc set_blend_mode*(ren; mode: BlendMode) {.raises: SDLError.} =
    check_err "Failed to set renderer's draw blend mode":
        set_render_draw_blend_mode(ren, mode)
proc get_blend_mode*(ren): BlendMode {.raises: SDLError.} =
    check_err "Failed to get renderer's draw blend mode":
        get_render_draw_blend_mode(ren, result.addr)

proc clear*(ren) {.raises: SDLError.} =
    check_err "Failed to clear renderer":
        render_clear ren
proc draw_point*(ren; x, y: float32) {.raises: SDLError.} =
    check_err "Failed to render point":
        render_point(ren, x, y)
proc draw_points*(ren; points: seq[FPoint]) {.raises: SDLError.} =
    check_err "Failed to render points":
        render_points(ren, points[0].addr, cint points.len)
proc draw_line*(ren; p1, p2: FPoint) {.raises: SDLError.} =
    check_err "Failed to render line":
        render_line(ren, p1.x, p1.y, p2.x, p2.y)
proc draw_lines*(ren; points: seq[FPoint]) {.raises: SDLError.} =
    check_err "Failed to render lines":
        render_lines(ren, points[0].addr, cint points.len)
proc draw_rect*(ren; rect: FRect) {.raises: SDLError.} =
    check_err "Failed to render rect":
        render_rect(ren, rect.addr)
proc draw_rect*(ren; rect: Rect) {.raises: SDLError.} = ren.draw_rect frect(rect)
proc draw_rects*(ren; rects: seq[FRect]) {.raises: SDLError.} =
    check_err "Failed to render rects":
        render_rects(ren, rects[0].addr, cint rects.len)
proc draw_fill_rect*(ren; rect: FRect) {.raises: SDLError.} =
    check_err "Failed to render fill rect":
        render_fill_rect(ren, rect.addr)
proc draw_fill_rect*(ren; rect: Rect) {.raises: SDLError.} = ren.draw_fill_rect frect(rect)
proc draw_fill_rects*(ren; rects: seq[FRect]) {.raises: SDLError.} =
    check_err "Failed to render fill rects":
        render_fill_rects(ren, rects[0].addr, cint rects.len)
proc fill*(ren) {.raises: SDLError.} =
    check_err "Failed to render fill rect":
        render_fill_rect(ren, nil)

proc draw_texture*(ren; tex; dst_rect, src_rect = FRect()) {.raises: SDLError.} =
    let src = if src_rect.w != 0.0 and src_rect.h != 0.0: src_rect.addr else: nil
    let dst = if dst_rect.w != 0.0 and dst_rect.h != 0.0: dst_rect.addr else: nil
    check_err "Failed to render texture":
        render_texture(ren, tex, src, dst)

proc draw_texture*(ren; tex; angle: SomeNumber; src_rect = FRect(); dst_rect = FRect();
                   center = FPoint(); flip = FlipMode.None) {.raises: SDLError.} =
    let src = if src_rect.w != 0.0 and src_rect.h != 0.0: src_rect.addr else: nil
    let dst = if dst_rect.w != 0.0 and dst_rect.h != 0.0: dst_rect.addr else: nil
    check_err "Failed to render rotated texture":
        render_texture_rotated(ren, tex, src.addr, dst.addr, cfloat angle, center, flip)

proc geometry*(ren; vertices: seq[Vertex]; indices = none seq[int32]; texture = none Texture) {.raises: SDLError.} =
    let tex = if is_some texture: cast[pointer](get texture) else: nil
    let (indc, inds) = if is_some indices: ((get indices).len, (get indices)[0].addr)
                       else: (0, nil)
    check_err "Failed to render geometry":
        render_geometry(ren, cast[Texture](tex), vertices[0].addr, cint vertices.len, inds, cint indc)

proc read_pixels*(ren; rect = Rect()): Surface {.raises: SDLError.} =
    let src = if rect.w != 0 and rect.h != 0: rect.addr else: nil
    check_ptr[Surface] "Failed to read pixels":
        render_read_pixels(ren, src)
proc present*(ren) {.raises: SDLError.} =
    check_err "Failed to present renderer":
        render_present ren
proc flush*(ren) {.raises: SDLError.} =
    check_err "Failed to flush renderer":
        flush_renderer ren

proc destroy*(tex) = destroy_texture tex
proc destroy*(ren) = destroy_renderer ren

{.pop.} # inline

# TODO:

# extern DECLSPEC SDL_Renderer * SDLCALL SDL_CreateRendererWithProperties(SDL_PropertiesID props);
# extern DECLSPEC SDL_Texture *SDLCALL SDL_CreateTextureWithProperties(SDL_Renderer *renderer, SDL_PropertiesID props);
# extern DECLSPEC SDL_PropertiesID SDLCALL SDL_GetTextureProperties(SDL_Texture *texture);

# extern DECLSPEC int SDLCALL SDL_QueryTexture(SDL_Texture *texture, SDL_PixelFormatEnum *format, int *access, int *w, int *h);
# extern DECLSPEC int SDLCALL SDL_SetTextureColorMod(SDL_Texture *texture, Uint8 r, Uint8 g, Uint8 b);
# extern DECLSPEC int SDLCALL SDL_SetTextureColorModFloat(SDL_Texture *texture, float r, float g, float b);
# extern DECLSPEC int SDLCALL SDL_GetTextureColorMod(SDL_Texture *texture, Uint8 *r, Uint8 *g, Uint8 *b);
# extern DECLSPEC int SDLCALL SDL_GetTextureColorModFloat(SDL_Texture *texture, float *r, float *g, float *b);
# extern DECLSPEC int SDLCALL SDL_SetTextureAlphaMod(SDL_Texture *texture, Uint8 alpha);
# extern DECLSPEC int SDLCALL SDL_SetTextureAlphaModFloat(SDL_Texture *texture, float alpha);
# extern DECLSPEC int SDLCALL SDL_GetTextureAlphaMod(SDL_Texture *texture, Uint8 *alpha);
# extern DECLSPEC int SDLCALL SDL_GetTextureAlphaModFloat(SDL_Texture *texture, float *alpha);
# extern DECLSPEC int SDLCALL SDL_SetTextureBlendMode(SDL_Texture *texture, SDL_BlendMode blendMode);
# extern DECLSPEC int SDLCALL SDL_GetTextureBlendMode(SDL_Texture *texture, SDL_BlendMode *blendMode);
# extern DECLSPEC int SDLCALL SDL_SetTextureScaleMode(SDL_Texture *texture, SDL_ScaleMode scaleMode);
# extern DECLSPEC int SDLCALL SDL_GetTextureScaleMode(SDL_Texture *texture, SDL_ScaleMode *scaleMode);
# extern DECLSPEC int SDLCALL SDL_UpdateTexture(SDL_Texture *texture, const SDL_Rect *rect, const void *pixels, int pitch);
# extern DECLSPEC int SDLCALL SDL_UpdateYUVTexture(SDL_Texture *texture, const SDL_Rect *rect,  const Uint8 *Yplane, int Ypitch,const Uint8 *Uplane, int Upitch,const Uint8 *Vplane, int Vpitch);
# extern DECLSPEC int SDLCALL SDL_UpdateNVTexture(SDL_Texture *texture, const SDL_Rect *rect, const Uint8 *Yplane, int Ypitch, const Uint8 *UVplane, int UVpitch);
# extern DECLSPEC int SDLCALL SDL_LockTexture(SDL_Texture *texture, const SDL_Rect *rect, void **pixels, int *pitch);
# extern DECLSPEC int SDLCALL SDL_LockTextureToSurface(SDL_Texture *texture, const SDL_Rect *rect, SDL_Surface **surface);
# extern DECLSPEC void SDLCALL SDL_UnlockTexture(SDL_Texture *texture);
# extern DECLSPEC SDL_Texture *SDLCALL SDL_GetRenderTarget(SDL_Renderer *renderer);
# extern DECLSPEC int SDLCALL SDL_SetRenderLogicalPresentation(SDL_Renderer *renderer, int w, int h, SDL_RendererLogicalPresentation mode, SDL_ScaleMode scale_mode);
# extern DECLSPEC int SDLCALL SDL_GetRenderLogicalPresentation(SDL_Renderer *renderer, int *w, int *h, SDL_RendererLogicalPresentation *mode, SDL_ScaleMode *scale_mode);
# extern DECLSPEC int SDLCALL SDL_RenderCoordinatesFromWindow(SDL_Renderer *renderer, float window_x, float window_y, float *x, float *y);
# extern DECLSPEC int SDLCALL SDL_RenderCoordinatesToWindow(SDL_Renderer *renderer, float x, float y, float *window_x, float *window_y);
# extern DECLSPEC int SDLCALL SDL_ConvertEventToRenderCoordinates(SDL_Renderer *renderer, SDL_Event *event);
# extern DECLSPEC int SDLCALL SDL_GetRenderViewport(SDL_Renderer *renderer, SDL_Rect *rect);
# extern DECLSPEC SDL_bool SDLCALL SDL_RenderViewportSet(SDL_Renderer *renderer);
# extern DECLSPEC int SDLCALL SDL_SetRenderClipRect(SDL_Renderer *renderer, const SDL_Rect *rect);
# extern DECLSPEC int SDLCALL SDL_GetRenderClipRect(SDL_Renderer *renderer, SDL_Rect *rect);
# extern DECLSPEC SDL_bool SDLCALL SDL_RenderClipEnabled(SDL_Renderer *renderer);

# void *SDLCALL         SDL_GetRenderMetalLayer(SDL_Renderer *renderer);
# void *SDLCALL         SDL_GetRenderMetalCommandEncoder(SDL_Renderer *renderer);
# int SDLCALL           SDL_AddVulkanRenderSemaphores(SDL_Renderer *renderer, Uint32 wait_stage_mask, Sint64 wait_semaphore, Sint64 signal_semaphore);

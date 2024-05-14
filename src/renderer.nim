import common, properties, pixels, rect, surface, video

proc check_pointer[T](p: pointer; msg: string): Option[T] =
    let msgi {.inject.} = msg # https://github.com/nim-lang/Nim/issues/10977
    if p == nil:
        echo red fmt"Error: failed to get {msgi}: {get_error()}"
        result = none T
    else:
        result = some cast[ptr T](p)[]

template check_error(msg, body) =
    when not defined NoSDLErrorChecks:
        let msgi {.inject.} = msg
        if body != 0:
            echo red fmt"Error: failed to {msgi}: {get_error()}"
    else:
        body

#[ -------------------------------------------------------------------- ]#

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

#~Blending~############################################################
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

using
    ren   : Renderer
    win   : Window
    wflags: WindowFlag
    rflags: RendererFlag
    surf  : Surface
    tex   : Texture

proc get_num_render_drivers*(): int32                      {.importc: "SDL_GetNumRenderDrivers"   , dynlib: SDLPath.}
proc get_render_driver*(index: int32): cstring             {.importc: "SDL_GetRenderDriver"       , dynlib: SDLPath.}
proc create_renderer*(win; name: cstring; rflags): pointer {.importc: "SDL_CreateRenderer"        , dynlib: SDLPath.}
proc create_software_renderer*(surf): pointer              {.importc: "SDL_CreateSoftwareRenderer", dynlib: SDLPath.}
proc create_software_renderer_opt*(surf): Option[Renderer] =
    let surf = create_software_renderer surf
    check_pointer[Renderer](surf, "software renderer")
proc create_renderer_opt*(win; name: string; rflags): Option[Renderer] =
    check_pointer[Renderer](create_renderer(win, cstring name, rflags), "renderer")
proc create_window_and_renderer*(title: cstring; w, h: int32; wflags; window: ptr Window; renderer: ptr Renderer): int32
    {.importc: "SDL_CreateWindowAndRenderer", dynlib: SDLPath.}
proc create_window_and_renderer*(title: string; w, h: int; wflags): (Window, Renderer) =
    if create_window_and_renderer(cstring title, int32 w, int32 h, wflags, result[0].addr, result[1].addr) != 0:
        echo red fmt"Error: failed to create window and renderer: {get_error()}"

proc get_renderer*(win): pointer                                    {.importc: "SDL_GetRenderer"               , dynlib: SDLPath.}
proc get_renderer_window*(ren): pointer                             {.importc: "SDL_GetRenderWindow"           , dynlib: SDLPath.}
proc get_renderer_info*(ren; info: ptr RendererInfo): int32         {.importc: "SDL_GetRendererInfo"           , dynlib: SDLPath.}
proc get_renderer_properties*(ren): PropertyID                      {.importc: "SDL_GetRendererProperties"     , dynlib: SDLPath.}
proc get_renderer_output_size*(ren; w, h: ptr int32): int32         {.importc: "SDL_GetRenderOutputSize"       , dynlib: SDLPath.}
proc get_current_renderer_output_size*(ren; w, h: ptr int32): int32 {.importc: "SDL_GetCurrentRenderOutputSize", dynlib: SDLPath.}
proc get_renderer*(tex): pointer                                    {.importc: "SDL_GetRendererFromTexture"    , dynlib: SDLPath.}
proc get_renderer_opt*(win): Option[Renderer]      = check_pointer[Renderer](get_renderer win, "renderer")
proc get_renderer_window_opt*(ren): Option[Window] = check_pointer[Window](get_renderer_window ren, "renderer window")
proc get_renderer_opt*(tex): Option[Renderer]      = check_pointer[Renderer](get_renderer tex, "renderer from texture")
proc get_renderer_info*(ren): RendererInfo =
    if get_renderer_info(ren, result.addr) != 0:
        echo red fmt"Error: failed to get renderer info: {get_error()}"
proc get_renderer_output_size*(ren): (int32, int32) =
    if get_renderer_output_size(ren, result[0].addr, result[1].addr) != 0:
        echo red fmt"Error: failed to get renderer output size: {get_error()}"
proc get_current_renderer_output_size*(ren): (int32, int32) =
    if get_current_renderer_output_size(ren, result[0].addr, result[1].addr) != 0:
        echo red fmt"Error: failed to get current renderer output size: {get_error()}"

proc create_texture*(ren; format: PixelFormat; access: TextureAccess; w, h: int32): pointer {.importc: "SDL_CreateTexture"           , dynlib: SDLPath.}
proc create_texture*(ren; surf): pointer                                                    {.importc: "SDL_CreateTextureFromSurface", dynlib: SDLPath.}
proc create_texture_opt*(ren; format: PixelFormat; access: TextureAccess; w, h: int): Option[Texture] =
    check_pointer[Texture](create_texture(ren, format, access, int32 w, int32 h), "texture")
proc create_texture_opt*(ren; surf): Option[Texture] =
    check_pointer[Texture](create_texture(ren, surf), "texture from surface")

#~Renderer Settings~###################################################
proc set_scale*(ren; x, y: cfloat): cint        {.importc: "SDL_SetRenderScale", dynlib: SDLPath.}
proc get_scale*(ren; x, y: ptr cfloat): cint    {.importc: "SDL_GetRenderScale", dynlib: SDLPath.}
proc set_scale*(ren; scale: (float32, float32)) {.inline.} = check_error "set scale": set_scale(ren, scale[0], scale[1])
proc get_scale*(ren): (float32, float32)        {.inline.} = check_error "get scale": get_scale(ren, result[0].addr, result[1].addr)

proc set_draw_colour*(ren; r, g, b, a: uint8): cint      {.importc: "SDL_SetRenderDrawColor"     , dynlib: SDLPath.}
proc get_draw_colour*(ren; r, g, b, a: ptr uint8): cint  {.importc: "SDL_GetRenderDrawColor"     , dynlib: SDLPath.}
proc set_draw_colour*(ren; r, g, b, a: cfloat): cint     {.importc: "SDL_SetRenderDrawColorFloat", dynlib: SDLPath.}
proc get_draw_colour*(ren; r, g, b, a: ptr cfloat): cint {.importc: "SDL_GetRenderDrawColorFloat", dynlib: SDLPath.}
proc set_draw_colour*(ren; colour: Colour | FColour) {.inline.} =
    check_error "set draw colour": set_draw_colour(ren, colour.r, colour.g, colour.b, colour.a)
proc get_draw_colour*(ren): Colour | FColour {.inline.} =
    check_error "get draw colour": get_draw_colour(ren, result.r.addr, result.g.addr, result.b.addr, result.a.addr)

proc set_colour_scale*(ren; scale: cfloat): cint     {.importc: "SDL_SetRenderColorScale", dynlib: SDLPath.}
proc get_colour_scale*(ren; scale: ptr cfloat): cint {.importc: "SDL_GetRenderColorScale", dynlib: SDLPath.}
proc set_colour_scale*(ren; scale: float) {.inline.} = check_error "set colour scale": set_colour_scale(ren, cfloat scale)
proc get_colour_scale*(ren): float32      {.inline.} = check_error "get colour scale": get_colour_scale(ren, result.addr)

proc set_draw_blend_mode*(ren; mode: cuint): cint     {.importc: "SDL_SetRenderDrawBlendMode", dynlib: SDLPath.}
proc get_draw_blend_mode*(ren; mode: ptr cuint): cint {.importc: "SDL_GetRenderDrawBlendMode", dynlib: SDLPath.}
proc set_draw_blend_mode*(ren; mode: BlendMode) {.inline.} =
    check_error "set draw blend mode": set_draw_blend_mode(ren, cuint mode)
proc get_draw_blend_mode*(ren): BlendMode {.inline.} =
    check_error "get draw blend mode": get_draw_blend_mode(ren, cast[ptr cuint](result.addr))

#~Renderer Drawing~####################################################

proc render_clear*(ren): cint                                     {.importc: "SDL_RenderClear"    , dynlib: SDLPath.}
proc render_point*(ren; x, y: cfloat): cint                       {.importc: "SDL_RenderPoint"    , dynlib: SDLPath.}
proc render_points*(ren; points: ptr FPoint; count: cint): cint   {.importc: "SDL_RenderPoints"   , dynlib: SDLPath.}
proc render_line*(ren; x1, y1, x2, y2: cfloat): cint              {.importc: "SDL_RenderLine"     , dynlib: SDLPath.}
proc render_lines*(ren; points: ptr FPoint; count: cint): cint    {.importc: "SDL_RenderLines"    , dynlib: SDLPath.}
proc render_rect*(ren; rect: ptr FRect): cint                     {.importc: "SDL_RenderRect"     , dynlib: SDLPath.}
proc render_rects*(ren; rects: ptr FRect; count: cint): cint      {.importc: "SDL_RenderRects"    , dynlib: SDLPath.}
proc render_fill_rect*(ren; rect: ptr FRect): cint                {.importc: "SDL_RenderFillRect" , dynlib: SDLPath.}
proc render_fill_rects*(ren; rects: ptr FRect; count: cint): cint {.importc: "SDL_RenderFillRects", dynlib: SDLPath.}
proc render_texture*(ren; tex; src, dst: ptr FRect): cint         {.importc: "SDL_RenderTexture"  , dynlib: SDLPath.}
proc render_texture_rotated*(ren; tex; src, dst: ptr FRect; angle: cdouble; center: ptr FPoint; flip: FlipMode): cint
    {.importc: "SDL_RenderTextureRotated", dynlib: SDLPath.}
proc render_geometry*(ren; tex; vertices: ptr Vertex; vertex_count: cint; indices: ptr cint; index_count: cint): cint
    {.importc: "SDL_RenderGeometry", dynlib: SDLPath.}
proc render_geometry_raw*(ren; tex; xys    : ptr cfloat; xy_stride    : cint;
                                    colours: ptr Colour; colour_stride: cint;
                                    uvs    : ptr cfloat; uv_stride    : cint;
                          vertex_count: cint; indices: pointer; index_count: cint; indices_size: cint): cint
    {.importc: "SDL_RenderGeometryRaw", dynlib: SDLPath.}
proc render_geometry_raw_float*(ren; tex; xys: ptr cfloat ; xy_stride    : cint;
                                    colours  : ptr FColour; colour_stride: cint;
                                    uvs      : ptr cfloat ; uv_stride    : cint;
                          vertex_count: cint; indices: pointer; index_count: cint; indices_size: cint): cint
    {.importc: "SDL_RenderGeometryRawFloat", dynlib: SDLPath.}
proc render_read_pixels*(ren; rect: ptr Rect): pointer {.importc: "SDL_RenderReadPixels", dynlib: SDLPath.} # this needs to be free'd
proc render_present*(ren): cint                        {.importc: "SDL_RenderPresent"   , dynlib: SDLPath.}
proc destroy_texture*(tex)                             {.importc: "SDL_DestroyTexture"  , dynlib: SDLPath.}
proc destroy_renderer*(ren)                            {.importc: "SDL_DestroyRenderer" , dynlib: SDLPath.}
proc flush_renderer*(ren): cint                        {.importc: "SDL_FlushRenderer"   , dynlib: SDLPath.}

proc clear*(ren)                         {.inline.} = check_error "clear renderer"   : render_clear ren
proc point*(ren; x, y: float32)          {.inline.} = check_error "render point"     : render_point(ren, x, y)
proc points*(ren; points: seq[FPoint])   {.inline.} = check_error "render points"    : render_points(ren, points[0].addr, cint points.len)
proc line*(ren; p1, p2: FPoint)          {.inline.} = check_error "render line"      : render_line(ren, p1.x, p1.y, p2.x, p2.y)
proc lines*(ren; points: seq[FPoint])    {.inline.} = check_error "render lines"     : render_lines(ren, points[0].addr, cint points.len)
proc rect*(ren; rect: FRect)             {.inline.} = check_error "render rect"      : render_rect(ren, rect.addr)
proc rects*(ren; rects: seq[FRect])      {.inline.} = check_error "render rects"     : render_rects(ren, rects[0].addr, cint rects.len)
proc fill*(ren)                          {.inline.} = check_error "render fill rect" : render_fill_rect(ren, nil)
proc fill_rect*(ren; rect: FRect)        {.inline.} = check_error "render fill rect" : render_fill_rect(ren, rect.addr)
proc fill_rects*(ren; rects: seq[FRect]) {.inline.} = check_error "render fill rects": render_fill_rects(ren, rects[0].addr, cint rects.len)

proc texture*(ren; tex; src, dst: FRect) {.inline.} = check_error "render texture": render_texture(ren, tex, src.addr, dst.addr)
proc texture*(ren; tex; src, dst: FRect; angle: SomeFloat; center: FPoint = FPoint(x:0, y:0); flip: FlipMode = None) {.inline.} =
    check_error "render texture rotated": render_texture_rotated(ren, tex, src.addr, dst.addr, angle, center, flip)
proc geometry*(ren; tex; vertices: seq[Vertex]; indices: seq[int32]) {.inline.} =
    check_error "render geometry": render_geometry(ren, tex, vertices[0].addr, cint vertices.len, indices[0].addr, cint indices.len)
proc read_pixels*(ren; rect: Rect): Option[Surface] {.inline.} =
    check_pointer[Surface](render_read_pixels(ren, rect.addr), "render read pixels")
proc present*(ren) {.inline.} = check_error "render present": render_present ren
proc flush*(ren)   {.inline.} = check_error "render flush"  : flush_renderer ren

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
# extern DECLSPEC int SDLCALL SDL_SetRenderTarget(SDL_Renderer *renderer, SDL_Texture *texture);
# extern DECLSPEC SDL_Texture *SDLCALL SDL_GetRenderTarget(SDL_Renderer *renderer);
# extern DECLSPEC int SDLCALL SDL_SetRenderLogicalPresentation(SDL_Renderer *renderer, int w, int h, SDL_RendererLogicalPresentation mode, SDL_ScaleMode scale_mode);
# extern DECLSPEC int SDLCALL SDL_GetRenderLogicalPresentation(SDL_Renderer *renderer, int *w, int *h, SDL_RendererLogicalPresentation *mode, SDL_ScaleMode *scale_mode);
# extern DECLSPEC int SDLCALL SDL_RenderCoordinatesFromWindow(SDL_Renderer *renderer, float window_x, float window_y, float *x, float *y);
# extern DECLSPEC int SDLCALL SDL_RenderCoordinatesToWindow(SDL_Renderer *renderer, float x, float y, float *window_x, float *window_y);
# extern DECLSPEC int SDLCALL SDL_ConvertEventToRenderCoordinates(SDL_Renderer *renderer, SDL_Event *event);
# extern DECLSPEC int SDLCALL SDL_SetRenderViewport(SDL_Renderer *renderer, const SDL_Rect *rect);
# extern DECLSPEC int SDLCALL SDL_GetRenderViewport(SDL_Renderer *renderer, SDL_Rect *rect);
# extern DECLSPEC SDL_bool SDLCALL SDL_RenderViewportSet(SDL_Renderer *renderer);
# extern DECLSPEC int SDLCALL SDL_SetRenderClipRect(SDL_Renderer *renderer, const SDL_Rect *rect);
# extern DECLSPEC int SDLCALL SDL_GetRenderClipRect(SDL_Renderer *renderer, SDL_Rect *rect);
# extern DECLSPEC SDL_bool SDLCALL SDL_RenderClipEnabled(SDL_Renderer *renderer);

# void *SDLCALL         SDL_GetRenderMetalLayer(SDL_Renderer *renderer);
# void *SDLCALL         SDL_GetRenderMetalCommandEncoder(SDL_Renderer *renderer);
# int SDLCALL           SDL_AddVulkanRenderSemaphores(SDL_Renderer *renderer, Uint32 wait_stage_mask, Sint64 wait_semaphore, Sint64 signal_semaphore);
# int SDLCALL           SDL_SetRenderVSync(SDL_Renderer *renderer, int vsync);
# int SDLCALL           SDL_GetRenderVSync(SDL_Renderer *renderer, int *vsync);

import std/options, common, bitgen, properties, pixels
from iostream import IoStream
from rect     import Rect

type SurfaceFlag* = distinct uint32
SurfaceFlag.gen_bit_ops PreAllocated, LockNeeded, Locked, SimdAligned

type
    FlipMode* {.size: sizeof(cint).} = enum
        None
        Horizontal
        Vertical

    ScaleMode* {.size: sizeof(cint).} = enum
        Nearest
        Linear

type
    BlitMap* = ptr object

    Surface* = ptr SurfaceObj
    SurfaceObj = object
        flags*    : SurfaceFlag
        fmt*      : PixelFormat
        w*, h*    : int32
        pitch*    : int32
        pxs*      : pointer
        ref_count*: int32
        _         : pointer

func must_lock*(surf: Surface | SurfaceObj): bool {.inline.} =
    (surf.flags and LockNeeded) == LockNeeded

#[ -------------------------------------------------------------------- ]#

from renderer import BlendMode

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_CreateSurface*(w, h: cint; fmt: PixelFormat): Surface
proc SDL_CreateSurfaceFrom*(w, h: cint; fmt: PixelFormat; pxs: pointer; pitch: cint): Surface
proc SDL_DestroySurface*(surf: Surface)

proc SDL_GetSurfaceProperties*(surf: Surface): PropertyId
proc SDL_SetSurfaceColorspace*(surf: Surface; colorspace: Colourspace): bool
proc SDL_GetSurfaceColorspace*(surf: Surface): Colourspace
proc SDL_CreateSurfacePalette*(surf: Surface): Palette
proc SDL_SetSurfacePalette*(surf: Surface; palette: Palette): bool
proc SDL_GetSurfacePalette*(surf: Surface): Palette

proc SDL_AddSurfaceAlternateImage*(surf, img: Surface): bool
proc SDL_SurfaceHasAlternateImages*(surf: Surface): bool
proc SDL_GetSurfaceImages*(surf: Surface; cnt: ptr cint): ptr Surface
proc SDL_RemoveSurfaceAlternateImages*(surf: Surface)
proc SDL_LockSurface*(surf: Surface): bool
proc SDL_UnlockSurface*(surf: Surface)

proc SDL_LoadBMP_IO*(stream: IoStream; close_io: bool): Surface
proc SDL_LoadBMP*(file: cstring): Surface
proc SDL_SaveBMP_IO*(surf: Surface; dst: IoStream; close_io: bool): bool
proc SDL_SaveBMP*(surf: Surface; file: cstring): bool

proc SDL_SetSurfaceRLE*(surf: Surface; enabled: bool): bool
proc SDL_SurfaceHasRLE*(surf: Surface): bool
proc SDL_SetSurfaceColorKey*(surf: Surface; enabled: bool; key: uint32): bool
proc SDL_SurfaceHasColorKey*(surf: Surface): bool
proc SDL_GetSurfaceColorKey*(surf: Surface; key: ptr uint32): bool
proc SDL_SetSurfaceColorMod*(surf: Surface; r, g, b: uint8): bool
proc SDL_GetSurfaceColorMod*(surf: Surface; r, g, b: ptr uint8): bool
proc SDL_SetSurfaceAlphaMod*(surf: Surface; alpha: uint8): bool
proc SDL_GetSurfaceAlphaMod*(surf: Surface; alpha: ptr uint8): bool
proc SDL_SetSurfaceBlendMode*(surf: Surface; blend_mode: BlendMode): bool
proc SDL_GetSurfaceBlendMode*(surf: Surface; blend_mode: ptr BlendMode): bool
proc SDL_SetSurfaceClipRect*(surf: Surface; rect: ptr Rect): bool
proc SDL_GetSurfaceClipRect*(surf: Surface; rect: ptr Rect): bool
proc SDL_FlipSurface*(surf: Surface; flip: FlipMode): bool
proc SDL_DuplicateSurface*(surf: Surface): Surface
proc SDL_ScaleSurface*(surf: Surface; w, h: cint; scale_mode: ScaleMode): Surface
proc SDL_ConvertSurface*(surf: Surface; fmt: PixelFormat): Surface
proc SDL_ConvertSurfaceAndColorspace*(surf: Surface; fmt: PixelFormat; palette: Palette, colorspace: Colourspace; props: PropertyId): Surface
proc SDL_ConvertPixels*(w, h: cint; src_fmt: PixelFormat; src: pointer; src_pitch: cint; dst_fmt: PixelFormat; dst: pointer; dst_pitch: cint): bool
proc SDL_ConvertPixelsAndColorspace*(w, h: cint; src_fmt: PixelFormat; src_colorspace: Colourspace; src_props: PropertyId; src: pointer; src_pitch: cint;
                                                 dst_fmt: PixelFormat; dst_colorspace: Colourspace; dst_props: PropertyId; dst: pointer; dst_pitch: cint): bool
proc SDL_PremultiplyAlpha*(w, h: cint; src_fmt: PixelFormat; src: pointer; src_pitch: cint; dst_fmt: PixelFormat; dst: pointer; dst_pitch: cint; linear: bool): bool
proc SDL_PremultiplySurfaceAlpha*(surf: Surface; linear: bool): bool

proc SDL_ClearSurface*(surf: Surface; r, g, b, a: cfloat): bool
proc SDL_FillSurfaceRect*(dst: Surface; rect: ptr Rect; colour: uint32): bool
proc SDL_FillSurfaceRects*(dst: Surface; rects: ptr Rect; cnt: cint; colour: uint32): bool
proc SDL_BlitSurface*(src: Surface; src_rect: ptr Rect; dst: Surface; dst_rect: ptr Rect): bool
proc SDL_BlitSurfaceUnchecked*(src: Surface; src_rect: ptr Rect; dst: Surface; dst_rect: ptr Rect): bool
proc SDL_BlitSurfaceScaled*(src: Surface; src_rect: ptr Rect; dst: Surface; dst_rect: ptr Rect; scale_mode: ScaleMode): bool
proc SDL_BlitSurfaceUncheckedScaled*(src: Surface; src_rect: ptr Rect; dst: Surface; dst_rect: ptr Rect; scale_mode: ScaleMode): bool
proc SDL_StretchSurface*(src: Surface; src_rect: ptr Rect; dst: Surface; dst_rect: ptr Rect; scale_mode: ScaleMode): bool
proc SDL_BlitSurfaceTiled*(src: Surface; src_rect: ptr Rect; dst: Surface; dst_rect: ptr Rect): bool
proc SDL_BlitSurfaceTiledWithScale*(src: Surface; src_rect: ptr Rect; scale: cfloat; scale_mode: ScaleMode, dst: Surface; dst_rect: ptr Rect): bool
proc SDL_BlitSurface9Grid*(src: Surface; src_rect: ptr Rect; left_w, right_w, top_h, bottom_h: cint; scale: cfloat; scale_mode: ScaleMode, dst: Surface; dst_rect: ptr Rect): bool
proc SDL_MapSurfaceRGB*(surf: Surface; r, g, b: uint8): uint32
proc SDL_MapSurfaceRGBA*(surf: Surface; r, g, b, a: uint8): uint32
proc SDL_ReadSurfacePixel*(surf: Surface; x, y: cint; r, g, b, a: ptr uint8): bool
proc SDL_ReadSurfacePixelFloat*(surf: Surface; x, y: cint; r, g, b, a: ptr cfloat): bool
proc SDL_WriteSurfacePixel*(surf: Surface; x, y: cint; r, g, b, a: uint8): bool
proc SDL_WriteSurfacePixelFloat*(surf: Surface; x, y: cint; r, g, b, a: cfloat): bool
{.pop.}

{.push inline.}

proc destroy*(surf: Surface) =
    SDL_DestroySurface surf

proc copy*(surf: Surface): Surface =
    result = SDL_DuplicateSurface(surf)
    sdl_assert result != nil, &"Failed to copy surface ({surf[]})"

proc create_surface*(fmt: PixelFormat; w, h: distinct SomeInteger): Surface =
    result = SDL_CreateSurface(cint w, cint h, fmt)
    sdl_assert result != nil, &"Failed to create blank surface ({fmt}: {w}x{h})"

proc create_surface*(fmt: PixelFormat; pxs: pointer; w, h, pitch: distinct SomeInteger): Surface =
    result = SDL_CreateSurfaceFrom(pxs, cint w, cint h, cint pitch, fmt)
    sdl_assert result != nil, &"Failed to create surface from data ({fmt}: {w}x{h}, pitch = {pitch})"

proc properties*(surf: Surface): PropertyId   = SDL_GetSurfaceProperties surf
proc colourspace*(surf: Surface): Colourspace = SDL_GetSurfaceColorspace surf
proc props*(surf: Surface): PropertyId = properties surf

proc palette*(surf: Surface): Palette =
    result = SDL_GetSurfacePalette surf
    sdl_assert result != nil, &"Failed to get palette for surface ({surf[]})"

proc set_colourspace*(surf: Surface; colourspace: Colourspace): bool {.discardable.} =
    let success = surf.SDL_SetSurfaceColorspace colourspace
    sdl_assert success, &"Failed to set colourspace for surface to '{colourspace}' ({surf[]})"
proc `colourspace=`*(surf: Surface; colourspace: Colourspace) = set_colourspace surf, colourspace

proc set_palette*(surf: Surface; palette: Palette): bool {.discardable.} =
    let success = SDL_SetSurfacePalette(surf, palette)
    sdl_assert success, &"Failed to set palette for surface to '{palette[]}' ({surf[]})"
proc `palette=`*(surf: Surface; palette: Palette) = set_palette surf, palette

proc create_palette*(surf: Surface): Palette =
    SDL_CreateSurfacePalette surf

proc lock*(surf: Surface): bool = SDL_LockSurface surf
proc unlock*(surf: Surface)     = SDL_UnlockSurface surf

proc set_rle*(surf: Surface; enabled: bool): bool {.discardable.} =
    let success = SDL_SetSurfaceRLE(surf, enabled)
    sdl_assert success, &"Failed to set rle for surface to '{enabled}' ({surf[]})"
proc `rle=`*(surf: Surface; enabled: bool) = set_rle surf, enabled

proc has_rle*(surf: Surface): bool        = SDL_SurfaceHasRLE surf
proc has_colour_key*(surf: Surface): bool = SDL_SurfaceHasColorKey surf

proc alpha_mod*(surf: Surface): uint8 =
    let success = SDL_GetSurfaceAlphaMod(surf, result.addr)
    sdl_assert success, &"Failed to get alpha mod for surface ({surf[]})"
proc blend_mode*(surf: Surface): BlendMode =
    let success = SDL_GetSurfaceBlendMode(surf, result.addr)
    sdl_assert success, &"Failed to get blend mode for surface ({surf[]})"
proc clip_rect*(surf: Surface): Rect =
    let success = SDL_GetSurfaceClipRect(surf, result.addr)
    sdl_assert success, &"Failed to get clip rect for surface ({surf[]})"
proc colour_key*(surf: Surface): uint32 =
    let success = SDL_GetSurfaceColorKey(surf, result.addr)
    sdl_assert success, &"Failed to get colour key for surface ({surf[]})"
proc colour_mod*(surf: Surface): tuple[r, g, b: uint8] =
    let success = SDL_GetSurfaceColorMod(surf, result.r.addr, result.g.addr, result.b.addr)
    sdl_assert success, &"Failed to get colour mod for surface ({surf[]})"

proc set_colour_key*(surf: Surface; key: uint32): bool {.discardable.} =
    let success = SDL_SetSurfaceColorKey(surf, true, key)
    sdl_assert success, &"Failed to set colour key for surface to '0x{key:X}' ({surf[]})"
proc set_colour_mod*(surf: Surface; `mod`: tuple[r, g, b: uint8]): bool {.discardable.} =
    let success = SDL_SetSurfaceColorMod(surf, `mod`.r, `mod`.g, `mod`.b)
    sdl_assert success, &"Failed to set colour mod for surface to ({`mod`.r}, {`mod`.g}, {`mod`.b}) ({surf[]})"
proc set_alpha_mod*(surf: Surface; `mod`: uint8): bool {.discardable.} =
    let success = SDL_SetSurfaceAlphaMod(surf, `mod`)
    sdl_assert success, &"Failed to set alpha mod for surface to '{`mod`}' ({surf[]})"
proc set_blend_mode*(surf: Surface; blend_mode: BlendMode): bool {.discardable.} =
    let success = SDL_SetSurfaceBlendMode(surf, blend_mode)
    sdl_assert success, &"Failed to set blend mode for surface to '{blend_mode}' ({surf[]})"
proc set_clip_rect*(surf: Surface; rect: Rect): bool {.discardable.} =
    let success = SDL_SetSurfaceClipRect(surf, rect.addr)
    sdl_assert success, &"Failed to set clip rect for surface to '{rect}' ({surf[]})"

proc `colour_key=`*(surf: Surface; key: uint32)                  = set_colour_key surf, key
proc `colour_mod=`*(surf: Surface; `mod`: tuple[r, g, b: uint8]) = set_colour_mod surf, `mod`
proc `alpha_mod=`*(surf: Surface; `mod`: uint8)                  = set_alpha_mod surf, `mod`
proc `blend_mode=`*(surf: Surface; blend_mode: BlendMode)        = set_blend_mode surf, blend_mode
proc `clip_rect=`*(surf: Surface; rect: Rect)                    = set_clip_rect surf, rect

proc disable_colour_key*(surf: Surface): bool {.discardable.} =
    var ck: uint32
    if not SDL_GetSurfaceColorKey(surf, ck.addr):
        return true

    let success = SDL_SetSurfaceColorKey(surf, false, ck)
    sdl_assert success, &"Failed to disable colour key for surface ({surf[]})"

proc flip*(surf: Surface; flip: FlipMode): bool {.discardable.} =
    let success = SDL_FlipSurface(surf, flip)
    sdl_assert success, &"Failed to flip surface with flip mode '{flip}' ({surf[]})"

proc scale*(surf: Surface; w, h: distinct SomeInteger; mode: ScaleMode = Linear): Surface =
    result = SDL_ScaleSurface(surf, cint w, cint h, mode)
    sdl_assert result != nil, &"Failed to scale surface to {w}x{h} with mode '{mode}' ({surf[]})"

proc convert*(surf: Surface; fmt: PixelFormat): Surface =
    result = SDL_ConvertSurface(surf, fmt)
    sdl_assert result != nil, &"Failed to convert surface to {fmt} ({surf[]})"
proc convert*(surf: Surface; fmt: PixelFormat; palette: Palette; colourspace: Colourspace; props: PropertyId = InvalidProperty): Surface =
    result = SDL_ConvertSurfaceAndColorspace(surf, fmt, palette, colourspace, props)
    sdl_assert result != nil, &"Failed to convert surface with values (format: {fmt}; palette: {palette[]}; colourspace: {colourspace}; props: {props}) ({surf[]})"

proc premultiply_alpha*(surf: Surface; linear: bool): bool {.discardable.} =
    let success = SDL_PremultiplySurfaceAlpha(surf, linear)
    sdl_assert success, &"Failed to premultiply alpha for surface (linear: {linear}) (surf[])"

proc clear*(surf: Surface; r, g, b, a: float32): bool {.discardable.} =
    let success = SDL_ClearSurface(surf, cfloat r, cfloat g, cfloat b, cfloat a)
    sdl_assert success, &"Failed to clear surface with colour ({r}, {g}, {b}, {a}) ({surf[]})"
proc clear*(surf: Surface; colour: ColourF): bool {.discardable.}    = clear surf, colour.r, colour.g, colour.b, colour.a
proc fill*(surf: Surface; r, g, b, a: float32): bool {.discardable.} = clear surf, r, g, b, a
proc fill*(surf: Surface; colour: ColourF): bool {.discardable.}     = clear surf, colour

proc fill*(surf: Surface; rect: Rect; colour: uint32 | Colour): bool {.discardable.} =
    let success = SDL_FillSurfaceRect(surf, rect.addr, colour)
    sdl_assert success, &"Failed to fill surface rect '{rect}' with colour '0x{colour:X}' ({surf[]})"
proc fill*(surf: Surface; rects: openArray[Rect]; colour: uint32 | Colour): bool {.discardable.} =
    let success = SDL_FillSurfaceRects(surf, rects[0].addr, cint rects.len, colour)
    sdl_assert success, &"Failed to fill surface rects '{rects}' with colour '0x{colour:X}' ({surf[]})"

func ropt(r: Rect | Option[Rect]): ptr Rect =
    when r is Rect:
        r.addr
    else:
        if r.is_some:
            (get r).addr
        else: nil
proc blit*(src: Surface; src_rect: Rect | Option[Rect]; dst: Surface; dst_rect: Rect | Option[Rect]): bool {.discardable.} =
    let success = SDL_BlitSurface(src, ropt src_rect, dst, ropt dst_rect)
    sdl_assert success, &"Failed to blit from surface ({src_rect}: {src[]}) to ({dst_rect}: {dst[]})"
proc blit*(src: Surface; src_rect: Rect | Option[Rect]; dst: Surface; dst_rect: Rect | Option[Rect]; scale_mode: ScaleMode): bool {.discardable.} =
    let success = SDL_BlitSurfaceScaled(src, ropt src_rect, dst, ropt dst_rect, scale_mode)
    sdl_assert success, &"Failed to blit from surface scaled '{scale_mode}' ({src_rect}: {src[]}) to ({dst_rect}: {dst[]})"

proc blit_tiled*(src: Surface; src_rect: Rect | Option[Rect]; dst: Surface; dst_rect: Rect | Option[Rect]): bool {.discardable.} =
    let success = SDL_BlitSurfaceTiled(src, ropt src_rect, dst, ropt dst_rect)
    sdl_assert success, &"Failed to blit from surface tiled ({src_rect}: {src[]}) to ({dst_rect}: {dst[]})"
proc blit_tiled*(src: Surface; src_rect: Rect | Option[Rect]; dst: Surface; dst_rect: Rect | Option[Rect]; scale: SomeNumber; scale_mode: ScaleMode): bool {.discardable.} =
    let success = SDL_BlitSurfaceTiledWithScale(src, ropt src_rect, cfloat scale, dst, ropt dst_rect, scale_mode)
    sdl_assert success, &"Failed to blit from surface tiled and scaled (x{scale}) '{scale_mode}' ({src_rect}: {src[]}) to ({dst_rect}: {dst[]})"

proc blit_9grid*(src: Surface; src_rect: Rect | Option[Rect]; dst: Surface; dst_rect: Rect | Option[Rect];
                 left_w, right_w, top_h, bottom_h: distinct SomeNumber;
                 scale: SomeNumber; scale_mode: ScaleMode;
                 ): bool {.discardable.} =
    let success = SDL_BlitSurface9Grid(src, ropt src_rect,
                                       cint left_w, cint right_w,
                                       cint top_h , cint bottom_h,
                                       cfloat scale, scale_mode, dst, ropt dst_rect)
    sdl_assert success, &"Failed to blit 9grid to surface [{left_w}, {right_h}, {top_h}, {bottom_h}] (scalex{scale} {scale_mode}) ({src_rect}: {src[]}) to ({dst_rect}: {dst[]})"

proc stretch*(src: Surface; src_rect: Rect | Option[Rect]; dst: Surface; dst_rect: Rect | Option[Rect]; scale_mode: ScaleMode): bool {.discardable.} =
    let success = SDL_StretchSurface(src, ropt src_rect, dst, ropt dst_rect, scale_mode)
    sdl_assert success, &"Failed to stretch surface '{scale_mode}' ({src_rect}: {src[]}) to ({dst_rect}: {dst[]})"

proc map*(surf: Surface; r, g, b: uint8): Colour    = SDL_MapSurfaceRGB surf, r, g, b
proc map*(surf: Surface; r, g, b, a: uint8): Colour = SDL_MapSurfaceRGBA surf, r, g, b, a
proc map*(surf: Surface; colour: Colour): Colour    = SDL_MapSurfaceRGBA surf, colour.r, colour.g, colour.b, colour.a

proc read_pixel*(surf: Surface; x, y: distinct SomeNumber): Colour =
    let success = SDL_ReadSurfacePixel(surf, cint x, cint y, result.r.addr, result.g.addr, result.b.addr, result.a.addr)
    sdl_assert success, &"Failed to read pixel at {x}x{y} ({surf[]})"
proc read_pixel_float*(surf: Surface; x, y: distinct SomeNumber): ColourF =
    let success = SDL_ReadSurfacePixelFloat(surf, cint x, cint y, result.r.addr, result.g.addr, result.b.addr, result.a.addr)
    sdl_assert success, &"Failed to read pixel at {x}x{y} ({surf[]})"

proc write_pixel*(surf: Surface; x, y: distinct SomeNumber; r, g, b, a: uint8): Colour =
    let success = SDL_WriteSurfacePixel(surf, cint x, cint y, result.r, result.g, result.b, result.a)
    sdl_assert success, &"Failed to write pixel at {x}x{y} ({r}, {g}, {b}, {a}) ({surf[]})"
proc write_pixel*(surf: Surface; x, y: distinct SomeNumber; r, g, b, a: distinct SomeFloat): ColourF =
    let success = SDL_WriteSurfacePixelFloat(surf, cint x, cint y, cfloat result.r, cfloat result.g, cfloat result.b, cfloat result.a)
    sdl_assert success, &"Failed to write pixel at {x}x{y} ({r}, {g}, {b}, {a}) ({surf[]})"
proc write_pixel*(surf: Surface; x, y: distinct SomeNumber; colour: Colour | ColourF): Colour =
    write_pixel surf, x, y, colour.r, colour.g, colour.b, colour.a

proc `[]`*(surf: Surface; x, y: distinct SomeNumber): Colour =
    read_pixel surf, x, y
proc `[]=`*(surf: Surface; x, y: distinct SomeNumber; colour: Colour | ColourF): Colour =
    write_pixel surf, x, y, colour

{.pop.}

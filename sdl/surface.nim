import common, bitgen, pixels, rect

type SurfaceFlag* = distinct uint32
SurfaceFlag.gen_bit_ops surfacePreAlloc, surfaceRleAccel, surfaceDontFree, surfaceSimdAligned, surfaceUsesProperties

type
    FlipMode* {.size: sizeof(cint).} = enum
        flipNone
        flipHorizontal
        flipVertical

    ScaleMode* {.size: sizeof(cint).} = enum
        scaleNearest
        scaleLinear
        scaleBest

type
    BlitMap* = object
        _: pointer

    Surface* = ptr SurfaceObj
    SurfaceObj* = object
        flags*    : SurfaceFlag
        fmt*      : PixelFormat
        w*, h*    : cint
        pitch*    : cint
        pxs*      : pointer
        ref_count*: cint
        _         : pointer

func must_lock*(surf: Surface): bool =
    (surf.flags and surfaceRleAccel) != SurfaceFlag 0

#[ -------------------------------------------------------------------- ]#

# import properties
type PropertyId = uint32
using surf: Surface

{.push dynlib: SdlLib.}
proc sdl_create_surface*(w, h: cint; fmt: PixelFormat): Surface                              {.importc: "SDL_CreateSurface"       .}
proc sdl_create_surface_from*(pixels: pointer; w, h, pitch: cint; fmt: PixelFormat): Surface {.importc: "SDL_CreateSurfaceFrom"   .}
proc sdl_destroy_surface*(surf)                                                              {.importc: "SDL_DestroySurface"      .}
proc sdl_get_surface_properties*(surf): PropertyID                                           {.importc: "SDL_GetSurfaceProperties".}
proc sdl_get_surface_palette*(surf; palette: ptr Palette): cbool                             {.importc: "SDL_SetSurfacePalette"   .}

proc sdl_lock_surface*(surf): cint {.importc: "SDL_LockSurface"  .}
proc sdl_unlock_surface*(surf)     {.importc: "SDL_UnlockSurface".}

proc sdl_set_surface_colourspace*(surf; colourspace: Colourspace): cbool     {.importc: "SDL_SetSurfaceColorspace".}
proc sdl_get_surface_colourspace*(surf; colourspace: ptr Colourspace): cbool {.importc: "SDL_GetSurfaceColorspace".}

proc sdl_duplicate_surface*(surf): Surface                 {.importc: "SDL_DuplicateSurface".}
proc sdl_convert_surface*(surf; fmt: PixelFormat): pointer {.importc: "SDL_ConvertSurface"  .}
{.pop.}

{.push inline.}

proc `=destroy`*(surf: SurfaceObj) = sdl_destroy_surface surf.addr

proc create_surface*(fmt: PixelFormat; w, h: int32): Surface =
    sdl_create_surface w, h, fmt

proc create_surface*(fmt: PixelFormat; pxs: pointer; w, h, pitch: int32): Surface =
    sdl_create_surface_from pxs, w, h, pitch, fmt

proc palette*(surf): Palette = assert not sdl_get_surface_palette(surf, result.addr)

proc lock*(surf): bool = 0 == sdl_lock_surface surf
proc unlock*(surf) = sdl_unlock_surface surf

proc convert*(surf: Surface; fmt: PixelFormat; destroy_after = true): (Surface, bool) =
    let new_surf = sdl_convert_surface(surf, fmt)
    if destroy_after:
        `=destroy` surf[]

    result[0] = cast[ptr Surface](new_surf)[]
    result[1] = new_surf == nil

{.pop.}

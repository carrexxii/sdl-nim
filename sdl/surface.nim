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
    BlitMap* = distinct pointer

    Surface* = ptr SurfaceObj
    SurfaceObj* = object
        flags*    : SurfaceFlag
        fmt*      : PixelFormat
        w*, h*    : cint
        pitch*    : cint
        pxs*      : pointer
        ref_count*: cint
        _         : pointer

converter `BlitMap -> bool`*(bmap: BlitMap): bool = cast[pointer](bmap) != nil
converter `Surface -> bool`*(surf: Surface): bool = cast[pointer](surf) != nil

func must_lock*(surf: Surface): bool =
    (surf.flags and surfaceRleAccel) != SurfaceFlag 0

#[ -------------------------------------------------------------------- ]#

from properties import PropertyId

using surf: Surface

{.push dynlib: SdlLib.}
proc sdl_create_surface*(w, h: cint; fmt: PixelFormat): Surface                              {.importc: "SDL_CreateSurface"       .}
proc sdl_create_surface_from*(pixels: pointer; w, h, pitch: cint; fmt: PixelFormat): Surface {.importc: "SDL_CreateSurfaceFrom"   .}
proc sdl_destroy_surface*(surf)                                                              {.importc: "SDL_DestroySurface"      .}
proc sdl_get_surface_properties*(surf): PropertyId                                           {.importc: "SDL_GetSurfaceProperties".}
proc sdl_get_surface_palette*(surf; palette: ptr Palette): bool                              {.importc: "SDL_SetSurfacePalette"   .}

proc sdl_lock_surface*(surf): cint {.importc: "SDL_LockSurface"  .}
proc sdl_unlock_surface*(surf)     {.importc: "SDL_UnlockSurface".}

proc sdl_set_surface_colourspace*(surf; colourspace: Colourspace): bool     {.importc: "SDL_SetSurfaceColorspace".}
proc sdl_get_surface_colourspace*(surf; colourspace: ptr Colourspace): bool {.importc: "SDL_GetSurfaceColorspace".}

proc sdl_duplicate_surface*(surf): Surface                 {.importc: "SDL_DuplicateSurface".}
proc sdl_convert_surface*(surf; fmt: PixelFormat): Surface {.importc: "SDL_ConvertSurface"  .}
{.pop.}

{.push inline.}

proc `=destroy`*(surf: SurfaceObj) = sdl_destroy_surface surf.addr

proc create_surface*(fmt: PixelFormat; w, h: SomeInteger): Surface =
    result = sdl_create_surface(cint w, cint h, fmt)
    sdl_assert result, &"Failed to create blank surface ({w}x{h}, {fmt})"

proc create_surface*(fmt: PixelFormat; pxs: pointer; w, h, pitch: SomeInteger): Surface =
    result = sdl_create_surface_from(pxs, cint w, cint h, cint pitch, fmt)
    sdl_assert result, &"Failed to create surface from data ({w}x{h}, {fmt}, pitch = {pitch})"

proc palette*(surf): Palette =
    let success = sdl_get_surface_palette(surf, result.addr)
    sdl_assert success, &"Failed to get palette for surface"

proc lock*(surf): bool = 0 == sdl_lock_surface surf
proc unlock*(surf)     = sdl_unlock_surface surf

proc convert*(surf: Surface; fmt: PixelFormat; destroy_after = true): Surface =
    let new_surf = sdl_convert_surface(surf, fmt)
    sdl_assert new_surf, &"Failed to convert surface to {fmt}"
    if destroy_after:
        `=destroy` surf[]

    result = new_surf

{.pop.}

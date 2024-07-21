import common, bitgen, pixels, rect

type SurfaceFlag* = distinct uint32
SurfaceFlag.gen_bit_ops(
    sfPreAlloc, sfRLEAccel, sfDontFree, sfSIMDAligned,
    sfSurfaceUsesProperties
)

type
    FlipMode* {.size: sizeof(cint).} = enum
        fmNone
        fmHorizontal
        fmVertical

    ScaleMode* {.size: sizeof(cint).} = enum
        smNearest
        smLinear
        smBest

type
    BlitMap* = distinct pointer

    Surface* = ptr SurfaceObj
    SurfaceObj* = object
        flags*      : SurfaceFlag
        format*     : ptr PixelFormat
        w*, h*      : int32
        pitch*      : int32
        pixels*     : pointer
        reserved    : pointer
        locked      : int32
        blitmap_list: pointer
        clip_rect   : Rect
        map         : BlitMap
        ref_count   : int32

func must_lock*(surface: Surface): bool =
    (surface.flags and sfRLEAccel) != SurfaceFlag 0

#[ -------------------------------------------------------------------- ]#

import properties

{.push dynlib: SDLLib.}
proc sdl_create_surface*(w, h: cint; fmt: PixelFormatKind): Surface                              {.importc: "SDL_CreateSurface"       .}
proc sdl_create_surface_from*(pixels: pointer; w, h, pitch: cint; fmt: PixelFormatKind): Surface {.importc: "SDL_CreateSurfaceFrom"   .}
proc sdl_destroy_surface*(surface: Surface)                                                      {.importc: "SDL_DestroySurface"      .}
proc sdl_get_surface_properties*(surface: Surface): PropertyID                                   {.importc: "SDL_GetSurfaceProperties".}

proc sdl_set_surface_colourspace*(surface: Surface; colourspace: Colourspace): cint     {.importc: "SDL_SetSurfaceColorspace".}
proc sdl_get_surface_colourspace*(surface: Surface; colourspace: ptr Colourspace): cint {.importc: "SDL_GetSurfaceColorspace".}

proc sdl_duplicate_surface*(surface: Surface): Surface                            {.importc: "SDL_DuplicateSurface"    .}
proc sdl_convert_surface*(surface: Surface; fmt: PixelFormat): Surface            {.importc: "SDL_ConvertSurface"      .}
proc sdl_convert_surface_format*(surface: Surface; fmt: PixelFormatKind): Surface {.importc: "SDL_ConvertSurfaceFormat".}
proc sdl_convert_surface_format_and_colourspace*(surface: Surface; fmt: PixelFormatKind; colourspace: Colourspace;
                                                 props: PropertyID): Surface {.importc: "SDL_ConvertSurfaceFormatAndColorspace".}
{.pop.}

{.push inline.}

proc create_surface*(fmt: PixelFormatKind; w, h: int): Surface =
    sdl_create_surface cint w, cint h, fmt

proc create_surface*(fmt: PixelFormatKind; pixels: pointer; w, h, pitch: int): Surface =
    sdl_create_surface_from pixels, cint w, cint h, cint pitch, fmt

proc destroy*(surface: var Surface) =
    sdl_destroy_surface surface

proc convert*(surface: var Surface; fmt: PixelFormatKind; destroy_after = true): Surface =
    result = sdl_convert_surface_format(surface, fmt)
    if destroy_after:
        destroy surface

{.pop.}

# int SDL_SetSurfacePalette(SDL_Surface *surface, SDL_Palette *palette);
# int SDLCALL SDL_LockSurface(SDL_Surface *surface);
# void SDLCALL SDL_UnlockSurface(SDL_Surface *surface);
# SDL_Surface *SDLCALL SDL_LoadBMP_IO(SDL_IOStream *src, SDL_bool closeio);
# SDL_Surface *SDLCALL SDL_LoadBMP(const char *file);
# int SDLCALL SDL_SaveBMP_IO(SDL_Surface *surface, SDL_IOStream *dst, SDL_bool closeio);
# int SDLCALL SDL_SaveBMP(SDL_Surface *surface, const char *file);
# int SDLCALL SDL_SetSurfaceRLE(SDL_Surface *surface, int flag);
# SDL_bool SDLCALL SDL_SurfaceHasRLE(SDL_Surface *surface);
# int SDLCALL SDL_SetSurfaceColorKey(SDL_Surface *surface, int flag, Uint32 key);
# SDL_bool SDLCALL SDL_SurfaceHasColorKey(SDL_Surface *surface);
# int SDLCALL SDL_GetSurfaceColorKey(SDL_Surface *surface, Uint32 *key);
# int SDLCALL SDL_SetSurfaceColorMod(SDL_Surface *surface, Uint8 r, Uint8 g, Uint8 b);
# int SDLCALL SDL_GetSurfaceColorMod(SDL_Surface *surface, Uint8 *r, Uint8 *g, Uint8 *b);
# int SDLCALL SDL_SetSurfaceAlphaMod(SDL_Surface *surface, Uint8 alpha);
# int SDLCALL SDL_GetSurfaceAlphaMod(SDL_Surface *surface, Uint8 *alpha);
# int SDLCALL SDL_SetSurfaceBlendMode(SDL_Surface *surface, SDL_BlendMode blendMode);
# int SDLCALL SDL_GetSurfaceBlendMode(SDL_Surface *surface, SDL_BlendMode *blendMode);
# SDL_bool SDLCALL SDL_SetSurfaceClipRect(SDL_Surface *surface, const SDL_Rect *rect);
# int SDLCALL SDL_GetSurfaceClipRect(SDL_Surface *surface, SDL_Rect *rect);
# int SDLCALL SDL_FlipSurface(SDL_Surface *surface, SDL_FlipMode flip);

# int SDLCALL SDL_ConvertPixels(int width, int height, SDL_PixelFormatEnum src_format, const void *src, int src_pitch, SDL_PixelFormatEnum dst_format, void *dst, int dst_pitch);
# int SDLCALL SDL_ConvertPixelsAndColorspace(int width, int height, SDL_PixelFormatEnum src_format, SDL_Colorspace src_colorspace, SDL_PropertiesID src_properties, const void *src, int src_pitch, SDL_PixelFormatEnum dst_format, SDL_Colorspace dst_colorspace, SDL_PropertiesID dst_properties, void *dst, int dst_pitch);
# int SDLCALL SDL_PremultiplyAlpha(int width, int height, SDL_PixelFormatEnum src_format, const void *src, int src_pitch, SDL_PixelFormatEnum dst_format, void *dst, int dst_pitch);

# int SDLCALL SDL_FillSurfaceRect(SDL_Surface *dst, const SDL_Rect *rect, Uint32 color);
# int SDLCALL SDL_FillSurfaceRects(SDL_Surface *dst, const SDL_Rect *rects, int count, Uint32 color);
# int SDLCALL SDL_BlitSurface(SDL_Surface *src, const SDL_Rect *srcrect, SDL_Surface *dst, SDL_Rect *dstrect);
# int SDLCALL SDL_BlitSurfaceUnchecked(SDL_Surface *src, const SDL_Rect *srcrect, SDL_Surface *dst, const SDL_Rect *dstrect);
# int SDLCALL SDL_SoftStretch(SDL_Surface *src, const SDL_Rect *srcrect, SDL_Surface *dst, const SDL_Rect *dstrect, SDL_ScaleMode scaleMode);
# int SDLCALL SDL_BlitSurfaceScaled(SDL_Surface *src, const SDL_Rect *srcrect, SDL_Surface *dst, SDL_Rect *dstrect, SDL_ScaleMode scaleMode);
# int SDLCALL SDL_BlitSurfaceUncheckedScaled(SDL_Surface *src, const SDL_Rect *srcrect, SDL_Surface *dst, const SDL_Rect *dstrect, SDL_ScaleMode scaleMode);
# int SDLCALL SDL_ReadSurfacePixel(SDL_Surface *surface, int x, int y, Unt8 *r, Uint8 *g, Uint8 *b, Uint8 *a);


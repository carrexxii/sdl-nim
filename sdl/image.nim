import std/macros, common, iostream, surface, renderer
from std/strutils import to_upper_ascii

type
    Animation* = distinct pointer
    AnimationObj = object
        w*, h* : int32
        cnt*   : int32
        frames*: ptr UncheckedArray[ptr Surface]
        delays*: ptr UncheckedArray[int32]

proc IMG_FreeAnimation*(anim: Animation) {.importc, cdecl, dynlib: SdlImageLib.}
proc free*(anim: Animation) =
    IMG_FreeAnimation anim

converter `Animation -> bool`*(anim: Animation): bool = nil != pointer anim

proc w*(anim: Animation): int32                                = cast[ptr AnimationObj](anim).w
proc h*(anim: Animation): int32                                = cast[ptr AnimationObj](anim).h
proc cnt*(anim: Animation): int32                              = cast[ptr AnimationObj](anim).cnt
proc frames*(anim: Animation): ptr UncheckedArray[ptr Surface] = cast[ptr AnimationObj](anim).frames
proc delays*(anim: Animation): ptr UncheckedArray[int32]       = cast[ptr AnimationObj](anim).delays

{.push importc, cdecl, dynlib: SdlImageLib.}
proc IMG_Version*(): Version
proc IMG_LoadTyped_IO*(src: IoStream; close_io: bool; ext: cstring): Surface
proc IMG_Load*(file: cstring): Surface
proc IMG_Load_IO*(src: IoStream; close_io: bool): Surface
proc IMG_LoadTexture*(ren: Renderer; file: cstring): Texture
proc IMG_LoadTexture_IO*(ren: Renderer; src: IoStream; close_io: bool): Texture
proc IMG_LoadTextureTyped_IO*(ren: Renderer; src: IoStream; close_io: bool; `type`: cstring): Texture

proc IMG_isAVIF*(src: IoStream): bool
proc IMG_isICO*(src: IoStream): bool
proc IMG_isCUR*(src: IoStream): bool
proc IMG_isBMP*(src: IoStream): bool
proc IMG_isGIF*(src: IoStream): bool
proc IMG_isJPG*(src: IoStream): bool
proc IMG_isJXL*(src: IoStream): bool
proc IMG_isLBM*(src: IoStream): bool
proc IMG_isPCX*(src: IoStream): bool
proc IMG_isPNG*(src: IoStream): bool
proc IMG_isPNM*(src: IoStream): bool
proc IMG_isSVG*(src: IoStream): bool
proc IMG_isQOI*(src: IoStream): bool
proc IMG_isTIF*(src: IoStream): bool
proc IMG_isXCF*(src: IoStream): bool
proc IMG_isXPM*(src: IoStream): bool
proc IMG_isXV*(src: IoStream): bool
proc IMG_isWEBP*(src: IoStream): bool

proc IMG_LoadAVIF_IO*(src: IoStream): Surface
proc IMG_LoadICO_IO*(src: IoStream): Surface
proc IMG_LoadCUR_IO*(src: IoStream): Surface
proc IMG_LoadBMP_IO*(src: IoStream): Surface
proc IMG_LoadGIF_IO*(src: IoStream): Surface
proc IMG_LoadJPG_IO*(src: IoStream): Surface
proc IMG_LoadJXL_IO*(src: IoStream): Surface
proc IMG_LoadLBM_IO*(src: IoStream): Surface
proc IMG_LoadPCX_IO*(src: IoStream): Surface
proc IMG_LoadPNG_IO*(src: IoStream): Surface
proc IMG_LoadPNM_IO*(src: IoStream): Surface
proc IMG_LoadSVG_IO*(src: IoStream): Surface
proc IMG_LoadQOI_IO*(src: IoStream): Surface
proc IMG_LoadTGA_IO*(src: IoStream): Surface
proc IMG_LoadTIF_IO*(src: IoStream): Surface
proc IMG_LoadXCF_IO*(src: IoStream): Surface
proc IMG_LoadXPM_IO*(src: IoStream): Surface
proc IMG_LoadXV_IO*(src: IoStream): Surface
proc IMG_LoadWEBP_IO*(src: IoStream): Surface
proc IMG_LoadSizedSVG_IO*(src: IoStream; w, h: cint): Surface
proc IMG_ReadXPMFromArray*(xpm: ptr ptr char): Surface
proc IMG_ReadXPMFromArrayToRGB888*(xpm: ptr ptr char): Surface

proc IMG_SaveAVIF*(surface: Surface; file: cstring; quality: cint): bool
proc IMG_SaveAVIF_IO*(surface: Surface; dst: IoStream; close_io: bool; quality: cint): bool
proc IMG_SavePNG*(surface: Surface; file: cstring): bool
proc IMG_SavePNG_IO*(surface: Surface; dst: IoStream; close_io: bool): bool
proc IMG_SaveJPG*(surface: Surface; file: cstring; quality: cint): bool
proc IMG_SaveJPG_IO*(surface: Surface; dst: IoStream; close_io: bool; quality: cint): bool

proc IMG_LoadAnimation*(file: cstring): Animation
proc IMG_LoadAnimation_IO*(src: IoStream; close_io: bool): Animation
proc IMG_LoadAnimationTyped_IO*(src: IoStream; close_io: bool; `type`: cstring): Animation
proc IMG_LoadGIFAnimation_IO*(src: IoStream): Animation
proc IMG_LoadWEBPAnimation_IO*(src: IoStream): Animation
{.pop.}

{.push inline.}

proc image_version*(): Version =
    IMG_Version()

proc load*(stream: IoStream; close_io = false; ext = ""): Surface =
    if ext.len > 0:
        result = IMG_LoadTyped_IO(stream, close_io, cstring ext)
    else:
        result = IMG_Load_IO(stream, close_io)
    sdl_assert result, &"Failed to load image from IoStream (type: '{ext}')"

proc load*(file: string): Surface =
    result = IMG_Load cstring file
    sdl_assert result, &"Failed to load image from file '{file}'"

proc load_texture*(ren: Renderer; file: string): Texture =
    result = IMG_LoadTexture(ren, cstring file)
    sdl_assert result, &"Failed to load texture from file '{file}'"

proc load_texture*(ren: Renderer; stream: IoStream; close_io = false; ext = ""): Texture =
    if ext.len > 0:
        result = IMG_LoadTextureTyped_IO(ren, stream, close_io, cstring ext)
    else:
        result = IMG_LoadTexture_IO(ren, stream, close_io)
    sdl_assert result, &"Failed to load texture from stream (type: '{ext}')"

macro is_x(lst: untyped): untyped =
    result = new_stmt_list()
    for ext in lst:
        let ext = $ext
        let fn  = ident("is_" & ext)
        let cfn = ident("IMG_is" & to_upper_ascii(ext))
        result.add quote do:
            proc `fn`*(stream: IoStream): bool = `cfn` stream
is_x [avif, ico, cur, bmp, gif, jpg, jxl, lbm, pcx, png, pnm, svg, qoi, tif, xcf, xpm, xv, webp]

macro load_x(lst: untyped): untyped =
    result = new_stmt_list()
    for ext in lst:
        let ext = $ext
        let fn  = ident("load_" & ext)
        let cfn = ident("IMG_Load" & to_upper_ascii(ext) & "_IO")
        result.add quote do:
            proc `fn`*(stream: IoStream): Surface =
                result = `cfn` stream
                sdl_assert result, "Failed to load '" & `ext` & "' from IoStream"
load_x [avif, ico, cur, bmp, gif, jpg, jxl, lbm, pcx, png, pnm, svg, qoi, tga, tif, xcf, xpm, xv, webp]

proc load_svg*(stream: IoStream; w, h: distinct SomeInteger): Surface =
    result = IMG_LoadSizedSVG_IO(stream, cint w, cint h)
    sdl_assert result, &"Failed to load SVG from stream with size {w}x{h}"
proc xpm_from_array*(xpm: openArray[byte]): Surface =
    result = IMG_ReadXPMFromArray cast[ptr ptr char](xpm[0].addr)
    sdl_assert result, &"Failed to create xpm image from array (len: {xpm.len})"

proc save_avif*(surface: Surface; file: string; quality: range[0..100]): bool =
    result = IMG_SaveAVIF(surface, cstring file, cint quality)
    sdl_assert result, &"Failed to save surface as AVIF to '{file}' (quality: {quality})"
proc save_avif*(surface: Surface; stream: IoStream; quality: range[0..100]; close_io = false): bool =
    result = IMG_SaveAVIF_IO(surface, stream, close_io, cint quality)
    sdl_assert result, &"Failed to save surface as AVIF to stream (quality: {quality})"

proc save_png*(surface: Surface; file: string): bool =
    result = IMG_SavePNG(surface, cstring file)
    sdl_assert result, &"Failed to save surface as PNG to '{file}'"
proc save_png*(surface: Surface; stream: IoStream; close_io = false): bool =
    result = IMG_SavePNG_IO(surface, stream, close_io)
    sdl_assert result, &"Failed to save surface as PNG to stream"

proc save_jpg*(surface: Surface; file: string; quality: range[0..100]): bool =
    result = IMG_SaveJPG(surface, cstring file, cint quality)
    sdl_assert result, &"Failed to save surface as JPG to '{file}' (quality: {quality})"
proc save_jpg*(surface: Surface; stream: IoStream; quality: range[0..100]; close_io = false): bool =
    result = IMG_SaveJPG_IO(surface, stream, close_io, cint quality)
    sdl_assert result, &"Failed to save surface as JPG to stream (quality: {quality})"

proc load_animation*(file: string): Animation =
    result = IMG_LoadAnimation cstring file
    sdl_assert result, &"Failed to load animation from file '{file}'"

proc load_animation*(stream: IoStream; ext = ""; close_io = false): Animation =
    if ext.len > 0:
        result = IMG_LoadAnimationTyped_IO(stream, close_io, cstring ext)
    else:
        result = IMG_LoadAnimation_IO(stream, close_io)
    sdl_assert result, &"Failed to load animation from stream"

proc load_gif_animation*(stream: IoStream): Animation =
    result = IMG_LoadGIFAnimation_IO stream
    sdl_assert result, &"Failed to load GIF animation from stream"

proc load_webp_animation*(stream: IoStream): Animation =
    result = IMG_LoadWEBPAnimation_IO stream
    sdl_assert result, &"Failed to load WEBP animation from stream"

{.pop.}

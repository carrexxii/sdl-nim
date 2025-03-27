import common, iostream, surface, renderer

# TODO: add a wrapper for `=destroy` on animations

type Animation* = object
    w*, h* : int32
    cnt*   : int32
    frames*: ptr UncheckedArray[ptr Surface]
    delays*: ptr UncheckedArray[int32]

{.push importc, dynlib: SdlImageLib.}
proc IMG_Version*(): Version
proc IMG_LoadTyped_IO*(src: IoStream; close_io: bool; ext: cstring): ptr SurfaceObj
proc IMG_Load*(file: cstring): ptr SurfaceObj
proc IMG_Load_IO*(src: IoStream; close_io: bool): ptr SurfaceObj
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

proc IMG_LoadAVIF_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadICO_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadCUR_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadBMP_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadGIF_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadJPG_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadJXL_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadLBM_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadPCX_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadPNG_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadPNM_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadSVG_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadQOI_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadTGA_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadTIF_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadXCF_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadXPM_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadXV_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadWEBP_IO*(src: IoStream): ptr SurfaceObj
proc IMG_LoadSizedSVG_IO*(src: IoStream; w, h: cint): ptr SurfaceObj
proc IMG_ReadXPMFromArray*(xpm: ptr ptr char): ptr SurfaceObj
proc IMG_ReadXPMFromArrayToRGB888*(xpm: ptr ptr char): ptr SurfaceObj

proc IMG_SaveAVIF*(surface: ptr SurfaceObj; file: cstring; quality: cint): bool
proc IMG_SaveAVIF_IO*(surface: ptr SurfaceObj; dst: IoStream; close_io: bool; quality: cint): bool
proc IMG_SavePNG*(surface: ptr SurfaceObj; file: cstring): bool
proc IMG_SavePNG_IO*(surface: ptr SurfaceObj; dst: IoStream; close_io: bool): bool
proc IMG_SaveJPG*(surface: ptr SurfaceObj; file: cstring; quality: cint): bool
proc IMG_SaveJPG_IO*(surface: ptr SurfaceObj; dst: IoStream; close_io: bool; quality: cint): bool

proc IMG_LoadAnimation*(file: cstring): ptr Animation
proc IMG_LoadAnimation_IO*(src: IoStream; close_io: bool): ptr Animation
proc IMG_LoadAnimationTyped_IO*(src: IoStream; close_io: bool; `type`: cstring): ptr Animation
proc IMG_LoadGIFAnimation_IO*(src: IoStream): ptr Animation
proc IMG_LoadWEBPAnimation_IO*(src: IoStream): ptr Animation
proc IMG_FreeAnimation*(anim: ptr Animation)
{.pop.}

{.push inline.}

proc image_version*(): Version =
    IMG_Version()

proc load*(stream: IoStream; close_io = false; ext = ""): ptr SurfaceObj =
    if ext.len > 0:
        result = IMG_LoadTyped_IO(stream, close_io, cstring ext)
    else:
        result = IMG_Load_IO(stream, close_io)
    sdl_assert result, &"Failed to load image from IoStream (type: '{ext}')"

proc load*(file: string): ptr SurfaceObj =
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

proc is_avif*(stream: IoStream): bool = IMG_isAVIF stream
proc is_ico*(stream: IoStream): bool  = IMG_isICO stream
proc is_cur*(stream: IoStream): bool  = IMG_isCUR stream
proc is_bmp*(stream: IoStream): bool  = IMG_isBMP stream
proc is_gif*(stream: IoStream): bool  = IMG_isGIF stream
proc is_jpg*(stream: IoStream): bool  = IMG_isJPG stream
proc is_jxl*(stream: IoStream): bool  = IMG_isJXL stream
proc is_lbm*(stream: IoStream): bool  = IMG_isLBM stream
proc is_pcx*(stream: IoStream): bool  = IMG_isPCX stream
proc is_png*(stream: IoStream): bool  = IMG_isPNG stream
proc is_pnm*(stream: IoStream): bool  = IMG_isPNM stream
proc is_svg*(stream: IoStream): bool  = IMG_isSVG stream
proc is_qoi*(stream: IoStream): bool  = IMG_isQOI stream
proc is_tif*(stream: IoStream): bool  = IMG_isTIF stream
proc is_xcf*(stream: IoStream): bool  = IMG_isXCF stream
proc is_xpm*(stream: IoStream): bool  = IMG_isXPM stream
proc is_xv*(stream: IoStream): bool   = IMG_isXV stream
proc is_webp*(stream: IoStream): bool = IMG_isWEBP stream

proc load_avif*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadAVIF_IO stream
    sdl_assert result, &"Failed to load AVIF from IoStream"
proc load_ico*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadICO_IO stream
    sdl_assert result, &"Failed to load ICO from IoStream"
proc load_cur*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadCUR_IO stream
    sdl_assert result, &"Failed to load CUR from IoStream"
proc load_bmp*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadBMP_IO stream
    sdl_assert result, &"Failed to load BMP from IoStream"
proc load_gif*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadGIF_IO stream
    sdl_assert result, &"Failed to load GIF from IoStream"
proc load_jpg*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadJPG_IO stream
    sdl_assert result, &"Failed to load JPG from IoStream"
proc load_jxl*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadJXL_IO stream
    sdl_assert result, &"Failed to load JXL from IoStream"
proc load_lbm*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadLBM_IO stream
    sdl_assert result, &"Failed to load LBM from IoStream"
proc load_pcx*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadPCX_IO stream
    sdl_assert result, &"Failed to load PCX from IoStream"
proc load_png*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadPNG_IO stream
    sdl_assert result, &"Failed to load PNG from IoStream"
proc load_pnm*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadPNM_IO stream
    sdl_assert result, &"Failed to load PNM from IoStream"
proc load_svg*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadSVG_IO stream
    sdl_assert result, &"Failed to load SVG from IoStream"
proc load_qoi*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadQOI_IO stream
    sdl_assert result, &"Failed to load QOI from IoStream"
proc load_tga*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadTGA_IO stream
    sdl_assert result, &"Failed to load TGA from IoStream"
proc load_tif*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadTIF_IO stream
    sdl_assert result, &"Failed to load TIFF from IoStream"
proc load_xcf*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadXCF_IO stream
    sdl_assert result, &"Failed to load XCF from IoStream"
proc load_xpm*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadXPM_IO stream
    sdl_assert result, &"Failed to load XPM from IoStream"
proc load_xv*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadXV_IO stream
    sdl_assert result, &"Failed to load XV from IoStream"
proc load_webp*(stream: IoStream): ptr SurfaceObj =
    result = IMG_LoadWEBP_IO stream
    sdl_assert result, &"Failed to load WEBP from IoStream"
proc load_svg*(stream: IoStream; w, h: distinct SomeInteger): ptr SurfaceObj =
    result = IMG_LoadSizedSVG_IO(stream, cint w, cint h)
    sdl_assert result, &"Failed to load SVG from stream with size {w}x{h}"
proc xpm_from_array*(xpm: openArray[byte]): ptr SurfaceObj =
    result = IMG_ReadXPMFromArray cast[ptr ptr char](xpm[0].addr)
    sdl_assert result, &"Failed to create xpm image from array (len: {xpm.len})"

proc save_avif*(surface: ptr SurfaceObj; file: string; quality: range[0..100]): bool =
    result = IMG_SaveAVIF(surface, cstring file, cint quality)
    sdl_assert result, &"Failed to save surface as AVIF to '{file}' (quality: {quality})"
proc save_avif*(surface: ptr SurfaceObj; stream: IoStream; quality: range[0..100]; close_io = false): bool =
    result = IMG_SaveAVIF_IO(surface, stream, close_io, cint quality)
    sdl_assert result, &"Failed to save surface as AVIF to stream (quality: {quality})"

proc save_png*(surface: ptr SurfaceObj; file: string): bool =
    result = IMG_SavePNG(surface, cstring file)
    sdl_assert result, &"Failed to save surface as PNG to '{file}'"
proc save_png*(surface: ptr SurfaceObj; stream: IoStream; close_io = false): bool =
    result = IMG_SavePNG_IO(surface, stream, close_io)
    sdl_assert result, &"Failed to save surface as PNG to stream"

proc save_jpg*(surface: ptr SurfaceObj; file: string; quality: range[0..100]): bool =
    result = IMG_SaveJPG(surface, cstring file, cint quality)
    sdl_assert result, &"Failed to save surface as JPG to '{file}' (quality: {quality})"
proc save_jpg*(surface: ptr SurfaceObj; stream: IoStream; quality: range[0..100]; close_io = false): bool =
    result = IMG_SaveJPG_IO(surface, stream, close_io, cint quality)
    sdl_assert result, &"Failed to save surface as JPG to stream (quality: {quality})"

proc load_animation*(file: string): ptr Animation =
    result = IMG_LoadAnimation cstring file
    sdl_assert result != nil, &"Failed to load animation from file '{file}'"

proc load_animation*(stream: IoStream; ext = ""; close_io = false): ptr Animation =
    if ext.len > 0:
        result = IMG_LoadAnimationTyped_IO(stream, close_io, cstring ext)
    else:
        result = IMG_LoadAnimation_IO(stream, close_io)
    sdl_assert result != nil, &"Failed to load animation from stream"

proc load_gif_animation*(stream: IoStream): ptr Animation =
    result = IMG_LoadGIFAnimation_IO stream
    sdl_assert result != nil, &"Failed to load GIF animation from stream"

proc load_webp_animation*(stream: IoStream): ptr Animation =
    result = IMG_LoadWEBPAnimation_IO stream
    sdl_assert result != nil, &"Failed to load WEBP animation from stream"

proc free*(anim: ptr Animation) =
    IMG_FreeAnimation anim

{.pop.}

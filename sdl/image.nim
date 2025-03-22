import common, iostream, surface, renderer

type Animation* = object
    w*, h* : int32
    cnt*   : int32
    frames*: ptr UncheckedArray[ptr Surface]
    delays*: ptr UncheckedArray[int32]

{.push importc, dynlib: SdlImageLib.}
proc IMG_Version(): cint
proc IMG_LoadTyped_IO(src: IoStream; close_io: bool; `type`: cstring): ptr SurfaceObj
proc IMG_Load(file: cstring): ptr SurfaceObj
proc IMG_Load_IO(src: IoStream; close_io: bool): ptr SurfaceObj
proc IMG_LoadTexture(ren: Renderer; file: cstring): Texture
proc IMG_LoadTexture_IO(ren: Renderer; src: IoStream; close_io: bool): Texture
proc IMG_LoadTextureTyped_IO(ren: Renderer; src: IoStream; close_io: bool; `type`: cstring): Texture
proc IMG_isAVIF(src: IoStream): bool
proc IMG_isICO(src: IoStream): bool
proc IMG_isCUR(src: IoStream): bool
proc IMG_isBMP(src: IoStream): bool
proc IMG_isGIF(src: IoStream): bool
proc IMG_isJPG(src: IoStream): bool
proc IMG_isJXL(src: IoStream): bool
proc IMG_isLBM(src: IoStream): bool
proc IMG_isPCX(src: IoStream): bool
proc IMG_isPNG(src: IoStream): bool
proc IMG_isPNM(src: IoStream): bool
proc IMG_isSVG(src: IoStream): bool
proc IMG_isQOI(src: IoStream): bool
proc IMG_isTIF(src: IoStream): bool
proc IMG_isXCF(src: IoStream): bool
proc IMG_isXPM(src: IoStream): bool
proc IMG_isXV(src: IoStream): bool
proc IMG_isWEBP(src: IoStream): bool
proc IMG_LoadAVIF_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadICO_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadCUR_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadBMP_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadGIF_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadJPG_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadJXL_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadLBM_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadPCX_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadPNG_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadPNM_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadSVG_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadQOI_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadTGA_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadTIF_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadXCF_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadXPM_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadXV_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadWEBP_IO(src: IoStream): ptr SurfaceObj
proc IMG_LoadSizedSVG_IO(src: IoStream; w, h: cint): ptr SurfaceObj
proc IMG_ReadXPMFromArray(xpm: ptr ptr char): ptr SurfaceObj
proc IMG_ReadXPMFromArrayToRGB888(xpm: ptr ptr char): ptr SurfaceObj

proc IMG_SaveAVIF(surface: ptr SurfaceObj; file: cstring; quality: cint): bool
proc IMG_SaveAVIF_IO(surface: ptr SurfaceObj; dst: IoStream; close_io: bool; quality: cint): bool
proc IMG_SavePNG(surface: ptr SurfaceObj; file: cstring): bool
proc IMG_SavePNG_IO(surface: ptr SurfaceObj; dst: IoStream; close_io: bool): bool
proc IMG_SaveJPG(surface: ptr SurfaceObj; file: cstring; quality: cint): bool
proc IMG_SaveJPG_IO(surface: ptr SurfaceObj; dst: IoStream; close_io: bool; quality: cint): bool

proc IMG_LoadAnimation(file: cstring): ptr Animation
proc IMG_LoadAnimation_IO(src: IoStream; close_io: bool): ptr Animation
proc IMG_LoadAnimationTyped_IO(src: IoStream; close_io: bool; `type`: cstring): ptr Animation
proc IMG_FreeAnimation(anim: ptr Animation)
proc IMG_LoadGIFAnimation_IO(src: IoStream): ptr Animation
proc IMG_LoadWEBPAnimation_IO(src: IoStream): ptr Animation
{.pop.}

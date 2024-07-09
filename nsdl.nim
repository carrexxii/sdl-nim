import nsdl/[common, init]
from nsdl/ttf import init

proc init*(flags: uint32): cint {.importc: "SDL_Init", dynlib: SDLLib.}
proc init*(flags: InitFlag; should_init_ttf = false) =
    check_err "Failed to initialize SDL":
        init(uint32 flags)

    if should_init_ttf:
        check_err "Failed to initalize SDL_ttf":
            ttf.init()

type Version* = distinct cint
func version*(major, minor, patch: int): Version =
    Version (1000*(1000_000*major + minor) + patch)
func major*(v: Version): int =  (int v) div 1000_000
func minor*(v: Version): int = ((int v) div 1000) mod 1000
func micro*(v: Version): int =  (int v) mod 1000
func `$`*(v: Version): string =
    &"{v.major}.{v.minor}.{v.micro}"

proc sdl_version*(): Version                              {.importc: "SDL_GetVersion"        , dynlib: SDLLib   .}
proc ttf_version*(): Version                              {.importc: "TTF_Version"           , dynlib: SDLTTFLib.}
proc get_freetype_version*(major, minor, patch: ptr cint) {.importc: "TTF_GetFreeTypeVersion", dynlib: SDLTTFLib.}
proc get_harfbuzz_version*(major, minor, patch: ptr cint) {.importc: "TTF_GetHarfBuzzVersion", dynlib: SDLTTFLib.}

proc freetype_version*(): Version =
    var major, minor, patch: cint
    get_freetype_version(major.addr, minor.addr, patch.addr)
    version(major, minor, patch)

proc harfbuzz_version*(): Version =
    var major, minor, patch: cint
    get_harfbuzz_version(major.addr, minor.addr, patch.addr)
    version(major, minor, patch)

import nsdl/events, nsdl/rect, nsdl/pixels, nsdl/properties, nsdl/surface, nsdl/video, nsdl/renderer, nsdl/opengl
export      events,      rect,      pixels,      properties,      surface,      video,      renderer,      opengl
export init


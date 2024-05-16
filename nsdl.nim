import nsdl/common
from nsdl/ttf import init

proc init*(flags: uint32): cint {.importc: "SDL_Init", dynlib: SDLPath.}
proc init*(flags: InitFlag; should_init_ttf = false) =
    check_err "Failed to initialize SDL":
        init(uint32 flags)

    if should_init_ttf:
        check_err "Failed to initalize SDL_ttf":
            ttf.init()

proc get_version*(version: ptr Version) {.importc: "SDL_GetVersion", dynlib: SDLPath.}
proc get_version*(): Version = get_version result.addr

import nsdl/events, nsdl/rect, nsdl/pixels, nsdl/properties, nsdl/surface, nsdl/video, nsdl/renderer, ttf
export      events,      rect,      pixels,      properties,      surface,      video,      renderer, ttf
# exports from common
export SDLError, InitFlag, Version, get_error, `or`

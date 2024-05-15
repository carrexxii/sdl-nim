import nsdl/common
from nsdl/ttf import init

proc init*(flags: uint32): cint {.importc: "SDL_Init", dynlib: SDLPath.}
proc init*(flags: InitFlag; should_init_ttf = false): bool =
    result = true
    if init(uint32 flags) != 0:
        echo red fmt"Error: failed to initialize SDL: {get_error()}"
        result = false

    if should_init_ttf:
        if ttf.init() != 0:
            echo red fmt"Error: failed to initialize SDL_ttf: {get_error()}"

proc get_version*(version: ptr Version) {.importc: "SDL_GetVersion", dynlib: SDLPath.}
proc get_version*(): Version = get_version result.addr

import nsdl/events, nsdl/rect, nsdl/pixels, nsdl/properties, nsdl/surface, nsdl/video, nsdl/renderer, ttf
export      events,      rect,      pixels,      properties,      surface,      video,      renderer, ttf
# exports from common
export get_error, InitFlag, Version, `or`

import common, bitgen
from std/strformat import `&`
from ttf import init

type InitFlag* = distinct uint32
InitFlag.gen_bit_ops(
    initTimer, _, _, _,
    initAudio, initVideo, _, _,
    _, initJoystick, _, _,
    initHaptic, initGamepad, initEvents, initSensor,
    initCamera
)

proc init*(flags: uint32): bool {.importc: "SDL_Init", dynlib: SDLLib.}
proc init*(flags: InitFlag): bool =
    init uint32 flags

type Version* = distinct cint
func version*(major, minor, patch: int): Version =
    Version (1000*(1000_000*major + minor) + patch)
func major*(v: Version): int =  (int v) div 1000_000
func minor*(v: Version): int = ((int v) div 1000) mod 1000
func micro*(v: Version): int =  (int v) mod 1000
func `$`*(v: Version): string =
    &"{v.major}.{v.minor}.{v.micro}"

proc sdl_version*(): Version                              {.importc: "SDL_GetVersion"        , dynlib: SdlLib   .}
proc ttf_version*(): Version                              {.importc: "TTF_Version"           , dynlib: SdlTtfLib.}
proc get_freetype_version*(major, minor, patch: ptr cint) {.importc: "TTF_GetFreeTypeVersion", dynlib: SdlTtfLib.}
proc get_harfbuzz_version*(major, minor, patch: ptr cint) {.importc: "TTF_GetHarfBuzzVersion", dynlib: SdlTtfLib.}

proc freetype_version*(): Version =
    var major, minor, patch: cint
    get_freetype_version major.addr, minor.addr, patch.addr
    version major, minor, patch

proc harfbuzz_version*(): Version =
    var major, minor, patch: cint
    get_harfbuzz_version major.addr, minor.addr, patch.addr
    version major, minor, patch

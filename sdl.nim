import src/common

type Version* = object
    major*: byte
    minor*: byte
    patch*: byte
func `$`*(version: Version): string =
    fmt"{version.major}.{version.minor}.{version.patch}"

type InitFlag* = distinct uint32
func `or`*(a, b: InitFlag): InitFlag {.borrow.}
const
    ifTimer*    = InitFlag 0x0000_0001
    ifAudio*    = InitFlag 0x0000_0010
    ifVideo*    = InitFlag 0x0000_0020
    ifJoystick* = InitFlag 0x0000_0200
    ifHaptic*   = InitFlag 0x0000_1000
    ifGamepad*  = InitFlag 0x0000_2000
    ifEvents*   = InitFlag 0x0000_4000
    ifSensor*   = InitFlag 0x0000_8000
    ifCamera*   = InitFlag 0x0001_0000

proc init(flags: uint32): int32 {.importc: "SDL_Init", dynlib: SDLPath.}
proc init*(flags: InitFlag) =
    if init(uint32 flags) != 0:
        echo red fmt"Error: failed to initialize SDL (SDL_Init): {get_error()}"

proc get_version(version: ptr[Version]) {.importc: "SDL_GetVersion", dynlib: SDLPath.}
proc get_version*(): Version =
    get_version(addr result)

import src/events, src/properties, src/video
export     events,     properties,     video

import src/common

type Version* = object
    major*: byte
    minor*: byte
    patch*: byte
func `$`*(version: Version): string =
    fmt"{version.major}.{version.minor}.{version.patch}"

type InitFlag* {.size: sizeof(uint32).} = enum
    Timer    = 0x0000_0001
    Audio    = 0x0000_0010
    Video    = 0x0000_0020
    Joystick = 0x0000_0200
    Haptic   = 0x0000_1000
    Gamepad  = 0x0000_2000
    Events   = 0x0000_4000
    Sensor   = 0x0000_8000
    Camera   = 0x0001_0000
func `or`*(a, b: InitFlag): InitFlag =
    InitFlag (a.ord or b.ord)

proc init(flags: uint32): int32 {.importc: "SDL_Init", dynlib: SDLPath.}
proc init*(flags: InitFlag) =
    if init(uint32 flags) != 0:
        echo red fmt"Error: failed to initialize SDL (SDL_Init): {get_error()}"

proc get_version(version: ptr Version) {.importc: "SDL_GetVersion", dynlib: SDLPath.}
proc get_version*(): Version =
    get_version result.addr

import src/events, src/pixels, src/properties, src/video, src/renderer
export     events,     pixels,     properties,     video,     renderer

import src/common
export get_error

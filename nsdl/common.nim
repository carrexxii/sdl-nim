import std/[strformat, options]
export strformat, options

const
    SDLDir* {.strdefine.} =  "."
    SDLPath* = fmt"{SDLDir}/lib/libSDL3.so"
    TTFPath* = fmt"{SDLDir}/lib/libSDL3_ttf.so"

type Version* = object
    major*: byte
    minor*: byte
    patch*: byte

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

proc get_error*(): cstring {.importc: "SDL_GetError", dynlib: SDLPath.}

#[ -------------------------------------------------------------------- ]#

type SDLError* = object of CatchableError

template check_ptr*[T](msg: string, body: pointer): T =
    let p = body
    if p == nil:
        raise new_exception(SDLError, "Error: " & msg & " (" & $get_error() & ")")
    cast[T](p)

# When the return value is only the error value
template check_err*(msg, body) =
    if body != 0:
        raise new_exception(SDLError, "Error: " & msg & " (" & $get_error() & ")")

# When the return value is also the value needed (properties.nim)
template check_err*(err_val, msg, body) =
    let res = body
    if res == err_val:
        raise new_exception(SDLError, "Error: " & msg & " (" & $get_error() & ")")
    return res

proc red*    (s: string): string = "\e[31m" & s & "\e[0m"
proc green*  (s: string): string = "\e[32m" & s & "\e[0m"
proc yellow* (s: string): string = "\e[33m" & s & "\e[0m"
proc blue*   (s: string): string = "\e[34m" & s & "\e[0m"
proc magenta*(s: string): string = "\e[35m" & s & "\e[0m"
proc cyan*   (s: string): string = "\e[36m" & s & "\e[0m"

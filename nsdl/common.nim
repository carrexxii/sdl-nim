import std/[sugar, options]
from std/os        import `/`, parent_dir
from std/strformat import `&`
export sugar, options, `&`, `/`

const CWD = current_source_path.parent_dir()
const SDLLib*    = CWD / "../lib/libSDL3.so"
const SDLTTFLib* = CWD / "../lib/libSDL3_ttf.so"

proc get_error*(): cstring {.importc: "SDL_GetError", dynlib: SDLLib.}

#[ -------------------------------------------------------------------- ]#

type SDLError* = object of CatchableError

template check_ptr*[T](msg: string; body: pointer): T =
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

proc red*    (s: string): string = &"\e[31m{s}\e[0m"
proc green*  (s: string): string = &"\e[32m{s}\e[0m"
proc yellow* (s: string): string = &"\e[33m{s}\e[0m"
proc blue*   (s: string): string = &"\e[34m{s}\e[0m"
proc magenta*(s: string): string = &"\e[35m{s}\e[0m"
proc cyan*   (s: string): string = &"\e[36m{s}\e[0m"


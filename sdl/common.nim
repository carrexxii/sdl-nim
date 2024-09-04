from std/os import `/`, parent_dir

const Cwd = current_source_path.parent_dir()
const SdlLib*    = Cwd / "../lib/libSDL3.so"
const SdlTtfLib* = Cwd / "../lib/libSDL3_ttf.so"

type SdlBool* {.importc: "bool".} = object

proc get_error*(): cstring {.importc: "SDL_GetError", dynlib: SDLLib.}
proc cfree*(p: pointer)    {.importc: "free".}

converter `SdlBool -> bool`*(b: SdlBool): bool = 0 != cast[cint](b)
converter `bool -> SdlBool`*(b: bool): SdlBool = {.emit: "(SDL_bool)b".}

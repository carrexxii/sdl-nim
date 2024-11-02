from std/os import `/`, parent_dir

const Cwd = current_source_path.parent_dir()
const SdlLib*    = Cwd / "../lib/libSDL3.so"
const SdlTtfLib* = Cwd / "../lib/libSDL3_ttf.so"

type
    cbool* {.importc: "bool".} = object

    OpaquePointer* = object
        _: pointer

    FunctionPointer* = proc() {.cdecl.}

    Version* = distinct cint

proc get_error*(): cstring {.importc: "SDL_GetError", dynlib: SdlLib.}
proc cfree*(p: pointer)    {.importc: "free"                        .}

converter `OpaquePointer -> pointer`*(p: OpaquePointer): pointer = cast[pointer](p)

converter `cbool -> bool`*(b: cbool): bool = 0 != cast[cint](b)
converter `bool -> cbool`*(b: bool): cbool = {.emit: "(bool)b".}

from std/os import `/`, parent_dir

const
    Cwd = current_source_path.parent_dir()
    SdlLib*            = Cwd / "../lib/libSDL3.so"
    SdlTtfLib*         = Cwd / "../lib/libSDL3_ttf.so"
    SdlShadercrossLib* = Cwd / "../lib/libSDL3Shadercross.so"

type
    FunctionPointer* = proc() {.cdecl.}

    Version* = distinct cint

proc get_error*(): cstring {.importc: "SDL_GetError", dynlib: SdlLib.}
proc cfree*(p: pointer)    {.importc: "free"                        .}

# converter `OpaquePointer -> pointer`*(p: OpaquePointer): pointer = cast[pointer](p)
# func `$`*(p: OpaquePointer): string = $cast[uint](p)

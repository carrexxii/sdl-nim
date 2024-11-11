from std/os        import `/`, parent_dir
from std/strformat import `&`
export `&`

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

proc sdl_assert*(cond: bool; msg: string) {.inline.} =
    when not defined SdlNoGpuAssert:
        assert cond, msg & &": '{get_error()}'"

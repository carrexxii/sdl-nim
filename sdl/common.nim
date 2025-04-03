from std/os        import `/`, parent_dir
from std/strformat import `&`
export `&`

const
    Cwd = current_source_path.parent_dir()
    SdlLib*            = Cwd / "../lib/libSDL3.so"
    SdlTtfLib*         = Cwd / "../lib/libSDL3_ttf.so"
    SdlImageLib*       = Cwd / "../lib/libSDL3_image.so"
    SdlShadercrossLib* = Cwd / "../lib/libSDL3Shadercross.so"

type
    FunctionPointer* = proc() {.cdecl.}

    Version* = distinct cint

proc get_error*(): cstring {.importc: "SDL_GetError", dynlib: SdlLib.}
proc sdl_free*(p: pointer) {.importc: "SDL_free"    , dynlib: SdlLib.}

proc sdl_assert*(cond: bool; msg: string) {.inline.} =
    when not defined SdlNoAssert:
        assert cond, &"{msg}: '{get_error()}'"

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
    Time*    = distinct int64

{.push cdecl, dynlib: SdlLib.}
proc get_error*(): cstring     {.importc: "SDL_GetError"         .}
proc sdl_free*(p: pointer)     {.importc: "SDL_free"             .}
proc allocation_count*(): cint {.importc: "SDL_GetNumAllocations".}
{.pop.}

proc sdl_assert*(cond: bool; msg: string) {.inline.} =
    when not defined SdlNoAssert:
        assert cond, &"{msg}: '{get_error()}'"

#[ -------------------------------------------------------------------- ]#
# SDL_guid.h

type Guid* = object
    data: array[16, byte]

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_GUIDToString*(guid: Guid; pszGUID: cstring; cbGUID: cint)
proc SDL_StringToGUID*(pchGUID: cstring): Guid
{.pop.}

proc `$`*(guid: Guid): string =
    result = new_string(40)
    SDL_GUIDToString(guid, result[0].addr, cint result.len)

proc to_guid*(guid: string): Guid =
    SDL_StringToGUID cstring guid

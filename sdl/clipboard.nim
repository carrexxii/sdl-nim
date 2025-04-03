import common

# TODO: Utility subroutines for ClipboardXXX types (iterators, conversions, etc)

type
    ClipboardDataCallback*    = proc(user_data: pointer; mime_type: cstring; sz: ptr csize_t): pointer {.cdecl.}
    ClipboardCleanupCallback* = proc(user_data: pointer) {.cdecl.}

    ClipboardData* = object
        data*: pointer
        len* : uint

    ClipboardString* = object
        data*: cstring

    ClipboardStringArray* = object
        data*: cstringArray
        len* : uint

proc `=destroy`*(data: ClipboardData)        = sdl_free data.data
proc `=destroy`*(str : ClipboardString)      = sdl_free str.data
proc `=destroy`*(strs: ClipboardStringArray) = sdl_free strs.data

proc `$`*(str: ClipboardString): string = $str.data

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_SetClipboardText*(text: cstring): bool
proc SDL_GetClipboardText*(): cstring
proc SDL_HasClipboardText*(): bool
proc SDL_SetPrimarySelectionText*(text: cstring): bool
proc SDL_GetPrimarySelectionText*(): cstring
proc SDL_HasPrimarySelectionText*(): bool
proc SDL_SetClipboardData*(cb: ClipboardDataCallback; cleanup: ClipboardCleanupCallback; user_data: pointer; mime_types: cstringArray; num_mime_types: csize_t): bool
proc SDL_ClearClipboardData*(): bool
proc SDL_GetClipboardData*(mime_type: cstring; sz: ptr csize_t): pointer
proc SDL_HasClipboardData*(mime_type: cstring): bool
proc SDL_GetClipboardMimeTypes*(num_mime_types: ptr csize_t): cstringArray
{.pop.}

{.push inline.}

proc set_clipboard_text*(text: string): bool {.discardable.} =
    let success = SDL_SetClipboardText(cstring text)
    sdl_assert success, &"Failed to set clipboard text to '{text}'"

proc clipboard_text*(): ClipboardString =
    result.data = SDL_GetClipboardText()
    sdl_assert result.data != nil, "Failed to get clipboard text"

proc clipboard_has_text*(): bool =
    SDL_HasClipboardText()

proc set_primary_selection*(text: string): bool {.discardable.} =
    result = SDL_SetPrimarySelectionText(cstring text)
    sdl_assert result, &"Failed to set clipboard primary selection text to '{text}'"

proc primary_selection_text*(): ClipboardString =
    result.data = SDL_GetPrimarySelectionText()
    sdl_assert result.data != nil, "Failed to get clipboard primary selection text"

proc have_primary_selection_text*(): bool =
    SDL_HasPrimarySelectionText()

proc set_clipboard_data*(cb: ClipboardDataCallback; cleanup: ClipboardCleanupCallback; mime_types: openArray[string];
                         user_data: pointer = nil;
                         ): bool {.discardable.} =
    ## A `cstringArray` is allocated and deallocated for more than one mime type
    assert mime_types.len > 0, "Need at least one mime type for clipboard data"
    if mime_types.len == 1:
        result = SDL_SetClipboardData(cb, cleanup, user_data, cast[cstringArray](cstring mime_types[0]), csize_t mime_types.len)
    elif mime_types.len > 1:
        let cmime_types = alloc_cstring_array(mime_types)
        result = SDL_SetClipboardData(cb, cleanup, user_data, cmime_types, csize_t mime_types.len)
        dealloc_cstring_array cmime_types
    sdl_assert result, &"Failed to set clipboard data (mime types: {mime_types})"

proc clear_clipboard*(): bool {.discardable.} =
    result = SDL_ClearClipboardData()
    sdl_assert result, "Failed to clear clipboard data"

proc clipboard_data*(mime_type: string): ClipboardData =
    result.data = SDL_GetClipboardData(cstring mime_type, result.len.addr)
    sdl_assert result.data != nil, &"Failed to get clipboard data (mime type: {mime_type})"

proc clipboard_has_data*(mime_type: string): bool =
    SDL_HasClipboardData cstring mime_type

proc clipboard_mime_types*(): ClipboardStringArray =
    result.data = SDL_GetClipboardMimeTypes(result.len.addr)
    sdl_assert result.data != nil, "Failed to get clipboard mime types"

{.pop.}

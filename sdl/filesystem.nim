import std/options, common

type
    FolderKind* {.size: sizeof(cint).} = enum
        Home
        Desktop
        Documents
        Downloads
        Music
        Pictures
        PublicShare
        SavedGames
        Screenshots
        Templates
        Videos

    PathKind* {.size: sizeof(cint).} = enum
        None
        File
        Directory
        Other

    EnumerationResult* {.size: sizeof(cint).} = enum
        Continue
        Success
        Failure

type
    GlobFlag* = distinct uint32

    PathInfo* = object
        kind*       : PathKind
        sz*         : uint64
        create_time*: Time
        modify_time*: Time
        access_time*: Time

    EnumerateDirectoryCallback* = proc(user_data: pointer; dir_name, file_name: cstring): EnumerationResult {.cdecl.}

const
    GlobNone*          = GlobFlag 0
    GlobCaseSensitive* = GlobFlag (1 shl 0)

func `or`*(a, b: GlobFlag): GlobFlag {.borrow.}

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_GetBasePath*(): cstring
proc SDL_GetPrefPath*(org, app: cstring): cstring
proc SDL_GetUserFolder*(kind: FolderKind): cstring
proc SDL_CreateDirectory*(path: cstring): bool
proc SDL_EnumerateDirectory*(path: cstring; cb: EnumerateDirectoryCallback; user_data: pointer): bool
proc SDL_RemovePath*(path: cstring): bool
proc SDL_RenamePath*(old_path, new_path: cstring): bool
proc SDL_CopyFile*(old_path, new_path: cstring): bool
proc SDL_GetPathInfo*(path: cstring; info: ptr PathInfo): bool
proc SDL_GlobDirectory*(path, pattern: cstring; flags: GlobFlag; cnt: ptr cint): cstringArray
proc SDL_GetCurrentDirectory*(): cstring
{.pop.}

proc base_path*(): string =
    let path = SDL_GetBasePath()
    sdl_assert path != nil, "Failed to get filesystem base path"
    if path != nil:
        result = $path

proc pref_path*(org, app: string): string =
    let path = SDL_GetPrefPath(cstring org, cstring app)
    sdl_assert path != nil, &"Failed to get pref path for org name '{org}' and app name '{app}'"
    if path != nil:
        result = $path
        sdl_free path

proc user_folder*(kind: FolderKind): string =
    let path = SDL_GetUserFolder(kind)
    sdl_assert path != nil, &"Failed to get user folder for folder of kind '{kind}'"
    if path != nil:
        result = $path

proc create_directory*(path: string): bool {.discardable.} =
    result = SDL_CreateDirectory(cstring path)
    sdl_assert result, &"Failed to create directory with path '{path}'"

proc enumerate_directory*(cb: EnumerateDirectoryCallback; path: string; user_data: pointer = nil): bool {.discardable.} =
    result = SDL_EnumerateDirectory(cstring path, cb, user_data)
    sdl_assert result, &"Failed to enumerate directory for path '{path}'"

proc remove_path*(path: string): bool {.discardable.} =
    result = SDL_RemovePath(cstring path)
    sdl_assert result, &"Failed to remove path '{path}'"

proc rename_path*(old_path, new_path: string): bool {.discardable.} =
    result = SDL_RenamePath(cstring old_path, cstring new_path)
    sdl_assert result, &"Failed to rename path '{old_path}' to '{new_path}'"

proc copy_path*(old_path, new_path: string): bool {.discardable.} =
    result = SDL_CopyFile(cstring old_path, cstring new_path)
    sdl_assert result, &"Failed to copy path '{old_path}' to '{new_path}'"

proc path_info*(path: string): PathInfo =
    let success = SDL_GetPathInfo(cstring path, result.addr)
    sdl_assert success, &"Failed to get path info for '{path}'"

proc glob_directory*(path: string; pattern: Option[string]; flags: GlobFlag = GlobNone): seq[string] =
    var cnt: cint
    let pattern = if pattern.is_some: cstring get pattern else: nil
    let paths   = SDL_GlobDirectory(cstring path, pattern, flags, cnt.addr)
    if cnt > 0:
        result = new_seq_of_cap[string](cnt)
        for i in 0..<cnt:
            result.add $paths[i]
        sdl_free paths

proc current_directory*(): string =
    let path = SDL_GetCurrentDirectory()
    sdl_assert path != nil, "Failed to get current directory"
    $path

import common
from std/sequtils import map_it
from video import Window

type
    DialogFileFilter* = object
        name*   : cstring
        pattern*: cstring

    DialogFileCallback* = proc(user_data: pointer; file_lst: ptr cstring; filter: cint) {.cdecl.}

type
    DialogKind = enum
        dkOpenFile
        dkSaveFile
        dkOpenFolder

    CallbackKind = enum
        ckOne
        ckMulti
    Callback = object
        case kind: CallbackKind
        of ckOne  : single_cb: proc(path: string)
        of ckMulti: multi_cb : proc(paths: seq[string])

using
    cb         : DialogFileCallback
    user_data  : pointer
    filters    : ptr DialogFileFilter
    win        : Window
    default_loc: cstring
    filter_cnt : cint

{.push dynlib: SdlLib.}
proc sdl_show_open_file_dialog*(cb; user_data; win; filters; filter_cnt; default_loc; allow_many: bool) {.importc: "SDL_ShowOpenFileDialog"  .}
proc sdl_show_save_file_dialog*(cb; user_data; win; filters; filter_cnt; default_loc)                   {.importc: "SDL_ShowSaveFileDialog"  .}
proc sdl_show_open_folder_dialog*(cb; user_data; win; default_loc; allow_many: bool)                    {.importc: "SDL_ShowOpenFolderDialog".}
{.pop.}

#[ -------------------------------------------------------------------- ]#

var return_cb: Callback
proc callback(user_data: pointer; file_lst: ptr cstring; filter: cint) {.cdecl.} =
    if return_cb.kind == ckOne:
        let path = if file_lst == nil: "" else: $file_lst[]
        return_cb.single_cb path
    else:
        var paths: seq[string] = @[]
        if file_lst != nil:
            let file_lst = cast[ptr UncheckedArray[cstring]](file_lst)
            var i    = 0
            var file = file_lst[][i]
            while file != nil:
                paths.add $file
                inc i
                file = file_lst[][i]
            
        return_cb.multi_cb paths

proc dialog_inner*(kind: DialogKind; win: Window; default_loc: string; filters: openArray[tuple[name, pattern: string]]) =
    let default_loc = if default_loc.len == 0: nil else: cstring default_loc
    let filters     = filters.map_it DialogFileFilter(name: it.name, pattern: it.pattern)
    let filter_ptr  = if filters.len > 0: filters[0].addr else: nil
    case kind
    of dkOpenFile  : sdl_show_open_file_dialog   callback, nil, win, filter_ptr, cint filters.len, default_loc, return_cb.kind == ckMulti
    of dkSaveFile  : sdl_show_save_file_dialog   callback, nil, win, filter_ptr, cint filters.len, default_loc
    of dkOpenFolder: sdl_show_open_folder_dialog callback, nil, win, default_loc, false

proc open_file_dialog*(cb: proc(path: string);
                       win        : Window = cast[Window](nil);
                       default_loc: string = "";
                       filters    : openArray[tuple[name, pattern: string]] = [];
                       ) =
    return_cb = Callback(kind: ckOne, single_cb: cb)
    dkOpenFile.dialog_inner win, default_loc, filters

proc open_file_dialog*(cb: proc(paths: seq[string]);
                       win        : Window = cast[Window](nil);
                       default_loc: string = "";
                       filters    : openArray[tuple[name, pattern: string]] = [];
                       ) =
    return_cb = Callback(kind: ckMulti, multi_cb: cb)
    dkOpenFile.dialog_inner win, default_loc, filters

proc save_file_dialog*(cb: proc(path: string);
                       win: Window = cast[Window](nil);
                       default_loc: string = "";
                       filters    : openArray[tuple[name, pattern: string]] = [];
                       ) =
    return_cb = Callback(kind: ckOne, single_cb: cb)
    dkSaveFile.dialog_inner win, default_loc, filters

proc open_folder_dialog*(cb: proc(path: string);
                       win: Window = cast[Window](nil);
                       default_loc: string = "";
                       filters    : openArray[tuple[name, pattern: string]] = [];
                       ) =
    return_cb = Callback(kind: ckOne, single_cb: cb)
    dkSaveFile.dialog_inner win, default_loc, filters

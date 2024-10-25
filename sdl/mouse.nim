type
    SystemCursor* {.size: sizeof(cint).} = enum
        cursorDefault
        cursorText
        cursorWait
        cursorCrosshair
        cursorProgress
        cursorNwseResize
        cursorNeswResize
        cursorEwResize
        cursorNsResize
        cursorMove
        cursorNotAllowed
        cursorPointer
        cursorNwResize
        cursorNResize
        cursorNeResize
        cursorEResize
        cursorSeResize
        cursorSResize
        cursorSwResize
        cursorWResize

    MouseWheelDirection* {.size: sizeof(cint).} = enum
        mwdNormal
        mwdFlipped

    MouseButton* {.size: sizeof(cint).} = enum
        mbLeft   = 1
        mbMiddle = 2
        mbRight  = 3
        mbX1     = 4
        mbX2     = 5

    # FIXME
    # Hard-coded unlike the SDL version which calculates it based off of MouseButton values
    # assigning values to the enum seems to break the bitset
    MouseButtonFlag* {.size: sizeof(uint32).} = enum
        btnLeft
        btnMiddle
        btnRight
        btnX1
        btnX2
    MouseButtonMask* = set[MouseButtonFlag]

type
    MouseId* = distinct uint32
    Cursor* = object
        _: pointer

#[ -------------------------------------------------------------------- ]#

using win: Window

{.push dynlib: SdlLib.}
proc sdl_has_mouse*(): cbool                                                                     {.importc: "SDL_HasMouse"                  .}
proc sdl_get_mice*(count: ptr cint): ptr UncheckedArray[MouseId]                                 {.importc: "SDL_GetMice"                   .}
proc sdl_get_mouse_name_for_id*(id: MouseId): cstring                                            {.importc: "SDL_GetMouseNameForID"         .}
proc sdl_get_mouse_focus*(): Window                                                              {.importc: "SDL_GetMouseFocus"             .}
proc sdl_get_mouse_state*(x, y: ptr cfloat): MouseButtonMask                                     {.importc: "SDL_GetMouseState"             .}
proc sdl_get_global_mouse_state*(x, y: ptr cfloat): MouseButtonMask                              {.importc: "SDL_GetGlobalMouseState"       .}
proc sdl_get_relative_mouse_state*(x, y: ptr cfloat): MouseButtonMask                            {.importc: "SDL_GetRelativeMouseState"     .}
proc sdl_warp_mouse_in_window*(win; x, y: cfloat)                                                {.importc: "SDL_WarpMouseInWindow"         .}
proc sdl_warp_mouse_global*(x, y: cfloat): cbool                                                 {.importc: "SDL_WarpMouseGlobal"           .}
proc sdl_set_window_relative_mouse_mode*(win; enabled: cbool): cbool                             {.importc: "SDL_SetWindowRelativeMouseMode".}
proc sdl_get_window_relative_mouse_mode*(win): cbool                                             {.importc: "SDL_GetWindowRelativeMouseMode".}
proc sdl_capture_mouse*(enabled: cbool): cbool                                                   {.importc: "SDL_CaptureMouse"              .}
proc sdl_create_cursor*(data, mask: ptr UncheckedArray[uint8]; w, h, hot_x, hot_y: cint): Cursor {.importc: "SDL_CreateCursor"              .}
proc sdl_create_colour_cursor*(surf: Surface; hot_x, hot_y: cint): Cursor                        {.importc: "SDL_CreateColorCursor"         .}
proc sdl_create_system_cursor*(id: SystemCursor): Cursor                                         {.importc: "SDL_CreateSystemCursor"        .}
proc sdl_set_cursor*(cursor: Cursor): cbool                                                      {.importc: "SDL_SetCursor"                 .}
proc sdl_get_cursor*(): Cursor                                                                   {.importc: "SDL_GetCursor"                 .}
proc sdl_get_default_cursor*(): Cursor                                                           {.importc: "SDL_GetDefaultCursor"          .}
proc sdl_destroy_cursor*(cursor: Cursor)                                                         {.importc: "SDL_DestroyCursor"             .}
proc sdl_show_cursor*(): cbool                                                                   {.importc: "SDL_ShowCursor"                .}
proc sdl_hide_cursor*(): cbool                                                                   {.importc: "SDL_HideCursor"                .}
proc sdl_cursor_visible*(): cbool                                                                {.importc: "SDL_CursorVisible"             .}
{.pop.}

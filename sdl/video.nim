import common, bitgen, pixels, rect

type WindowFlag* = distinct uint64
WindowFlag.gen_bit_ops(
    winFullscreen, winOpenGL, winOccluded, winHidden,
    winBorderless, winResizeable, winMinimized, winMaximized,
    winMouseGrabbed, winInputFocus, winMouseFocus, winExternal,
    _, winHighPixelDensity, winMouseCapture, winAlwaysOnTop,
    winSkipTaskbar, winUtility, winTooltip, winPopupMenu,
    winKeyboardGrabbed, _, _, _,
    _, _, _, _,
    winVulkan, winMetal, winTransparent, winNotFocusable,
)
const winNone* = WindowFlag 0

type
    WindowPos* {.size: sizeof(cint).} = enum
        winPosUndefined = 0x1FFF_0000
        winPosCentred   = 0x2FFF_0000

    SystemTheme* {.size: sizeof(cint).} = enum
        themeUnknown
        themeLight
        themeDark

    DisplayOrientation* {.size: sizeof(cint).} = enum
        orientUnknown
        orientLandscape
        orientLandscapeFlipped
        orientPortrait
        orientPortraitFlipped

    FlashOperation* {.size: sizeof(cint).} = enum
        flashCancel
        flashBriefly
        flashUntilFocused

type
    DisplayId*       = distinct uint32
    WindowId*        = distinct uint32
    Window*          = distinct pointer
    IccProfile*      = distinct pointer
    DisplayModeData* = distinct pointer

    DisplayMode* = ptr DisplayModeObj
    DisplayModeObj* = object
        display_id*        : DisplayId
        px_fmt*            : PixelFormat
        w*, h*             : cint
        px_density*        : cfloat
        refresh_rate*      : cfloat
        refresh_rate_numer*: cint
        refresh_rate_denom*: cint
        _                  : pointer

converter `Window -> bool`*(win: Window): bool                    = cast[pointer](win) != nil
converter `IccProfile -> bool`*(icc: IccProfile): bool            = cast[pointer](icc) != nil
converter `DisplayModeData -> bool`*(data: DisplayModeData): bool = cast[pointer](data) != nil
converter `DisplayMode -> bool`*(mode: DisplayMode): bool         = mode != nil
converter `WindowId -> bool`*(win_id: WindowId): bool     = 0 != int win_id
converter `DisplayId -> bool`*(disp_id: DisplayId): bool  = 0 != int disp_id

#[ -------------------------------------------------------------------- ]#

from properties import PropertyId

using
    win    : Window
    display: DisplayID

{.push dynlib: SdlLib.}
proc sdl_create_window*(title: cstring; w, h: cint; flags: WindowFlag): Window             {.importc: "SDL_CreateWindow"     .}
proc sdl_create_popup_window*(parent: Window; x, y, w, h: cint; flags: WindowFlag): Window {.importc: "SDL_CreatePopupWindow".}
proc sdl_destroy_window*(win)                                                              {.importc: "SDL_DestroyWindow"    .}
proc sdl_quit*()                                                                           {.importc: "SDL_Quit"             .}

proc sdl_set_window_position*(win; x, y: cint): bool  {.importc: "SDL_SetWindowPosition".}
proc sdl_set_window_title*(win; title: cstring): bool {.importc: "SDL_SetWindowTitle"   .}

proc sdl_get_num_video_drivers*(): cint                                                                {.importc: "SDL_GetNumVideoDrivers"             .}
proc sdl_get_video_driver*(index: cint): cstring                                                       {.importc: "SDL_GetVideoDriver"                 .}
proc sdl_get_current_video_driver*(): cstring                                                          {.importc: "SDL_GetCurrentVideoDriver"          .}
proc sdl_get_system_theme*(): SystemTheme                                                              {.importc: "SDL_GetSystemTheme"                 .}
proc sdl_get_displays*(count: ptr cint): ptr DisplayId                                                 {.importc: "SDL_GetDisplays"                    .}
proc sdl_get_primary_display*(): DisplayId                                                             {.importc: "SDL_GetPrimaryDisplay"              .}
proc sdl_get_display_properties*(display): PropertyId                                                  {.importc: "SDL_GetDisplayProperties"           .}
proc sdl_get_display_name*(display): cstring                                                           {.importc: "SDL_GetDisplayName"                 .}
proc sdl_get_display_bounds*(display; rect: ptr Rect): bool                                            {.importc: "SDL_GetDisplayBounds"               .}
proc sdl_get_display_usable_bounds*(display; rect: ptr Rect): bool                                     {.importc: "SDL_GetDisplayUsableBounds"         .}
proc sdl_get_natural_display_orientation*(display): DisplayOrientation                                 {.importc: "SDL_GetNaturalDisplayOrientation"   .}
proc sdl_get_current_display_orientation*(display): DisplayOrientation                                 {.importc: "SDL_GetCurrentDisplayOrientation"   .}
proc sdl_get_display_content_scale*(display): cfloat                                                   {.importc: "SDL_GetDisplayContentScale"         .}
proc sdl_get_fullscreen_display_modes*(display; count: ptr cint): ptr UncheckedArray[DisplayMode]      {.importc: "SDL_GetFullscreenDisplayModes"      .}
proc sdl_get_closest_fullscreen_display_mode*(display; w, h: cint; refresh: cfloat; hd: bool): pointer {.importc: "SDL_GetClosestFullscreenDisplayMode".}
proc sdl_get_desktop_display_mode*(display): DisplayMode                                               {.importc: "SDL_GetDesktopDisplayMode"          .}
proc sdl_get_current_display_mode*(display): DisplayMode                                               {.importc: "SDL_GetCurrentDisplayMode"          .}
proc sdl_get_display_for_point*(point: ptr Point): DisplayId                                           {.importc: "SDL_GetDisplayForPoint"             .}
proc sdl_get_display_for_rect*(point: ptr Rect): DisplayId                                             {.importc: "SDL_GetDisplayForRect"              .}
proc sdl_get_display_for_window*(win): DisplayId                                                       {.importc: "SDL_GetDisplayForWindow"            .}
proc sdl_get_window_pixel_density*(win): cfloat                                                        {.importc: "SDL_GetWindowPixelDensity"          .}
proc sdl_get_window_display_scale*(win): cfloat                                                        {.importc: "SDL_GetWindowDisplayScale"          .}
proc sdl_set_window_fullscreen_mode*(win; mode: DisplayMode): bool                                     {.importc: "SDL_SetWindowFullscreenMode"        .}
proc sdl_get_window_fullscreen_mode*(win): DisplayMode                                                 {.importc: "SDL_GetWindowFullscreenMode"        .}
proc sdl_get_window_icc_profile*(win; size: ptr csize_t): pointer                                      {.importc: "SDL_GetWindowICCProfile"            .}
proc sdl_get_window_pixel_format*(win): PixelFormat                                                    {.importc: "SDL_GetWindowPixelFormatKind"           .}
{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}

proc `destroy=`*(win) = sdl_destroy_window win
proc quit*() = sdl_quit()

proc create_window*(title: string; w, h: SomeInteger; flags = winNone): Window =
    result = sdl_create_window(cstring title, cint w, cint h, flags)
    sdl_assert result, "Failed to create window"

proc create_popup*(parent: Window; x, y, w, h: SomeInteger; flags = winNone): Window =
    result = sdl_create_popup_window(parent, cint x, cint y, cint w, cint h, flags)
    sdl_assert result, &"Failed to create popup window"

proc bounds*(display): Rect =
    let success = sdl_get_display_bounds(display, result.addr)
    sdl_assert success, &"Failed to get display bounds"
proc usable_bounds*(display): Rect =
    let success = sdl_get_display_usable_bounds(display, result.addr)
    sdl_assert success, &"Failed to get display usable bounds"

proc `title=`*(win; title: string): bool {.discardable.} =
    result = sdl_set_window_title(win, cstring title)
    sdl_assert result, &"Failed to set window title"

proc fullscreen_modes*(display): seq[DisplayModeObj] =
    var count: cint
    let modes = sdl_get_fullscreen_display_modes(display, count.addr)
    sdl_assert modes != nil, &"Failed to get fullscreen display modes"
    for mode in to_open_array(modes, 0'i32, count - 1):
        result.add mode[]
    SDL_free modes

proc desktop_mode*(display): DisplayMode =
    result = sdl_get_desktop_display_mode display
    sdl_assert result, &"Failed to get display's desktop mode"

proc current_mode*(display): DisplayMode =
    result = sdl_get_current_display_mode display
    sdl_assert result, &"Failed to get current display mode"

proc fullscreen_mode*(win): DisplayMode =
    result = sdl_get_window_fullscreen_mode(win)
    sdl_assert result, &"Failed to get window fullscreen mode"

proc `fullscreen_mode=`*(win; mode: DisplayMode): bool {.discardable.} =
    result = sdl_set_window_fullscreen_mode(win, mode)
    sdl_assert result, &"Failed to set fullscreen mode to {mode}"

proc centre_window*(win): bool {.discardable.} =
    result = sdl_set_window_position(win, winPosCentred.ord, winPosCentred.ord)
    sdl_assert result, &"Failed to centre window"

proc get_display_at*(x, y: SomeInteger): DisplayId =
    let point = point(x, y)
    result = sdl_get_display_for_point point.addr
    sdl_assert result, &"Failed to get display at ({x}, {y})"

proc get_display_at*(x, y, w, h: SomeInteger): DisplayId =
    let rect = rect(x, y, w, h)
    result = sdl_get_display_for_rect rect.addr
    sdl_assert result, &"Failed to get display at {rect}"

proc px_fmt*(win): PixelFormat =
    sdl_get_window_pixel_format win

{.pop.}

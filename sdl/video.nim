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
    WindowPos* {.size: sizeof(int32).} = enum
        winPosUndefined = 0x1FFF_0000
        winPosCentred   = 0x2FFF_0000

    SystemTheme* {.size: sizeof(int32).} = enum
        themeUnknown
        themeLight
        themeDark

    DisplayOrientation* {.size: sizeof(int32).} = enum
        orientUnknown
        orientLandscape
        orientLandscapeFlipped
        orientPortrait
        orientPortraitFlipped

    FlashOperation* {.size: sizeof(int32).} = enum
        flashCancel
        flashBriefly
        flashUntilFocused

type
    DisplayID* = distinct uint32
    WindowID*  = distinct uint32
    Window* = object
        _: pointer
    ICCProfile* = object
        _: pointer

    DisplayMode* = object
        display_id*  : DisplayId
        px_fmt*      : PixelFormat
        w*, h*       : int32
        px_density*  : float32
        refresh_rate*: float32
        driver_data* : pointer

#[ -------------------------------------------------------------------- ]#

from properties import PropertyID
using
    win : Window
    d_id: DisplayID

{.push dynlib: SdlLib.}
proc sdl_create_window*(title: cstring; w, h: cint; flags: WindowFlag): ptr Window                 {.importc: "SDL_CreateWindow"     .}
proc sdl_create_popup_window*(parent: ptr Window; x, y, w, h: cint; flags: WindowFlag): ptr Window {.importc: "SDL_CreatePopupWindow".}
proc sdl_destroy_window*(win)                                                                      {.importc: "SDL_DestroyWindow"    .}
proc sdl_quit*()                                                                                   {.importc: "SDL_Quit"             .}

proc sdl_set_window_position*(win; x, y: cint): cbool  {.importc: "SDL_SetWindowPosition".}
proc sdl_set_window_title*(win; title: cstring): cbool {.importc: "SDL_SetWindowTitle"   .}

proc sdl_get_num_video_drivers*(): cint                                                              {.importc: "SDL_GetNumVideoDrivers"             .}
proc sdl_get_video_driver*(index: cint): cstring                                                     {.importc: "SDL_GetVideoDriver"                 .}
proc sdl_get_current_video_driver*(): cstring                                                        {.importc: "SDL_GetCurrentVideoDriver"          .}
proc sdl_get_system_theme*(): SystemTheme                                                            {.importc: "SDL_GetSystemTheme"                 .}
proc sdl_get_displays*(count: ptr cint): ptr DisplayID                                               {.importc: "SDL_GetDisplays"                    .}
proc sdl_get_primary_display*(): DisplayID                                                           {.importc: "SDL_GetPrimaryDisplay"              .}
proc sdl_get_display_properties*(d_id): PropertyID                                                   {.importc: "SDL_GetDisplayProperties"           .}
proc sdl_get_display_name*(d_id): cstring                                                            {.importc: "SDL_GetDisplayName"                 .}
proc sdl_get_display_bounds*(d_id; rect: ptr Rect): cbool                                            {.importc: "SDL_GetDisplayBounds"               .}
proc sdl_get_display_usable_bounds*(d_id; rect: ptr Rect): cbool                                     {.importc: "SDL_GetDisplayUsableBounds"         .}
proc sdl_get_natural_display_orientation*(d_id): DisplayOrientation                                  {.importc: "SDL_GetNaturalDisplayOrientation"   .}
proc sdl_get_current_display_orientation*(d_id): DisplayOrientation                                  {.importc: "SDL_GetCurrentDisplayOrientation"   .}
proc sdl_get_display_content_scale*(d_id): cfloat                                                    {.importc: "SDL_GetDisplayContentScale"         .}
proc sdl_get_fullscreen_display_modes*(d_id; count: ptr cint): ptr UncheckedArray[ptr DisplayMode]   {.importc: "SDL_GetFullscreenDisplayModes"      .}
proc sdl_get_closest_fullscreen_display_mode*(d_id; w, h: cint; refresh: cfloat; hd: cbool): pointer {.importc: "SDL_GetClosestFullscreenDisplayMode".}
proc sdl_get_desktop_display_mode*(d_id): ptr DisplayMode                                            {.importc: "SDL_GetDesktopDisplayMode"          .}
proc sdl_get_current_display_mode*(d_id): ptr DisplayMode                                            {.importc: "SDL_GetCurrentDisplayMode"          .}
proc sdl_get_display_for_point*(point: ptr Point): DisplayID                                         {.importc: "SDL_GetDisplayForPoint"             .}
proc sdl_get_display_for_rect*(point: ptr Rect): DisplayID                                           {.importc: "SDL_GetDisplayForRect"              .}
proc sdl_get_display_for_window*(win): DisplayID                                                     {.importc: "SDL_GetDisplayForWindow"            .}
proc sdl_get_window_pixel_density*(win): cfloat                                                      {.importc: "SDL_GetWindowPixelDensity"          .}
proc sdl_get_window_display_scale*(win): cfloat                                                      {.importc: "SDL_GetWindowDisplayScale"          .}
proc sdl_set_window_fullscreen_mode*(win; mode: ptr DisplayMode): cbool                              {.importc: "SDL_SetWindowFullscreenMode"        .}
proc sdl_get_window_fullscreen_mode*(win): ptr DisplayMode                                           {.importc: "SDL_GetWindowFullscreenMode"        .}
proc sdl_get_window_icc_profile*(win; size: ptr csize_t): pointer                                    {.importc: "SDL_GetWindowICCProfile"            .}
proc sdl_get_window_pixel_format*(win): PixelFormat                                                  {.importc: "SDL_GetWindowPixelFormatKind"           .}
{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}

proc `destroy=`*(win) = sdl_destroy_window win
proc quit*() = sdl_quit()

proc create_window*(title: string; w, h: int; flags = winNone): ptr Window =
    sdl_create_window cstring title, cint w, cint h, flags

proc create_popup*(parent: ptr Window; x, y, w, h: int; flags = winNone): ptr Window =
    sdl_create_popup_window parent, cint x, cint y, cint w, cint h, flags

proc bounds*(d_id): Rect        = assert not sdl_get_display_bounds(d_id, result.addr)
proc usable_bounds*(d_id): Rect = assert not sdl_get_display_usable_bounds(d_id, result.addr)

proc `title=`*(win; title: string) = assert not sdl_set_window_title(win, cstring title)

proc fullscreen_modes*(d_id): seq[DisplayMode] =
    var count: cint
    let modes = sdl_get_fullscreen_display_modes(d_id, count.addr)
    for mode in to_open_array(modes, 0'i32, count - 1):
        result.add mode[]
    cfree modes

proc desktop_mode*(d_id): DisplayMode =
    let mode = sdl_get_desktop_display_mode(d_id)
    assert mode != nil
    mode[]

proc current_mode*(d_id): DisplayMode =
    let mode = sdl_get_current_display_mode(d_id)
    assert mode != nil
    mode[]

proc fullscreen_mode*(win): DisplayMode =
    let mode = sdl_get_window_fullscreen_mode(win)
    assert mode != nil
    mode[]

proc `fullscreen_mode=`*(win; mode: DisplayMode) =
    assert not sdl_set_window_fullscreen_mode(win, mode.addr)

proc centre_window*(win) =
    assert not sdl_set_window_position(win, winPosCentred.ord, winPosCentred.ord)

proc get_display_at*(x, y: int32): DisplayID =
    let point = Point(x: x, y: y)
    sdl_get_display_for_point point.addr

proc get_display_at*(x, y, w, h: int32): DisplayID =
    let rect = Rect(x: x, y: y, w: w, h: h)
    sdl_get_display_for_rect rect.addr

proc px_fmt*(win): PixelFormat =
    sdl_get_window_pixel_format win

{.pop.} # inline

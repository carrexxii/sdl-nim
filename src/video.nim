import common

type DisplayID*  = distinct uint32
type WindowID*   = distinct uint32

type Window* = pointer
type WindowFlag* = distinct uint64
func `or`*(a, b: WindowFlag): WindowFlag {.borrow.}
const
    wfFullscreen*       = WindowFlag 0x0000_0000_0000_0001
    wfOpenGL*           = WindowFlag 0x0000_0000_0000_0002
    wfOccluded*         = WindowFlag 0x0000_0000_0000_0004
    wfHidden*           = WindowFlag 0x0000_0000_0000_0008
    wfBorderless*       = WindowFlag 0x0000_0000_0000_0010
    wfResizable*        = WindowFlag 0x0000_0000_0000_0020
    wfMinimized*        = WindowFlag 0x0000_0000_0000_0040
    wfMaximized*        = WindowFlag 0x0000_0000_0000_0080
    wfMouseGrabbed*     = WindowFlag 0x0000_0000_0000_0100
    wfinputFocus*       = WindowFlag 0x0000_0000_0000_0200
    wfMouseFocus*       = WindowFlag 0x0000_0000_0000_0400
    wfExternal*         = WindowFlag 0x0000_0000_0000_0800
    wfHighPixelDensity* = WindowFlag 0x0000_0000_0000_2000
    wfMouseCapture*     = WindowFlag 0x0000_0000_0000_4000
    wfAlwaysOnTop*      = WindowFlag 0x0000_0000_0000_8000
    wfSkipTaskbar*      = WindowFlag 0x0000_0000_0001_0000
    wfUtility*          = WindowFlag 0x0000_0000_0002_0000
    wfTooltip*          = WindowFlag 0x0000_0000_0004_0000
    wfPopupMenu*        = WindowFlag 0x0000_0000_0008_0000
    wfKeyboardGrabbed*  = WindowFlag 0x0000_0000_0010_0000
    wfVulkan*           = WindowFlag 0x0000_0000_1000_0000
    wfMetal*            = WindowFlag 0x0000_0000_2000_0000
    wfTransparent*      = WindowFlag 0x0000_0000_4000_0000
    wfNotFocusable*     = WindowFlag 0x0000_0000_8000_0000

type WindowPos* {.size: sizeof(int32).} = enum
    wpUndefined = 0x1FFF_0000
    wpCentered  = 0x2FFF_0000
converter toInt32(x: WindowPos): int32 = int32 x

proc create_window*(title: cstring, w, h: cint, flags: WindowFlag): Window {.importc: "SDL_CreateWindow", dynlib: SDLPath.}
proc create_window*(title: string, w, h: int32, flags: WindowFlag): Window =
    result = create_window(cstring title, w, h, flags)
    if result == nil:
        echo red "Error: failed to open window (SDL_CreateWindow): " & $get_error()

proc set_window_position*(window: Window; x, y: int32) {.importc: "SDL_SetWindowPosition", dynlib: SDLPath.}
proc center_window*(window: Window) =
    set_window_position(window, wpCentered, wpCentered)

proc destroy_window*(window: Window) {.importc: "SDL_DestroyWindow", dynlib: SDLPath.}
proc quit*()                         {.importc: "SDL_Quit"         , dynlib: SDLPath.}

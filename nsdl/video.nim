import common, pixels, rect

# TODO: use a block structure for this
# TODO: figure out how to move this to common
proc check_pointer[T](p: pointer; msg: string): Option[T] =
    let msgi {.inject.} = msg # https://github.com/nim-lang/Nim/issues/10977
    if p == nil:
        echo red fmt"Error: failed to get {msgi}: {get_error()}"
        result = none T
    else:
        result = some cast[ptr T](p)[]

type Window* = distinct pointer

type WindowFlag* {.size: sizeof(uint64).} = enum
    Fullscreen       = 0x0000_0000_0000_0001
    OpenGL           = 0x0000_0000_0000_0002
    Occluded         = 0x0000_0000_0000_0004
    Hidden           = 0x0000_0000_0000_0008
    Borderless       = 0x0000_0000_0000_0010
    Resizable        = 0x0000_0000_0000_0020
    Minimized        = 0x0000_0000_0000_0040
    Maximized        = 0x0000_0000_0000_0080
    MouseGrabbed     = 0x0000_0000_0000_0100
    InputFocus       = 0x0000_0000_0000_0200
    MouseFocus       = 0x0000_0000_0000_0400
    External         = 0x0000_0000_0000_0800
    HighPixelDensity = 0x0000_0000_0000_2000
    MouseCapture     = 0x0000_0000_0000_4000
    AlwaysOnTop      = 0x0000_0000_0000_8000
    SkipTaskbar      = 0x0000_0000_0001_0000
    Utility          = 0x0000_0000_0002_0000
    Tooltip          = 0x0000_0000_0004_0000
    PopupMenu        = 0x0000_0000_0008_0000
    KeyboardGrabbed  = 0x0000_0000_0010_0000
    Vulkan           = 0x0000_0000_1000_0000
    Metal            = 0x0000_0000_2000_0000
    Transparent      = 0x0000_0000_4000_0000
    NotFocusable     = 0x0000_0000_8000_0000
func `or`*(a, b: WindowFlag): WindowFlag =
    WindowFlag (a.ord or b.ord)

type WindowPos* {.size: sizeof(int32).} = enum
    Undefined = 0x1FFF_0000
    Centered  = 0x2FFF_0000
converter toInt32(x: WindowPos): int32 = int32 x

type
    SystemTheme* {.size: sizeof(int32).} = enum
        Unknown
        Light
        Dark

    DisplayOrientation* {.size: sizeof(int32).} = enum
        Unknown
        Landscape
        LandscapeFlipped
        Portrait
        PortraitFlipped

    FlashOperation* {.size: sizeof(int32).} = enum
        Cancel
        Briefly
        UntilFocused

type
    DisplayID*  = distinct uint32
    WindowID*   = distinct uint32
    ICCProfile* = distinct pointer

    DisplayMode* = object
        display_id*  : DisplayID
        px_format*   : PixelFormat
        w*, h*       : int32
        px_density*  : float32
        refresh_rate*: float32
        driver_data* : pointer

proc create_window*(title: cstring, w, h: int32, flags: WindowFlag): pointer      {.importc: "SDL_CreateWindow"     , dynlib: SDLPath.}
proc create_popup*(parent: Window; x, y, w, h: int32; flags: WindowFlag): pointer {.importc: "SDL_CreatePopupWindow", dynlib: SDLPath.}
proc create_window_opt*(title: string, w, h: int32, flags: WindowFlag): Option[Window] =
    let window = create_window(cstring title, w, h, flags)
    if window == nil:
        echo red fmt"Error: failed to open window: {get_error()}"
        result = none Window
    else:
        result = some Window window
proc create_popup_opt*(parent: Window; x, y, w, h: int32; flags: WindowFlag): Option[Window] =
    let window = create_popup(parent, x, y, w, h, flags)
    if window == nil:
        echo red fmt"Error: failed to open popup window: {get_error()}"
        result = none Window
    else:
        result = some Window window

proc set_window_position*(window: Window; x, y: int32) {.importc: "SDL_SetWindowPosition", dynlib: SDLPath.}
proc center_window*(window: Window) =
    set_window_position(window, Centered, Centered)

proc destroy_window*(window: Window) {.importc: "SDL_DestroyWindow", dynlib: SDLPath.}
proc quit*()                         {.importc: "SDL_Quit"         , dynlib: SDLPath.}
proc destroy*(win: Window) {.inline.} = destroy_window win

from properties import PropertyID
proc get_num_video_drivers*(): int32          {.importc: "SDL_GetNumVideoDrivers"   , dynlib: SDLPath.}
proc get_video_driver*(index: int32): cstring {.importc: "SDL_GetVideoDriver"       , dynlib: SDLPath.}
proc get_current_video_driver*(): cstring     {.importc: "SDL_GetCurrentVideoDriver", dynlib: SDLPath.}
proc get_system_theme*(): SystemTheme         {.importc: "SDL_GetSystemTheme"       , dynlib: SDLPath.}

proc get_displays*(count: ptr int32): ptr UncheckedArray[DisplayID] {.importc: "SDL_GetDisplays"         , dynlib: SDLPath.}
proc get_primary_display*(): DisplayID                              {.importc: "SDL_GetPrimaryDisplay"   , dynlib: SDLPath.}
proc get_properties*(id: DisplayID): PropertyID                     {.importc: "SDL_GetDisplayProperties", dynlib: SDLPath.}
proc get_name*(id: DisplayID): cstring                              {.importc: "SDL_GetDisplayName"      , dynlib: SDLPath.}

proc get_bounds*(id: DisplayID; rect: ptr Rect): int32        {.importc: "SDL_GetDisplayBounds"      , dynlib: SDLPath.}
proc get_usable_bounds*(id: DisplayID; rect: ptr Rect): int32 {.importc: "SDL_GetDisplayUsableBounds", dynlib: SDLPath.}
proc get_bounds*(id: DisplayID): Rect =
    if get_bounds(id, result.addr) != 0:
        echo red fmt"Error: failed to get bounds for display: {get_error()}"
proc get_usable_bounds*(id: DisplayID): Rect =
    if get_usable_bounds(id, result.addr) != 0:
        echo red fmt"Error: failed to get usable bounds for display: {get_error()}"

proc get_natural_orientation*(id: DisplayID): DisplayOrientation {.importc: "SDL_GetNaturalDisplayOrientation", dynlib: SDLPath.}
proc get_current_orientation*(id: DisplayID): DisplayOrientation {.importc: "SDL_GetCurrentDisplayOrientation", dynlib: SDLPath.}
proc get_content_scale*(id: DisplayID): float32                  {.importc: "SDL_GetDisplayContentScale"      , dynlib: SDLPath.}

# TODO: The modes returned need to be freed
proc get_fullscreen_modes*(id: DisplayID; count: ptr int32): ptr UncheckedArray[ptr DisplayMode] {.importc: "SDL_GetFullscreenDisplayModes", dynlib: SDLPath.}
proc get_fullscreen_modes*(id: DisplayID): seq[DisplayMode] =
    var count: int32
    let modes = get_fullscreen_modes(id, count.addr)
    if modes == nil:
        echo red fmt"Error: failed to get fullscreen display modes: {get_error()}"
    else:
        for mode in to_open_array(modes, 0, count - 1):
            result.add mode[]

proc get_closest_fullscreen_mode*(id: DisplayID; w, h: int32; refresh_rate: float32; include_high_density: bool): pointer
    {.importc: "SDL_GetClosestFullscreenDisplayMode", dynlib: SDLPath.}
proc get_desktop_mode*(id: DisplayID): pointer {.importc: "SDL_GetDesktopDisplayMode", dynlib: SDLPath.}
proc get_current_mode*(id: DisplayID): pointer {.importc: "SDL_GetCurrentDisplayMode", dynlib: SDLPath.}
proc get_closest_fullscreen_mode_opt*(id: DisplayID; w, h: int32; refresh_rate: float32; include_high_density: bool): Option[DisplayMode] =
    let mode = get_closest_fullscreen_mode(id, w, h, refresh_rate, include_high_density)
    check_pointer[DisplayMode](mode, "closest fullscreen mode")
proc get_desktop_mode_opt*(id: DisplayID): Option[DisplayMode] = check_pointer[DisplayMode](get_desktop_mode id, "desktop mode")
proc get_current_mode_opt*(id: DisplayID): Option[DisplayMode] = check_pointer[DisplayMode](get_current_mode id, "current mode")

proc get_display*(point: ptr Point): DisplayID {.importc: "SDL_GetDisplayForPoint" , dynlib: SDLPath.}
proc get_display*(point: ptr Rect): DisplayID  {.importc: "SDL_GetDisplayForRect"  , dynlib: SDLPath.}
proc get_display*(window: Window): DisplayID   {.importc: "SDL_GetDisplayForWindow", dynlib: SDLPath.}
proc get_display*(x, y: int): DisplayID =
    let point = Point(x: int32 x, y: int32 y)
    get_display point.addr
proc get_display*(x, y, w, h: int): DisplayID =
    let rect = Rect(x: int32 x, y: int32 y, w: int32 w, h: int32 h)
    get_display rect.addr

proc get_pixel_density*(window: Window): float32 {.importc: "SDL_GetWindowPixelDensity", dynlib: SDLPath.}
proc get_display_scale*(window: Window): float32 {.importc: "SDL_GetWindowDisplayScale", dynlib: SDLPath.}

proc set_fullscreen_mode_nocheck*(window: Window; mode: ptr DisplayMode): int32 {.importc: "SDL_SetWindowFullscreenMode", dynlib: SDLPath.}
proc get_fullscreen_mode_nocheck*(window: Window): ptr DisplayMode              {.importc: "SDL_GetWindowFullscreenMode", dynlib: SDLPath.}
proc set_fullscreen_mode*(window: Window; mode: DisplayMode) =
    if set_fullscreen_mode_nocheck(window, mode.addr) != 0:
        echo red fmt"Error: failed to set fullscreen mode for window: {get_error()}"
proc get_fullscreen_mode*(window: Window): Option[DisplayMode] =
    let mode = get_fullscreen_mode_nocheck window
    if mode == nil:
        none DisplayMode
    else:
        some mode[]

# TODO: this memory returned needs to be free'd
proc get_icc_profile_nocheck*(window: Window; size: ptr csize_t): pointer {.importc: "SDL_GetWindowICCProfile" , dynlib: SDLPath.}
proc get_pixel_format_nocheck*(window: Window): PixelFormat               {.importc: "SDL_GetWindowPixelFormat", dynlib: SDLPath.}
proc get_icc_profile_opt*(window: Window; size: uint64): Option[ICCProfile] =
    let profile = get_icc_profile_nocheck(window, cast[ptr csize_t](size.addr))
    check_pointer[ICCProfile](profile, "ICC profile")
proc get_pixel_format*(window: Window): PixelFormat =
    result = get_pixel_format_nocheck window
    if result == Unknown:
        echo red fmt"Error: failed to get pixel format for window: {get_error()}"

# TODO

# SDL_Window *SDLCALL SDL_CreateWindowWithProperties(SDL_PropertiesID props);

# typedef void *SDL_GLContext;
# typedef void *SDL_EGLDisplay;
# typedef void *SDL_EGLConfig;
# typedef void *SDL_EGLSurface;
# typedef intptr_t SDL_EGLAttrib;
# typedef int SDL_EGLint;
# typedef SDL_EGLAttrib *(SDLCALL *SDL_EGLAttribArrayCallback)(void);
# typedef SDL_EGLint *(SDLCALL *SDL_EGLIntArrayCallback)(void);
# typedef enum SDL_GLattr
# {
#     SDL_GL_RED_SIZE,
#     SDL_GL_GREEN_SIZE,
#     SDL_GL_BLUE_SIZE,
#     SDL_GL_ALPHA_SIZE,
#     SDL_GL_BUFFER_SIZE,
#     SDL_GL_DOUBLEBUFFER,
#     SDL_GL_DEPTH_SIZE,
#     SDL_GL_STENCIL_SIZE,
#     SDL_GL_ACCUM_RED_SIZE,
#     SDL_GL_ACCUM_GREEN_SIZE,
#     SDL_GL_ACCUM_BLUE_SIZE,
#     SDL_GL_ACCUM_ALPHA_SIZE,
#     SDL_GL_STEREO,
#     SDL_GL_MULTISAMPLEBUFFERS,
#     SDL_GL_MULTISAMPLESAMPLES,
#     SDL_GL_ACCELERATED_VISUAL,
#     SDL_GL_RETAINED_BACKING,
#     SDL_GL_CONTEXT_MAJOR_VERSION,
#     SDL_GL_CONTEXT_MINOR_VERSION,
#     SDL_GL_CONTEXT_FLAGS,
#     SDL_GL_CONTEXT_PROFILE_MASK,
#     SDL_GL_SHARE_WITH_CURRENT_CONTEXT,
#     SDL_GL_FRAMEBUFFER_SRGB_CAPABLE,
#     SDL_GL_CONTEXT_RELEASE_BEHAVIOR,
#     SDL_GL_CONTEXT_RESET_NOTIFICATION,
#     SDL_GL_CONTEXT_NO_ERROR,
#     SDL_GL_FLOATBUFFERS,
#     SDL_GL_EGL_PLATFORM
# } SDL_GLattr;

# typedef enum SDL_GLprofile
# {
#     SDL_GL_CONTEXT_PROFILE_CORE           = 0x0001,
#     SDL_GL_CONTEXT_PROFILE_COMPATIBILITY  = 0x0002,
#     SDL_GL_CONTEXT_PROFILE_ES             = 0x0004 /**< GLX_CONTEXT_ES2_PROFILE_BIT_EXT */
# } SDL_GLprofile;

# typedef enum SDL_GLcontextFlag
# {
#     SDL_GL_CONTEXT_DEBUG_FLAG              = 0x0001,
#     SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG = 0x0002,
#     SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG      = 0x0004,
#     SDL_GL_CONTEXT_RESET_ISOLATION_FLAG    = 0x0008
# } SDL_GLcontextFlag;

# typedef enum SDL_GLcontextReleaseFlag
# {
#     SDL_GL_CONTEXT_RELEASE_BEHAVIOR_NONE   = 0x0000,
#     SDL_GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH  = 0x0001
# } SDL_GLcontextReleaseFlag;

# typedef enum SDL_GLContextResetNotification
# {
#     SDL_GL_CONTEXT_RESET_NO_NOTIFICATION = 0x0000,
#     SDL_GL_CONTEXT_RESET_LOSE_CONTEXT    = 0x0001
# } SDL_GLContextResetNotification;

#define SDL_PROP_DISPLAY_HDR_ENABLED_BOOLEAN             "SDL.display.HDR_enabled"
#define SDL_PROP_DISPLAY_SDR_WHITE_POINT_FLOAT           "SDL.display.SDR_white_point"
#define SDL_PROP_DISPLAY_HDR_HEADROOM_FLOAT              "SDL.display.HDR_headroom"
#define SDL_PROP_DISPLAY_KMSDRM_PANEL_ORIENTATION_NUMBER "SDL.display.KMSDRM.panel_orientation"

#define SDL_PROP_WINDOW_CREATE_ALWAYS_ON_TOP_BOOLEAN               "always_on_top"
#define SDL_PROP_WINDOW_CREATE_BORDERLESS_BOOLEAN                  "borderless"
#define SDL_PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN                   "focusable"
#define SDL_PROP_WINDOW_CREATE_EXTERNAL_GRAPHICS_CONTEXT_BOOLEAN   "external_graphics_context"
#define SDL_PROP_WINDOW_CREATE_FULLSCREEN_BOOLEAN                  "fullscreen"
#define SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER                       "height"
#define SDL_PROP_WINDOW_CREATE_HIDDEN_BOOLEAN                      "hidden"
#define SDL_PROP_WINDOW_CREATE_HIGH_PIXEL_DENSITY_BOOLEAN          "high_pixel_density"
#define SDL_PROP_WINDOW_CREATE_MAXIMIZED_BOOLEAN                   "maximized"
#define SDL_PROP_WINDOW_CREATE_MENU_BOOLEAN                        "menu"
#define SDL_PROP_WINDOW_CREATE_METAL_BOOLEAN                       "metal"
#define SDL_PROP_WINDOW_CREATE_MINIMIZED_BOOLEAN                   "minimized"
#define SDL_PROP_WINDOW_CREATE_MODAL_BOOLEAN                       "modal"
#define SDL_PROP_WINDOW_CREATE_MOUSE_GRABBED_BOOLEAN               "mouse_grabbed"
#define SDL_PROP_WINDOW_CREATE_OPENGL_BOOLEAN                      "opengl"
#define SDL_PROP_WINDOW_CREATE_PARENT_POINTER                      "parent"
#define SDL_PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN                   "resizable"
#define SDL_PROP_WINDOW_CREATE_TITLE_STRING                        "title"
#define SDL_PROP_WINDOW_CREATE_TRANSPARENT_BOOLEAN                 "transparent"
#define SDL_PROP_WINDOW_CREATE_TOOLTIP_BOOLEAN                     "tooltip"
#define SDL_PROP_WINDOW_CREATE_UTILITY_BOOLEAN                     "utility"
#define SDL_PROP_WINDOW_CREATE_VULKAN_BOOLEAN                      "vulkan"
#define SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER                        "width"
#define SDL_PROP_WINDOW_CREATE_X_NUMBER                            "x"
#define SDL_PROP_WINDOW_CREATE_Y_NUMBER                            "y"
#define SDL_PROP_WINDOW_CREATE_COCOA_WINDOW_POINTER                "cocoa.window"
#define SDL_PROP_WINDOW_CREATE_COCOA_VIEW_POINTER                  "cocoa.view"
#define SDL_PROP_WINDOW_CREATE_WAYLAND_SCALE_TO_DISPLAY_BOOLEAN    "wayland.scale_to_display"
#define SDL_PROP_WINDOW_CREATE_WAYLAND_SURFACE_ROLE_CUSTOM_BOOLEAN "wayland.surface_role_custom"
#define SDL_PROP_WINDOW_CREATE_WAYLAND_CREATE_EGL_WINDOW_BOOLEAN   "wayland.create_egl_window"
#define SDL_PROP_WINDOW_CREATE_WAYLAND_WL_SURFACE_POINTER          "wayland.wl_surface"
#define SDL_PROP_WINDOW_CREATE_WIN32_HWND_POINTER                  "win32.hwnd"
#define SDL_PROP_WINDOW_CREATE_WIN32_PIXEL_FORMAT_HWND_POINTER     "win32.pixel_format_hwnd"
#define SDL_PROP_WINDOW_CREATE_X11_WINDOW_NUMBER                   "x11.window"

# extern DECLSPEC SDL_WindowID SDLCALL SDL_GetWindowID(SDL_Window *window);
# extern DECLSPEC SDL_Window *SDLCALL SDL_GetWindowFromID(SDL_WindowID id);
# extern DECLSPEC SDL_Window *SDLCALL SDL_GetWindowParent(SDL_Window *window);
# extern DECLSPEC SDL_PropertiesID SDLCALL SDL_GetWindowProperties(SDL_Window *window);

#define SDL_PROP_WINDOW_SHAPE_POINTER                             "SDL.window.shape"
#define SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER                    "SDL.window.android.window"
#define SDL_PROP_WINDOW_ANDROID_SURFACE_POINTER                   "SDL.window.android.surface"
#define SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER                      "SDL.window.uikit.window"
#define SDL_PROP_WINDOW_UIKIT_METAL_VIEW_TAG_NUMBER               "SDL.window.uikit.metal_view_tag"
#define SDL_PROP_WINDOW_KMSDRM_DEVICE_INDEX_NUMBER                "SDL.window.kmsdrm.dev_index"
#define SDL_PROP_WINDOW_KMSDRM_DRM_FD_NUMBER                      "SDL.window.kmsdrm.drm_fd"
#define SDL_PROP_WINDOW_KMSDRM_GBM_DEVICE_POINTER                 "SDL.window.kmsdrm.gbm_dev"
#define SDL_PROP_WINDOW_COCOA_WINDOW_POINTER                      "SDL.window.cocoa.window"
#define SDL_PROP_WINDOW_COCOA_METAL_VIEW_TAG_NUMBER               "SDL.window.cocoa.metal_view_tag"
#define SDL_PROP_WINDOW_VIVANTE_DISPLAY_POINTER                   "SDL.window.vivante.display"
#define SDL_PROP_WINDOW_VIVANTE_WINDOW_POINTER                    "SDL.window.vivante.window"
#define SDL_PROP_WINDOW_VIVANTE_SURFACE_POINTER                   "SDL.window.vivante.surface"
#define SDL_PROP_WINDOW_WINRT_WINDOW_POINTER                      "SDL.window.winrt.window"
#define SDL_PROP_WINDOW_WIN32_HWND_POINTER                        "SDL.window.win32.hwnd"
#define SDL_PROP_WINDOW_WIN32_HDC_POINTER                         "SDL.window.win32.hdc"
#define SDL_PROP_WINDOW_WIN32_INSTANCE_POINTER                    "SDL.window.win32.instance"
#define SDL_PROP_WINDOW_WAYLAND_DISPLAY_POINTER                   "SDL.window.wayland.display"
#define SDL_PROP_WINDOW_WAYLAND_SURFACE_POINTER                   "SDL.window.wayland.surface"
#define SDL_PROP_WINDOW_WAYLAND_EGL_WINDOW_POINTER                "SDL.window.wayland.egl_window"
#define SDL_PROP_WINDOW_WAYLAND_XDG_SURFACE_POINTER               "SDL.window.wayland.xdg_surface"
#define SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_POINTER              "SDL.window.wayland.xdg_toplevel"
#define SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_EXPORT_HANDLE_STRING "SDL.window.wayland.xdg_toplevel_export_handle"
#define SDL_PROP_WINDOW_WAYLAND_XDG_POPUP_POINTER                 "SDL.window.wayland.xdg_popup"
#define SDL_PROP_WINDOW_WAYLAND_XDG_POSITIONER_POINTER            "SDL.window.wayland.xdg_positioner"
#define SDL_PROP_WINDOW_X11_DISPLAY_POINTER                       "SDL.window.x11.display"
#define SDL_PROP_WINDOW_X11_SCREEN_NUMBER                         "SDL.window.x11.screen"
#define SDL_PROP_WINDOW_X11_WINDOW_NUMBER                         "SDL.window.x11.window"

# extern DECLSPEC SDL_WindowFlags SDLCALL SDL_GetWindowFlags(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_SetWindowTitle(SDL_Window *window, const char *title);
# extern DECLSPEC const char *SDLCALL SDL_GetWindowTitle(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_SetWindowIcon(SDL_Window *window, SDL_Surface *icon);
# extern DECLSPEC int SDLCALL SDL_SetWindowPosition(SDL_Window *window, int x, int y);
# extern DECLSPEC int SDLCALL SDL_GetWindowPosition(SDL_Window *window, int *x, int *y);
# extern DECLSPEC int SDLCALL SDL_SetWindowSize(SDL_Window *window, int w, int h);
# extern DECLSPEC int SDLCALL SDL_GetWindowSize(SDL_Window *window, int *w, int *h);
# extern DECLSPEC int SDLCALL SDL_GetWindowBordersSize(SDL_Window *window, int *top, int *left, int *bottom, int *right);
# extern DECLSPEC int SDLCALL SDL_GetWindowSizeInPixels(SDL_Window *window, int *w, int *h);
# extern DECLSPEC int SDLCALL SDL_SetWindowMinimumSize(SDL_Window *window, int min_w, int min_h);
# extern DECLSPEC int SDLCALL SDL_GetWindowMinimumSize(SDL_Window *window, int *w, int *h);
# extern DECLSPEC int SDLCALL SDL_SetWindowMaximumSize(SDL_Window *window, int max_w, int max_h);
# extern DECLSPEC int SDLCALL SDL_GetWindowMaximumSize(SDL_Window *window, int *w, int *h);
# extern DECLSPEC int SDLCALL SDL_SetWindowBordered(SDL_Window *window, SDL_bool bordered);
# extern DECLSPEC int SDLCALL SDL_SetWindowResizable(SDL_Window *window, SDL_bool resizable);
# extern DECLSPEC int SDLCALL SDL_SetWindowAlwaysOnTop(SDL_Window *window, SDL_bool on_top);
# extern DECLSPEC int SDLCALL SDL_ShowWindow(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_HideWindow(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_RaiseWindow(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_MaximizeWindow(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_MinimizeWindow(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_RestoreWindow(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_SetWindowFullscreen(SDL_Window *window, SDL_bool fullscreen);
# extern DECLSPEC int SDLCALL SDL_SyncWindow(SDL_Window *window);
# extern DECLSPEC SDL_bool SDLCALL SDL_WindowHasSurface(SDL_Window *window);
# extern DECLSPEC SDL_Surface *SDLCALL SDL_GetWindowSurface(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_UpdateWindowSurface(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_UpdateWindowSurfaceRects(SDL_Window *window, const SDL_Rect *rects, int numrects);
# extern DECLSPEC int SDLCALL SDL_DestroyWindowSurface(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_SetWindowKeyboardGrab(SDL_Window *window, SDL_bool grabbed);
# extern DECLSPEC int SDLCALL SDL_SetWindowMouseGrab(SDL_Window *window, SDL_bool grabbed);
# extern DECLSPEC SDL_bool SDLCALL SDL_GetWindowKeyboardGrab(SDL_Window *window);
# extern DECLSPEC SDL_bool SDLCALL SDL_GetWindowMouseGrab(SDL_Window *window);
# extern DECLSPEC SDL_Window *SDLCALL SDL_GetGrabbedWindow(void);
# extern DECLSPEC int SDLCALL SDL_SetWindowMouseRect(SDL_Window *window, const SDL_Rect *rect);
# extern DECLSPEC const SDL_Rect *SDLCALL SDL_GetWindowMouseRect(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_SetWindowOpacity(SDL_Window *window, float opacity);
# extern DECLSPEC int SDLCALL SDL_GetWindowOpacity(SDL_Window *window, float *out_opacity);
# extern DECLSPEC int SDLCALL SDL_SetWindowModalFor(SDL_Window *modal_window, SDL_Window *parent_window);
# extern DECLSPEC int SDLCALL SDL_SetWindowInputFocus(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_SetWindowFocusable(SDL_Window *window, SDL_bool focusable);
# extern DECLSPEC int SDLCALL SDL_ShowWindowSystemMenu(SDL_Window *window, int x, int y);

# typedef enum SDL_HitTestResult
# {
#     SDL_HITTEST_NORMAL,             /**< Region is normal. No special properties. */
#     SDL_HITTEST_DRAGGABLE,          /**< Region can drag entire window. */
#     SDL_HITTEST_RESIZE_TOPLEFT,     /**< Region is the resizable top-left corner border. */
#     SDL_HITTEST_RESIZE_TOP,         /**< Region is the resizable top border. */
#     SDL_HITTEST_RESIZE_TOPRIGHT,    /**< Region is the resizable top-right corner border. */
#     SDL_HITTEST_RESIZE_RIGHT,       /**< Region is the resizable right border. */
#     SDL_HITTEST_RESIZE_BOTTOMRIGHT, /**< Region is the resizable bottom-right corner border. */
#     SDL_HITTEST_RESIZE_BOTTOM,      /**< Region is the resizable bottom border. */
#     SDL_HITTEST_RESIZE_BOTTOMLEFT,  /**< Region is the resizable bottom-left corner border. */
#     SDL_HITTEST_RESIZE_LEFT         /**< Region is the resizable left border. */
# } SDL_HitTestResult;

# typedef SDL_HitTestResult (SDLCALL *SDL_HitTest)(SDL_Window *win,
                                                #  const SDL_Point *area,
                                                #  void *data);

# extern DECLSPEC int SDLCALL SDL_SetWindowHitTest(SDL_Window *window, SDL_HitTest callback, void *callback_data);
# extern DECLSPEC int SDLCALL SDL_SetWindowShape(SDL_Window *window, SDL_Surface *shape);
# extern DECLSPEC int SDLCALL SDL_FlashWindow(SDL_Window *window, SDL_FlashOperation operation);
# extern DECLSPEC void SDLCALL SDL_DestroyWindow(SDL_Window *window);
# extern DECLSPEC SDL_bool SDLCALL SDL_ScreenSaverEnabled(void);
# extern DECLSPEC int SDLCALL SDL_EnableScreenSaver(void);
# extern DECLSPEC int SDLCALL SDL_DisableScreenSaver(void);
# extern DECLSPEC int SDLCALL SDL_GL_LoadLibrary(const char *path);
# extern DECLSPEC SDL_FunctionPointer SDLCALL SDL_GL_GetProcAddress(const char *proc);
# extern DECLSPEC SDL_FunctionPointer SDLCALL SDL_EGL_GetProcAddress(const char *proc);
# extern DECLSPEC void SDLCALL SDL_GL_UnloadLibrary(void);
# extern DECLSPEC SDL_bool SDLCALL SDL_GL_ExtensionSupported(const char *extension);
# extern DECLSPEC void SDLCALL SDL_GL_ResetAttributes(void);
# extern DECLSPEC int SDLCALL SDL_GL_SetAttribute(SDL_GLattr attr, int value);
# extern DECLSPEC int SDLCALL SDL_GL_GetAttribute(SDL_GLattr attr, int *value);
# extern DECLSPEC SDL_GLContext SDLCALL SDL_GL_CreateContext(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_GL_MakeCurrent(SDL_Window *window, SDL_GLContext context);
# extern DECLSPEC SDL_Window *SDLCALL SDL_GL_GetCurrentWindow(void);
# extern DECLSPEC SDL_GLContext SDLCALL SDL_GL_GetCurrentContext(void);
# extern DECLSPEC SDL_EGLDisplay SDLCALL SDL_EGL_GetCurrentEGLDisplay(void);
# extern DECLSPEC SDL_EGLConfig SDLCALL SDL_EGL_GetCurrentEGLConfig(void);
# extern DECLSPEC SDL_EGLSurface SDLCALL SDL_EGL_GetWindowEGLSurface(SDL_Window *window);
# extern DECLSPEC void SDLCALL SDL_EGL_SetEGLAttributeCallbacks(SDL_EGLAttribArrayCallback platformAttribCallback,
                                                            #   SDL_EGLIntArrayCallback surfaceAttribCallback,
                                                            #   SDL_EGLIntArrayCallback contextAttribCallback);
# extern DECLSPEC int SDLCALL SDL_GL_SetSwapInterval(int interval);
# extern DECLSPEC int SDLCALL SDL_GL_GetSwapInterval(int *interval);
# extern DECLSPEC int SDLCALL SDL_GL_SwapWindow(SDL_Window *window);
# extern DECLSPEC int SDLCALL SDL_GL_DeleteContext(SDL_GLContext context);

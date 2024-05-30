{.push raises: [].}

import common, pixels, rect

type Window* = distinct pointer

type WindowFlag* {.size: sizeof(uint64).} = enum
    None             = 0x0000_0000_0000_0000
    Fullscreen       = 0x0000_0000_0000_0001
    OpenGL           = 0x0000_0000_0000_0002
    Occluded         = 0x0000_0000_0000_0004
    Hidden           = 0x0000_0000_0000_0008
    Borderless       = 0x0000_0000_0000_0010
    Resizeable       = 0x0000_0000_0000_0020
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

#[ -------------------------------------------------------------------- ]#

from properties import PropertyID
using
    window: Window
    d_id: DisplayID

{.push dynlib: SDLPath.}
proc create_window*(title: cstring, w, h: cint, flags: WindowFlag): pointer                     {.importc: "SDL_CreateWindow"                   .}
proc create_popup_window*(parent: Window; x, y, w, h: cint; flags: WindowFlag): pointer         {.importc: "SDL_CreatePopupWindow"              .}
proc set_window_position*(window; x, y: cint)                                                   {.importc: "SDL_SetWindowPosition"              .}
proc destroy_window*(window)                                                                    {.importc: "SDL_DestroyWindow"                  .}
proc quit*()                                                                                    {.importc: "SDL_Quit"                           .}
proc get_num_video_drivers*(): cint                                                             {.importc: "SDL_GetNumVideoDrivers"             .}
proc get_video_driver*(index: cint): cstring                                                    {.importc: "SDL_GetVideoDriver"                 .}
proc get_current_video_driver*(): cstring                                                       {.importc: "SDL_GetCurrentVideoDriver"          .}
proc get_system_theme*(): SystemTheme                                                           {.importc: "SDL_GetSystemTheme"                 .}
proc get_displays*(count: ptr cint): ptr DisplayID                                              {.importc: "SDL_GetDisplays"                    .}
proc get_primary_display*(): DisplayID                                                          {.importc: "SDL_GetPrimaryDisplay"              .}
proc get_display_properties*(d_id): PropertyID                                                  {.importc: "SDL_GetDisplayProperties"           .}
proc get_display_name*(d_id): cstring                                                           {.importc: "SDL_GetDisplayName"                 .}
proc get_display_bounds*(d_id; rect: ptr Rect): cint                                            {.importc: "SDL_GetDisplayBounds"               .}
proc get_display_usable_bounds*(d_id; rect: ptr Rect): cint                                     {.importc: "SDL_GetDisplayUsableBounds"         .}
proc get_natural_display_orientation*(d_id): DisplayOrientation                                 {.importc: "SDL_GetNaturalDisplayOrientation"   .}
proc get_current_display_orientation*(d_id): DisplayOrientation                                 {.importc: "SDL_GetCurrentDisplayOrientation"   .}
proc get_display_content_scale*(d_id): cfloat                                                   {.importc: "SDL_GetDisplayContentScale"         .}
proc get_fullscreen_display_modes*(d_id; count: ptr cint): ptr ptr DisplayMode                  {.importc: "SDL_GetFullscreenDisplayModes"      .}
proc get_closest_fullscreen_display_mode*(d_id; w, h: cint; refresh: cfloat; hd: bool): pointer {.importc: "SDL_GetClosestFullscreenDisplayMode".}
proc get_desktop_display_mode*(d_id): pointer                                                   {.importc: "SDL_GetDesktopDisplayMode"          .}
proc get_current_display_mode*(d_id): pointer                                                   {.importc: "SDL_GetCurrentDisplayMode"          .}
proc get_display_for_point*(point: ptr Point): DisplayID                                        {.importc: "SDL_GetDisplayForPoint"             .}
proc get_display_for_rect*(point: ptr Rect): DisplayID                                          {.importc: "SDL_GetDisplayForRect"              .}
proc get_display_for_window*(window): DisplayID                                                 {.importc: "SDL_GetDisplayForWindow"            .}
proc get_window_pixel_density*(window): float32                                                 {.importc: "SDL_GetWindowPixelDensity"          .}
proc get_window_display_scale*(window): float32                                                 {.importc: "SDL_GetWindowDisplayScale"          .}
proc set_window_fullscreen_mode*(window; mode: ptr DisplayMode): int32                          {.importc: "SDL_SetWindowFullscreenMode"        .}
proc get_window_fullscreen_mode*(window): ptr DisplayMode                                       {.importc: "SDL_GetWindowFullscreenMode"        .}
proc get_window_icc_profile*(window; size: ptr csize_t): pointer                                {.importc: "SDL_GetWindowICCProfile"            .}
proc get_window_pixel_format*(window): PixelFormat                                              {.importc: "SDL_GetWindowPixelFormat"           .}
{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}

proc create_window*(title: string, w, h: int, flags: WindowFlag = None): Window {.raises: SDLError.} =
    check_ptr[Window] "Failed to create window":
        create_window(cstring title, cint w, cint h, flags)
proc create_popup*(parent: Window; x, y, w, h: int; flags: WindowFlag = None): Window {.raises: SDLError.} =
    check_ptr[Window] "Failed to create popup window":
        create_popup_window(parent, cint x, cint y, cint w, cint h, flags)

proc get_bounds*(d_id): Rect {.raises: SDLError.} =
    check_err "Failed to get bounds for display":
        get_display_bounds(d_id, result.addr)
proc get_usable_bounds*(d_id): Rect {.raises: SDLError.} =
    check_err "Failed to get usable bounds for display":
        get_display_usable_bounds(d_id, result.addr)

# TODO: The modes returned need to be free'd
proc get_fullscreen_modes*(d_id): seq[DisplayMode] {.raises: SDLError.} =
    var count: cint
    let modes = check_ptr[ptr UncheckedArray[ptr DisplayMode]] "Failed to get fullscreen display modes":
        get_fullscreen_display_modes(d_id, count.addr)

    for mode in to_open_array(modes, 0, count - 1):
        result.add mode[]
proc get_desktop_mode_opt*(d_id): DisplayMode {.raises: SDLError.} =
    let mode = check_ptr[ptr DisplayMode] "Failed to get desktop display mode":
        get_desktop_display_mode d_id
    mode[]
proc get_current_mode_opt*(d_id): DisplayMode {.raises: SDLError.} =
    let mode = check_ptr[ptr DisplayMode] "Failed to get current display mode":
        get_current_display_mode d_id
    mode[]

proc set_fullscreen_mode*(window; mode: DisplayMode) {.raises: SDLError.} =
    check_err "Failed to set fullscreen mode for window":
        set_window_fullscreen_mode(window, mode.addr)
proc get_fullscreen_mode*(window): DisplayMode {.raises: SDLError.} =
    let mode = check_ptr[ptr DisplayMode] "Failed to get fullscreen window mode":
        get_window_fullscreen_mode window
    mode[]

#[ -------------------------------------------------------------------- ]#

proc center*(window) =
    set_window_position(window, Centered, Centered)

proc get_display*(x, y: int): DisplayID =
    let point = Point(x: int32 x, y: int32 y)
    get_display_for_point point.addr
proc get_display*(x, y, w, h: int): DisplayID =
    let rect = Rect(x: int32 x, y: int32 y, w: int32 w, h: int32 h)
    get_display_for_rect rect.addr

proc get_pixel_format*(window): PixelFormat =
    result = get_window_pixel_format window
    if result == Unknown:
        echo red &"Error: failed to get pixel format for window: {get_error()}"

proc destroy*(window) =
    destroy_window window

{.pop.}

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

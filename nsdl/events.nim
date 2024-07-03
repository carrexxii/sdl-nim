import common, keyboard
from video   import Window, WindowID, DisplayID
from surface import Surface

export keyboard

type
    MouseButton* = distinct uint8
    MouseID*     = distinct uint32
    Cursor*      = distinct pointer

    SystemCursor* {.size: sizeof(cint).} = enum
        Arrow
        IBeam
        Wait
        Crosshair
        WaitArrow
        SizeNWSE
        SizeNESW
        SizeWE
        SizeNS
        SizeAll
        No
        Hand
        WindowTopLeft
        WindowTop
        WindowTopRight
        WindowRight
        WindowBottomRight
        WindowBottom
        WindowBottomLeft
        WindowLeft

    MouseWheelDirection* {.size: sizeof(cint).} = enum
        Normal
        Flipped

    MouseButtonKind* {.size: sizeof(uint8).} = enum
        Left   = 1
        Middle = 2
        Right  = 3
        X1     = 4
        X2     = 5

    # Hard-coded unlike the SDL version which calculates it based off of MouseButtonKind values
    # assigning values to the enum seems to break the bitset
    MouseButtonFlag* {.size: sizeof(uint32).} = enum
        Left
        Middle
        Right
        X1
        X2
    MouseButtonMask* = set[MouseButtonFlag]

converter to_button_mask*(mask: SomeInteger): MouseButtonMask =
    cast[MouseButtonMask](mask)

#[ -------------------------------------------------------------------- ]#

type
    Timestamp*   = distinct uint64
    KeyboardID*  = distinct uint32

    EventKind* {.size: sizeof(cint).} = enum
        First = 0x0
        Quit = 0x100
        Terminating
        LowMemory
        WillEnterBackground
        DidEnterBackground
        WillEnterForeground
        DidEnterForeground
        LocaleChanged
        SystemThemeChanged

        DisplayOrientation = 0x151
        DisplayAdded
        DisplayRemoved
        DisplayMoved
        DisplayContentScaleChanged
        DisplayHDRStateChanged

        WindowShown = 0x202
        WindowHidden
        WindowExposed
        WindowMoved
        WindowResized
        WindowPixelSizeChanged
        WindowMinimized
        WindowMaximized
        WindowRestored
        WindowMouseEnter
        WindowMouseLeave
        WindowFocusGained
        WindowFocusLost
        WindowCloseRequested
        WindowTakeFocus
        WindowHitTest
        WindowICCProfChanged
        WindowDisplayChanged
        WindowDisplayScaleChanged
        WindowOccluded
        WindowEnterFullscreen
        WindowLeaveFullscreen
        WindowDestroyed
        WindowPenEnter
        WindowPenLeave

        KeyDown = 0x300
        KeyUp
        TextEditing
        TextInput
        KeymapChanged
        KeyboardAdded
        KeyboardRemoved

        MouseMotion = 0x400
        MouseButtonDownOWN
        MouseButtonUp
        MouseWheel
        MouseAdded
        MouseRemoved

        JoystickAxisMotion = 0x600
        JoystickBallMotion
        JoystickHatMotion
        JoystickButtonDown
        JoystickButtonUp
        JoystickAdded
        JoystickRemoved
        JoystickBatteryUpdated
        JoystickUpdateComplete

        GamepadAxisMotion = 0x650
        GamepadButtonDown
        GamepadButtonUp
        GamepadAdded
        GamepadRemoved
        GamepadRemapped
        GamepadTouchpadDown
        GamepadTouchpadMotion
        GamepadTouchpadUp
        GamepadSensorUpdate
        GamepadUpdateComplete
        GamepadSteamHandleUpdated

        FingerDown = 0x700
        FingerUp
        FingerMotion

        ClipboardUpdate = 0x900

        DropFile = 0x1000
        DropText
        DropBegin
        DropComplete
        DropPosition

        AudioDeviceAdded = 0x1100
        AudioDeviceRemoved
        AudioDeviceFormatChanged

        SensorUpdate = 0x1200

        PenDown = 0x1300
        PenUp
        PenMotion
        PenButtonDown
        PenButtonUp

        CameraDeviceAdded = 0x1400
        CameraDeviceRemoved
        CameraDeviceApproved
        CameraDeviceDenied

        RenderTargetsReset = 0x2000
        RenderDeviceReset

        PollSentinel = 0x7F00
        User = 0x8000
        UserMax = high uint32 # To allow custom events

    EventState* {.size: sizeof(cint).} = enum
        Released = 0
        Pressed  = 1

    EventAction* {.size: sizeof(cint).} = enum
        Add
        Peek
        Get

    CustomEvent* = distinct uint32

    CommonEvent* = object
        kind*   : uint32
        reserved: uint32
        time*   : Timestamp

    DisplayEvent* = object
        kind*      : EventKind
        reserved   : uint32
        time*      : Timestamp
        display_id*: DisplayID
        data*      : int32

    WindowEvent* = object
        kind*     : EventKind
        reserved  : uint32
        time*     : Timestamp
        window_id*: WindowID
        data1*    : int32
        data2*    : int32

    KeyboardDeviceEvent* = object
        kind*: EventKind
        reserved: uint32
        time*   : Timestamp
        kb_id*  : KeyboardID

    KeyboardEvent* = object
        kind*     : EventKind
        reserved  : uint32
        time*     : Timestamp
        window_id*: WindowID
        kb_id*    : KeyboardID
        state*    : uint8
        repeat*   : bool
        _         : uint16
        keysym*   : Keysym

    TextEditingEvent* = object
        kind*     : EventKind
        reserved  : uint32
        time*     : Timestamp
        window_id*: WindowID
        text*     : cstring
        start*    : int32
        len*      : int32

    TextInputEvent* = object
        kind*     : EventKind
        reserved  : uint32
        time*     : Timestamp
        window_id*: WindowID
        text*     : cstring

    MouseDeviceEvent* = object
        kind*    : EventKind
        reserved : uint32
        time*    : Timestamp
        mouse_id*: MouseID

    MouseMotionEvent* = object
        kind*     : EventKind
        reserved  : uint32
        time*     : Timestamp
        window_id*: WindowID
        mouse_id* : MouseID
        state*    : uint32
        x*, y*    : float32
        x_rel*    : float32
        y_rel*    : float32

    MouseButtonEvent* = object
        kind*     : EventKind
        reserved  : uint32
        time*     : Timestamp
        window_id*: WindowID
        mouse_id* : MouseID
        button*   : MouseButton
        state*    : uint8
        clicks*   : uint8
        _         : uint8
        x*, y*    : float32

    MouseWheelEvent* = object
        kind*     : EventKind
        reserved  : uint32
        time*     : Timestamp
        window_id*: WindowID
        mouse_id* : MouseID
        x*, y*    : float32
        direction*: MouseWheelDirection
        mouse_x*  : float32
        mouse_y*  : float32

    QuitEvent* = object
        kind*   : EventKind
        reserved: uint32
        time*   : Timestamp

    Event* {.union.} = object
        kind*     : EventKind
        common*   : CommonEvent
        display*  : DisplayEvent
        window*   : WindowEvent
        kdevice*  : KeyboardDeviceEvent
        key*      : KeyboardEvent
        edit*     : TextEditingEvent
        text*     : TextInputEvent
        mdevice*  : MouseDeviceEvent
        motion*   : MouseMotionEvent
        button*   : MouseButtonEvent
        wheel*    : MouseWheelEvent
        # jdevice*  : JoyDeviceEvent
        # jaxis*    : JoyAxisEvent
        # jball*    : JoyBallEvent
        # jhat*     : JoyHatEvent
        # jbutton*  : JoyButtonEvent
        # jbattery* : JoyBatteryEvent
        # gdevice*  : GamepadDeviceEvent
        # gaxis*    : GamepadAxisEvent
        # gbutton*  : GamepadButtonEvent
        # gtouchpad*: GamepadTouchpadEvent
        # gsensor*  : GamepadSensorEvent
        # adevice*  : AudioDeviceEvent
        # cdevice*  : CameraDeviceEvent
        # sensor*   : SensorEvent
        quit*     : QuitEvent
        # user*     : UserEvent
        # tfinger*  : TouchFingerEvent
        # ptip*     : PenTipEvent
        # pmotion*  : PenMotionEvent
        # pbutton*  : PenButtonEvent
        # drop*     : DropEvent
        # clipboard*: ClipboardEvent
        padding: array[128, byte]

func `==`*[T, U: CustomEvent | SomeInteger](a: T; b: U): bool =
    (uint32 a) == (uint32 b)

#[ -------------------------------------------------------------------- ]#

{.push dynlib: SDLLib.}
proc poll_event*(event: ptr Event): bool            {.importc: "SDL_PollEvent"          .}
proc register_events*(count: cint): uint32          {.importc: "SDL_RegisterEvents"     .}
proc allocate_event_memory*(size: csize_t): pointer {.importc: "SDL_AllocateEventMemory".}
proc push_event*(event: ptr Event): cint            {.importc: "SDL_PushEvent"          .}

proc has_mouse*(): bool                                                                {.importc: "SDL_HasMouse"             .}
proc get_mice*(count: ptr cint): ptr MouseID                                           {.importc: "SDL_GetMice"              .}
proc get_mouse_instance_name*(id: MouseID): cstring                                    {.importc: "SDL_GetMouseInstanceName" .}
proc get_mouse_focus*(): Window                                                        {.importc: "SDL_GetMouseFocus"        .}
proc get_mouse_state*(x, y: ptr cfloat): uint32                                        {.importc: "SDL_GetMouseState"        .}
proc get_global_mouse_state*(x, y: ptr cfloat): uint32                                 {.importc: "SDL_GetGlobalMouseState"  .}
proc get_relative_mouse_state*(x, y: ptr cfloat): uint32                               {.importc: "SDL_GetRelativeMouseState".}
proc warp_mouse_in_window*(window: Window; x, y: cfloat)                               {.importc: "SDL_WarpMouseInWindow"    .}
proc warp_mouse_global*(x, y: cfloat): cint                                            {.importc: "SDL_WarpMouseGlobal"      .}
proc set_relative_mouse_mode*(enabled: bool): cint                                     {.importc: "SDL_SetRelativeMouseMode" .}
proc capture_mouse*(enabled: bool): cint                                               {.importc: "SDL_CaptureMouse"         .}
proc get_relative_mouse_mode*(): bool                                                  {.importc: "SDL_GetRelativeMouseMode" .}
proc create_cursor*(data: ptr UncheckedArray[uint8]; w, h, hot_x, hot_y: cint): Cursor {.importc: "SDL_CreateCursor"         .}
proc create_colour_cursor*(surf: Surface; hot_x, hot_y: cint): Cursor                  {.importc: "SDL_CreateColorCursor"    .}
proc create_system_cursor*(id: SystemCursor): Cursor                                   {.importc: "SDL_CreateSystemCursor"   .}
proc set_cursor*(cursor: Cursor): cint                                                 {.importc: "SDL_SetCursor"            .}
proc get_cursor*(): Cursor                                                             {.importc: "SDL_GetCursor"            .}
proc get_default_cursor*(): Cursor                                                     {.importc: "SDL_GetDefaultCursor"     .}
proc destroy_cursor*(cursor: Cursor)                                                   {.importc: "SDL_DestroyCursor"        .}
proc show_cursor*(): cint                                                              {.importc: "SDL_DestroyCursor"        .}
proc hide_cursor*(): cint                                                              {.importc: "SDL_ShowCursor"           .}
proc cursor_visible*(): bool                                                           {.importc: "SDL_CursorVisible"        .}
{.pop.}

{.push inline, raises: [].}

iterator get_events*(): Event =
    var event: Event
    while poll_event(addr event):
        yield event

proc register_event*(): CustomEvent {.raises: SDLError.} =
    check_err 0, "Failed to register event":
        CustomEvent register_events 1

proc push_event*(event: Event) =
    let err = push_event event.addr
    if err > 0:
        return

    # This is needed to avoid having a ValueError raises tag which can prevent usage in a closure (mpv_set_wakeup_callback)
    try:
        if err < 0:
            echo red &"[NSDL] Failed to push event '{event}': {get_error()}"
        elif err == 0:
            echo yellow &"[NSDL] Warning: event '{event}' was filtered"
    except ValueError:
        echo "IDK"

# Mouse #

proc get_mouse_state*(): tuple[buttons: MouseButtonMask; x, y: int] =
    var x, y: cfloat
    result.buttons = get_mouse_state(x.addr, y.addr)
    result.x = int x
    result.y = int y

{.pop.}

# TODO:

# typedef struct SDL_JoyAxisEvent
# typedef struct SDL_JoyBallEvent
# typedef struct SDL_JoyHatEvent
# typedef struct SDL_JoyButtonEvent
# typedef struct SDL_JoyDeviceEvent
# typedef struct SDL_JoyBatteryEvent
# typedef struct SDL_GamepadAxisEvent
# typedef struct SDL_GamepadButtonEvent
# typedef struct SDL_GamepadDeviceEvent
# typedef struct SDL_GamepadTouchpadEvent
# typedef struct SDL_GamepadSensorEvent
# typedef struct SDL_AudioDeviceEvent
# typedef struct SDL_CameraDeviceEvent
# typedef struct SDL_TouchFingerEvent
# typedef struct SDL_PenTipEvent
# typedef struct SDL_PenMotionEvent
# typedef struct SDL_PenButtonEvent
# typedef struct SDL_DropEvent
# typedef struct SDL_ClipboardEvent
# typedef struct SDL_SensorEvent
# typedef struct SDL_UserEventc

# extern DECLSPEC void SDLCALL SDL_PumpEvents(void);
# extern DECLSPEC int SDLCALL SDL_PeepEvents(SDL_Event *events, int numevents, SDL_EventAction action, Uint32 minType, Uint32 maxType);
# extern DECLSPEC SDL_bool SDLCALL SDL_HasEvent(Uint32 type);
# extern DECLSPEC SDL_bool SDLCALL SDL_HasEvents(Uint32 minType, Uint32 maxType);
# extern DECLSPEC void SDLCALL SDL_FlushEvent(Uint32 type);
# extern DECLSPEC void SDLCALL SDL_FlushEvents(Uint32 minType, Uint32 maxType);
# extern DECLSPEC SDL_bool SDLCALL SDL_WaitEvent(SDL_Event *event);
# extern DECLSPEC SDL_bool SDLCALL SDL_WaitEventTimeout(SDL_Event *event, Sint32 timeoutMS);
# typedef int (SDLCALL *SDL_EventFilter)(void *userdata, SDL_Event *event);
# extern DECLSPEC void SDLCALL SDL_SetEventFilter(SDL_EventFilter filter, void *userdata);
# extern DECLSPEC SDL_bool SDLCALL SDL_GetEventFilter(SDL_EventFilter *filter, void **userdata);
# extern DECLSPEC int SDLCALL SDL_AddEventWatch(SDL_EventFilter filter, void *userdata);
# extern DECLSPEC void SDLCALL SDL_DelEventWatch(SDL_EventFilter filter, void *userdata);
# extern DECLSPEC void SDLCALL SDL_FilterEvents(SDL_EventFilter filter, void *userdata);
# extern DECLSPEC void SDLCALL SDL_SetEventEnabled(Uint32 type, SDL_bool enabled);
# extern DECLSPEC SDL_bool SDLCALL SDL_EventEnabled(Uint32 type);

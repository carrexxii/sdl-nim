import common, keyboard
from video   import Window, WindowID, DisplayID
from surface import Surface

export keyboard

type
    SystemCursor* {.size: sizeof(cint).} = enum
        cursorArrow
        cursorIBeam
        cursorWait
        cursorCrosshair
        cursorWaitArrow
        cursorSizeNWSE
        cursorSizeNESW
        cursorSizeWE
        cursorSizeNS
        cursorSizeAll
        cursorNo
        cursorHand
        cursorWindowTopLeft
        cursorWindowTop
        cursorWindowTopRight
        cursorWindowRight
        cursorWindowBottomRight
        cursorWindowBottom
        cursorWindowBottomLeft
        cursorWindowLeft

    MouseWheelDirection* {.size: sizeof(cint).} = enum
        dirNormal
        dirFlipped

    MouseButton* {.size: sizeof(uint8).} = enum
        btnLeft   = 1
        btnMiddle = 2
        btnRight  = 3
        btnX1     = 4
        btnX2     = 5

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
    Timestamp*  = distinct uint64
    KeyboardId* = distinct uint32
    MouseId*    = distinct uint32
    Cursor*     = distinct pointer

    EventKind* {.size: sizeof(cint).} = enum
        eventFirst = 0x0
        eventQuit = 0x100
        eventTerminating
        eventLowMemory
        eventWillEnterBackground
        eventDidEnterBackground
        eventWillEnterForeground
        eventDidEnterForeground
        eventLocaleChanged
        eventSystemThemeChanged

        eventDisplayOrientation = 0x151
        eventDisplayAdded
        eventDisplayRemoved
        eventDisplayMoved
        eventDisplayContentScaleChanged
        eventDisplayHDRStateChanged

        eventWindowShown = 0x202
        eventWindowHidden
        eventWindowExposed
        eventWindowMoved
        eventWindowResized
        eventWindowPixelSizeChanged
        eventWindowMinimized
        eventWindowMaximized
        eventWindowRestored
        eventWindowMouseEnter
        eventWindowMouseLeave
        eventWindowFocusGained
        eventWindowFocusLost
        eventWindowCloseRequested
        eventWindowTakeFocus
        eventWindowHitTest
        eventWindowICCProfChanged
        eventWindowDisplayChanged
        eventWindowDisplayScaleChanged
        eventWindowOccluded
        eventWindowEnterFullscreen
        eventWindowLeaveFullscreen
        eventWindowDestroyed
        eventWindowPenEnter
        eventWindowPenLeave

        eventKeyDown = 0x300
        eventKeyUp
        eventTextEditing
        eventTextInput
        eventKeymapChanged
        eventKeyboardAdded
        eventKeyboardRemoved

        eventMouseMotion = 0x400
        eventMouseButtonDown
        eventMouseButtonUp
        eventMouseWheel
        eventMouseAdded
        eventMouseRemoved

        eventJoystickAxisMotion = 0x600
        eventJoystickBallMotion
        eventJoystickHatMotion
        eventJoystickButtonDown
        eventJoystickButtonUp
        eventJoystickAdded
        eventJoystickRemoved
        eventJoystickBatteryUpdated
        eventJoystickUpdateComplete

        eventGamepadAxisMotion = 0x650
        eventGamepadButtonDown
        eventGamepadButtonUp
        eventGamepadAdded
        eventGamepadRemoved
        eventGamepadRemapped
        eventGamepadTouchpadDown
        eventGamepadTouchpadMotion
        eventGamepadTouchpadUp
        eventGamepadSensorUpdate
        eventGamepadUpdateComplete
        eventGamepadSteamHandleUpdated

        eventFingerDown = 0x700
        eventFingerUp
        eventFingerMotion

        eventClipboardUpdate = 0x900

        eventDropFile = 0x1000
        eventDropText
        eventDropBegin
        eventDropComplete
        eventDropPosition

        eventAudioDeviceAdded = 0x1100
        eventAudioDeviceRemoved
        eventAudioDeviceFormatChanged

        eventSensorUpdate = 0x1200

        eventPenDown = 0x1300
        eventPenUp
        eventPenMotion
        eventPenButtonDown
        eventPenButtonUp

        eventCameraDeviceAdded = 0x1400
        eventCameraDeviceRemoved
        eventCameraDeviceApproved
        eventCameraDeviceDenied

        eventRenderTargetsReset = 0x2000
        eventRenderDeviceReset

        eventPollSentinel = 0x7F00
        eventUser = 0x8000
        eventUserMax = high uint32 # To allow custom events

    EventState* {.size: sizeof(cint).} = enum
        stateReleased
        statePressed

    EventAction* {.size: sizeof(cint).} = enum
        actionAdd
        actionPeek
        actionGet

    CustomEvent* = distinct uint32

    CommonEvent* = object
        kind*: uint32
        _    : uint32
        time*: Timestamp

    DisplayEvent* = object
        kind*      : EventKind
        _          : uint32
        time*      : Timestamp
        display_id*: DisplayId
        data*      : int32

    WindowEvent* = object
        kind*  : EventKind
        _      : uint32
        time*  : Timestamp
        win_id*: WindowId
        data1* : int32
        data2* : int32

    KeyboardDeviceEvent* = object
        kind* : EventKind
        _     : uint32
        time* : Timestamp
        kb_id*: KeyboardId

    KeyboardEvent* = object
        kind*  : EventKind
        _      : uint32
        time*  : Timestamp
        win_id*: WindowId
        kb_id* : KeyboardId
        code*  : ScanCode
        key*   : KeyCode
        keymod*: KeyMod
        raw*   : uint16
        state* {.bitsize: 8.}: EventState
        repeat*: uint8

    TextEditingEvent* = object
        kind*  : EventKind
        _      : uint32
        time*  : Timestamp
        win_id*: WindowId
        text*  : cstring
        start* : int32
        len*   : int32

    TextInputEvent* = object
        kind*  : EventKind
        _      : uint32
        time*  : Timestamp
        win_id*: WindowId
        text*  : cstring

    MouseDeviceEvent* = object
        kind*    : EventKind
        _        : uint32
        time*    : Timestamp
        mouse_id*: MouseId

    MouseMotionEvent* = object
        kind*    : EventKind
        _        : uint32
        time*    : Timestamp
        win_id*  : WindowId
        mouse_id*: MouseId
        state*   : uint32
        x*, y*   : float32
        x_rel*   : float32
        y_rel*   : float32

    MouseButtonEvent* = object
        kind*    : EventKind
        pad1     : uint32
        time*    : Timestamp
        win_id*  : WindowId
        mouse_id*: MouseId
        button*  : MouseButton
        state*   : uint8
        clicks*  : uint8
        pad2     : uint8
        x*, y*   : float32

    MouseWheelEvent* = object
        kind*    : EventKind
        _        : uint32
        time*    : Timestamp
        win_id*  : WindowId
        mouse_id*: MouseId
        x*, y*   : float32
        dir*     : MouseWheelDirection
        mouse_x* : float32
        mouse_y* : float32

    QuitEvent* = object
        kind*: EventKind
        _    : uint32
        time*: Timestamp

    Event* {.union.} = object
        kind*     : EventKind
        common*   : CommonEvent
        display*  : DisplayEvent
        win*      : WindowEvent
        kdevice*  : KeyboardDeviceEvent
        kb*       : KeyboardEvent
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
        _: array[128, byte]

func `==`*[T, U: CustomEvent | SomeInteger](a: T; b: U): bool =
    (uint32 a) == (uint32 b)

#[ -------------------------------------------------------------------- ]#

{.push dynlib: SdlLib.}
proc sdl_poll_event*(event: ptr Event): bool            {.importc: "SDL_PollEvent"          .}
proc sdl_register_events*(count: cint): uint32          {.importc: "SDL_RegisterEvents"     .}
proc sdl_allocate_event_memory*(size: csize_t): pointer {.importc: "SDL_AllocateEventMemory".}
proc sdl_push_event*(event: ptr Event): cint            {.importc: "SDL_PushEvent"          .}

proc sdl_has_mouse*(): bool                                                                {.importc: "SDL_HasMouse"             .}
proc sdl_get_mice*(count: ptr cint): ptr MouseId                                           {.importc: "SDL_GetMice"              .}
proc sdl_get_mouse_instance_name*(id: MouseId): cstring                                    {.importc: "SDL_GetMouseInstanceName" .}
proc sdl_get_mouse_focus*(): Window                                                        {.importc: "SDL_GetMouseFocus"        .}
proc sdl_get_mouse_state*(x, y: ptr cfloat): MouseButtonMask                               {.importc: "SDL_GetMouseState"        .}
proc sdl_get_global_mouse_state*(x, y: ptr cfloat): uint32                                 {.importc: "SDL_GetGlobalMouseState"  .}
proc sdl_get_relative_mouse_state*(x, y: ptr cfloat): uint32                               {.importc: "SDL_GetRelativeMouseState".}
proc sdl_warp_mouse_in_window*(window: Window; x, y: cfloat)                               {.importc: "SDL_WarpMouseInWindow"    .}
proc sdl_warp_mouse_global*(x, y: cfloat): cint                                            {.importc: "SDL_WarpMouseGlobal"      .}
proc sdl_set_relative_mouse_mode*(enabled: bool): cint                                     {.importc: "SDL_SetRelativeMouseMode" .}
proc sdl_capture_mouse*(enabled: bool): cint                                               {.importc: "SDL_CaptureMouse"         .}
proc sdl_get_relative_mouse_mode*(): bool                                                  {.importc: "SDL_GetRelativeMouseMode" .}
proc sdl_create_cursor*(data: ptr UncheckedArray[uint8]; w, h, hot_x, hot_y: cint): Cursor {.importc: "SDL_CreateCursor"         .}
proc sdl_create_colour_cursor*(surf: Surface; hot_x, hot_y: cint): Cursor                  {.importc: "SDL_CreateColorCursor"    .}
proc sdl_create_system_cursor*(id: SystemCursor): Cursor                                   {.importc: "SDL_CreateSystemCursor"   .}
proc sdl_set_cursor*(cursor: Cursor): cint                                                 {.importc: "SDL_SetCursor"            .}
proc sdl_get_cursor*(): Cursor                                                             {.importc: "SDL_GetCursor"            .}
proc sdl_get_default_cursor*(): Cursor                                                     {.importc: "SDL_GetDefaultCursor"     .}
proc sdl_destroy_cursor*(cursor: Cursor)                                                   {.importc: "SDL_DestroyCursor"        .}
proc sdl_show_cursor*(): cint                                                              {.importc: "SDL_DestroyCursor"        .}
proc sdl_hide_cursor*(): cint                                                              {.importc: "SDL_ShowCursor"           .}
proc sdl_cursor_visible*(): bool                                                           {.importc: "SDL_CursorVisible"        .}
{.pop.}

{.push inline.}

iterator events*(): Event =
    var event: Event
    while sdl_poll_event(event.addr):
        yield event

proc register_event*(): CustomEvent =
    CustomEvent sdl_register_events(1)

proc push_event*(event: Event): bool =
    let err = sdl_push_event(event.addr)
    err > 0

#~ Mouse ~#

proc mouse_state*(): tuple[btns: MouseButtonMask; x, y: float32] =
    result.btns = sdl_get_mouse_state(result.x.addr, result.y.addr)

{.pop.} # inline

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

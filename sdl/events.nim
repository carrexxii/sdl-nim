import common, keyboard, mouse
from video import Window, WindowId, DisplayId

export keyboard

type
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
        eventDisplayDesktopModeChanged
        eventDisplayCurrentModeChanged
        eventDisplayContentScaleChanged

        eventWindowShown = 0x202
        eventWindowHidden
        eventWindowExposed
        eventWindowMoved
        eventWindowResized
        eventWindowPixelSizeChanged
        eventWindowMetalViewResized
        eventWindowMinimized
        eventWindowMaximized
        eventWindowRestored
        eventWindowMouseEnter
        eventWindowMouseLeave
        eventWindowFocusGained
        eventWindowFocusLost
        eventWindowCloseRequested
        eventWindowHitTest
        eventWindowICCProfChanged
        eventWindowDisplayChanged
        eventWindowDisplayScaleChanged
        eventWindowSafeAreaChanged
        eventWindowOccluded
        eventWindowEnterFullscreen
        eventWindowLeaveFullscreen
        eventWindowDestroyed
        eventWindowHdrStateChanged

        eventKeyDown = 0x300
        eventKeyUp
        eventTextEditing
        eventTextInput
        eventKeymapChanged
        eventKeyboardAdded
        eventKeyboardRemoved
        eventTextEditingCandidates

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

        eventPenProximityIn = 0x1300
        eventPenProximityOut
        eventPenDown
        eventPenUp
        eventPenButtonDown
        eventPenButtonUp
        eventPenMotion
        eventPenAxis

        eventCameraDeviceAdded = 0x1400
        eventCameraDeviceRemoved
        eventCameraDeviceApproved
        eventCameraDeviceDenied

        eventRenderTargetsReset = 0x2000
        eventRenderDeviceReset

        eventPollSentinel = 0x7F00
        eventUser         = 0x8000
        eventLast         = 0xFFFF # To allow custom events

    EventState* {.size: sizeof(cint).} = enum
        stateReleased
        statePressed

    EventAction* {.size: sizeof(cint).} = enum
        actionAdd
        actionPeek
        actionGet

type
    Timestamp*   = distinct uint64
    CustomEvent* = distinct uint32

    EventFilter* = proc(user_data: pointer; event: ptr Event): bool

    CommonEvent* = object
        kind*: uint32
        _    : uint32
        time*: Timestamp

    DisplayEvent* = object
        kind*      : EventKind
        _          : uint32
        time*      : Timestamp
        display_id*: DisplayId
        data1*     : int32
        data2*     : int32

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
        down*  : bool
        repeat*: bool

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
        x*, y*   : cfloat
        x_rel*   : cfloat
        y_rel*   : cfloat

    MouseButtonEvent* = object
        kind*    : EventKind
        pad1     : uint32
        time*    : Timestamp
        win_id*  : WindowId
        mouse_id*: MouseId
        btn*     : MouseButton
        down*    : bool
        clicks*  : uint8
        pad2     : uint8
        x*, y*   : cfloat

    MouseWheelEvent* = object
        kind*    : EventKind
        _        : uint32
        time*    : Timestamp
        win_id*  : WindowId
        mouse_id*: MouseId
        x*, y*   : cfloat
        dir*     : MouseWheelDirection
        mouse_x* : cfloat
        mouse_y* : cfloat

    QuitEvent* = object
        kind*: EventKind
        _    : uint32
        time*: Timestamp

    Event* {.union.} = object
        kind*     : EventKind
        common*   : CommonEvent
        display*  : DisplayEvent
        win*      : WindowEvent
        kb_dev*   : KeyboardDeviceEvent
        kb*       : KeyboardEvent
        edit*     : TextEditingEvent
        # edit_candidate*: TextEditingCandidateEvent
        text*     : TextInputEvent
        mouse_dev*: MouseDeviceEvent
        motion*   : MouseMotionEvent
        btn*      : MouseButtonEvent
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

using
    event : ptr Event
    events: ptr UncheckedArray[Event]
    filter: EventFilter

{.push dynlib: SdlLib.}
proc sdl_pump_events*()                                                                          {.importc: "SDL_PumpEvents"        .}
proc sdl_peep_events*(events; event_count: cint; action: EventAction; min, max: EventKind): cint {.importc: "SDL_PeepEvents"        .}
proc sdl_has_event*(kind: EventKind): bool                                                       {.importc: "SDL_HasEvent"          .}
proc sdl_has_events*(min, max: EventKind): bool                                                  {.importc: "SDL_HasEvents"         .}
proc sdl_flush_event*(kind: EventKind)                                                           {.importc: "SDL_FlushEvent"        .}
proc sdl_flush_events*(min, max: EventKind)                                                      {.importc: "SDL_FlushEvents"       .}
proc sdl_poll_event*(event): bool                                                                {.importc: "SDL_PollEvent"         .}
proc sdl_wait_event*(event): bool                                                                {.importc: "SDL_WaitEvent"         .}
proc sdl_wait_event_timeout*(event; timeout_ms: int32): bool                                     {.importc: "SDL_WaitEventTimeout"  .}
proc sdl_push_event*(event): bool                                                                {.importc: "SDL_PushEvent"         .}
proc sdl_set_event_filter*(filter; user_data: pointer)                                           {.importc: "SDL_SetEventFilter"    .}
proc sdl_get_event_filter*(filter: ptr EventFilter; user_data: ptr pointer): bool                {.importc: "SDL_GetEventFilter"    .}
proc sdl_add_event_watch*(filter; user_data: pointer): bool                                      {.importc: "SDL_AddEventWatch"     .}
proc sdl_remove_event_watch*(filter; user_data: pointer)                                         {.importc: "SDL_RemoveEventWatch"  .}
proc sdl_filter_events*(filter; user_data: pointer)                                              {.importc: "SDL_FilterEvents"      .}
proc sdl_set_event_enabled*(kind: EventKind; enabled: bool)                                      {.importc: "SDL_SetEventEnabled"   .}
proc sdl_event_enabled*(kind: EventKind): bool                                                   {.importc: "SDL_EventEnabled"      .}
proc sdl_register_events*(count: cint): EventKind                                                {.importc: "SDL_RegisterEvents"    .}
proc sdl_get_window_from_event*(event): ptr Window                                               {.importc: "SDL_GetWindowFromEvent".}
{.pop.}

{.push inline.}

iterator events*(): Event =
    var event: Event
    while sdl_poll_event event.addr:
        yield event

proc register_event*(): CustomEvent =
    CustomEvent sdl_register_events 1

proc push_event*(event: Event): bool = sdl_push_event(event.addr)

#~ Mouse ~#

proc mouse_state*(): tuple[btns: MouseButtonMask; x, y: float32] =
    result.btns = sdl_get_mouse_state(result.x.addr, result.y.addr)

{.pop.} # inline

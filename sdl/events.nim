import common, keyboard
from video   import Window, WindowID, DisplayID
from surface import Surface

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
    Timestamp*   = distinct uint64
    KeyboardId*  = distinct uint32
    MouseId*     = distinct uint32
    Cursor*      = distinct pointer
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
        down*  : cbool
        repeat*: cbool

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
        button*  : MouseButton
        state*   : uint8
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

using
    event : ptr Event
    events: ptr UncheckedArray[Event]
    filter: EventFilter
{.push dynlib: SdlLib.}
proc sdl_pump_events*()                                                                          {.importc: "SDL_PumpEvents"        .}
proc sdl_peep_events*(events; event_count: cint; action: EventAction; min, max: EventKind): cint {.importc: "SDL_PeepEvents"        .}
proc sdl_has_event*(kind: EventKind): cbool                                                      {.importc: "SDL_HasEvent"          .}
proc sdl_has_events*(min, max: EventKind): cbool                                                 {.importc: "SDL_HasEvents"         .}
proc sdl_flush_event*(kind: EventKind)                                                           {.importc: "SDL_FlushEvent"        .}
proc sdl_flush_events*(min, max: EventKind)                                                      {.importc: "SDL_FlushEvents"       .}
proc sdl_poll_event*(event): cbool                                                               {.importc: "SDL_PollEvent"         .}
proc sdl_wait_event*(event): cbool                                                               {.importc: "SDL_WaitEvent"         .}
proc sdl_wait_event_timeout*(event; timeout_ms: int32): cbool                                    {.importc: "SDL_WaitEventTimeout"  .}
proc sdl_push_event*(event): cbool                                                               {.importc: "SDL_PushEvent"         .}
proc sdl_set_event_filter*(filter; user_data: pointer)                                           {.importc: "SDL_SetEventFilter"    .}
proc sdl_get_event_filter*(filter: ptr EventFilter; user_data: ptr pointer): cbool               {.importc: "SDL_GetEventFilter"    .}
proc sdl_add_event_watch*(filter; user_data: pointer): cbool                                     {.importc: "SDL_AddEventWatch"     .}
proc sdl_remove_event_watch*(filter; user_data: pointer)                                         {.importc: "SDL_RemoveEventWatch"  .}
proc sdl_filter_events*(filter; user_data: pointer)                                              {.importc: "SDL_FilterEvents"      .}
proc sdl_set_event_enabled*(kind: EventKind; enabled: bool)                                      {.importc: "SDL_SetEventEnabled"   .}
proc sdl_event_enabled*(kind: EventKind): cbool                                                  {.importc: "SDL_EventEnabled"      .}
proc sdl_register_events*(count: cint): EventKind                                                {.importc: "SDL_RegisterEvents"    .}
proc sdl_get_window_from_event*(event): ptr Window                                               {.importc: "SDL_GetWindowFromEvent".}

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

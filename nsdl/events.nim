import common, keyboard, video

export keyboard

type
    Timestamp*   = distinct uint64
    KeyboardID*  = distinct uint32
    MouseID*     = distinct uint32
    MouseButton* = distinct uint8

    EventKind* {.size: sizeof(uint32).} = enum
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

    EventState* = enum
        esReleased = 0
        esPressed  = 1

    MouseWheelDirection* {.size: sizeof(int32).} = enum
        mwdNormal
        mwdFlipped

    EventAction* {.size: sizeof(int32).} = enum
        eaAddEvent
        eaPeekEvent
        eaGetEvent

type
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

proc get_event(event: ptr Event): bool {.importc: "SDL_PollEvent", dynlib: SDLPath.}
iterator get_events*(): Event =
    var event: Event
    while get_event(addr event):
        yield event

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
# extern DECLSPEC int SDLCALL SDL_PushEvent(SDL_Event *event);
# typedef int (SDLCALL *SDL_EventFilter)(void *userdata, SDL_Event *event);
# extern DECLSPEC void SDLCALL SDL_SetEventFilter(SDL_EventFilter filter, void *userdata);
# extern DECLSPEC SDL_bool SDLCALL SDL_GetEventFilter(SDL_EventFilter *filter, void **userdata);
# extern DECLSPEC int SDLCALL SDL_AddEventWatch(SDL_EventFilter filter, void *userdata);
# extern DECLSPEC void SDLCALL SDL_DelEventWatch(SDL_EventFilter filter, void *userdata);
# extern DECLSPEC void SDLCALL SDL_FilterEvents(SDL_EventFilter filter, void *userdata);
# extern DECLSPEC void SDLCALL SDL_SetEventEnabled(Uint32 type, SDL_bool enabled);
# extern DECLSPEC SDL_bool SDLCALL SDL_EventEnabled(Uint32 type);
# extern DECLSPEC Uint32 SDLCALL SDL_RegisterEvents(int numevents);
# extern DECLSPEC void * SDLCALL SDL_AllocateEventMemory(size_t size);

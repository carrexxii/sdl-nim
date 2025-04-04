import common, power
from properties import PropertyId
from sensor     import SensorKind

const
    JoystickAxisMax* = 32767'i32
    JoystickAxisMin* = -32768'i32

    HatCentred*   = 0x00'u16
    HatUp*        = 0x01'u16
    HatRight*     = 0x02'u16
    HatDown*      = 0x04'u16
    HatLeft*      = 0x08'u16
    HatRightUp*   = HatRight or HatUp
    HatRightDown* = HatRight or HatDown
    HatLeftUp*    = HatLeft  or HatUp
    HatLeftDown*  = HatLeft  or HatDown

type
    JoystickKind* {.size: sizeof(uint16).} = enum
        Unknown
        Gamepad
        Wheel
        ArcadeStick
        FlightStick
        DancePad
        Guitar
        DrumKit
        ArcadePad
        Throttle

    JoystickConnectionState* {.size: sizeof(cint).} = enum
        Invalid = -1
        Unknown
        Wired
        Wireless

type
    Joystick*   = distinct pointer
    JoystickId* = distinct uint32

    VirtualJoystickTouchpadDesc* = object
        finger_cnt*: uint16
        _          : array[3, uint16]

    VirtualJoystickSensorDesc* = object
        kind*: SensorKind
        rate*: float32

    VirtualJoystickDesc* = object
        version*     : uint32
        kind*        : JoystickKind
        pad1         : uint16
        vendor_id*   : uint16
        product_id*  : uint16
        axis_cnt*    : uint16
        btn_cnt*     : uint16
        ball_cnt*    : uint16
        hat_cnt*     : uint16
        touchpad_cnt*: uint16
        sensor_cnt*  : uint16
        pad2         : uint16
        btn_mask*    : uint32
        axis_mask*   : uint32

        name*     : cstring
        touchpads*: ptr UncheckedArray[VirtualJoystickTouchpadDesc]
        sensors*  : ptr UncheckedArray[VirtualJoystickSensorDesc]

        user_data*          : pointer
        update*             : proc(user_data: pointer) {.cdecl.}
        set_player_index*   : proc(user_data: pointer; player_idx: cint) {.cdecl.}
        rumble*             : proc(user_data: pointer; low_freq_rumble, high_freq_rumble: uint16): bool {.cdecl.}
        rumble_triggers*    : proc(user_data: pointer; left_rumble, right_rumble: uint16): bool {.cdecl.}
        set_led*            : proc(user_data: pointer; r, g, b: uint8): bool {.cdecl.}
        send_effect*        : proc(user_data: pointer; data: pointer; sz: cint): bool {.cdecl.}
        set_sensors_enabled*: proc(user_data: pointer; enabled: bool): bool {.cdecl.}
        cleanup*            : proc(user_data: pointer) {.cdecl.}

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_LockJoysticks*()
proc SDL_UnlockJoysticks*()
proc SDL_HasJoystick*(): bool
proc SDL_GetJoysticks(cnt: ptr cint): ptr UncheckedArray[JoystickId]
proc SDL_GetJoystickNameForID*(id: JoystickId): cstring
proc SDL_GetJoystickPathForID*(id: JoystickId): cstring
proc SDL_GetJoystickPlayerIndexForID*(id: JoystickId): cint
proc SDL_GetJoystickGUIDForID*(id: JoystickId): Guid
proc SDL_GetJoystickVendorForID*(id: JoystickId): uint16
proc SDL_GetJoystickProductForID*(id: JoystickId): uint16
proc SDL_GetJoystickProductVersionForID*(id: JoystickId): uint16
proc SDL_GetJoystickTypeForID*(id: JoystickId): JoystickKind
proc SDL_OpenJoystick*(id: JoystickId): Joystick
proc SDL_GetJoystickFromID*(id: JoystickId): Joystick
proc SDL_GetJoystickFromPlayerIndex*(player_idx: cint): Joystick
proc SDL_AttachVirtualJoystick*(desc: ptr VirtualJoystickDesc): JoystickId
proc SDL_DetachVirtualJoystick*(id: JoystickId): bool
proc SDL_IsJoystickVirtual*(id: JoystickId): bool
proc SDL_SetJoystickVirtualAxis*(joystick: Joystick; axis: cint; val: int16): bool
proc SDL_SetJoystickVirtualBall*(joystick: Joystick; ball: cint; xrel, yrel: int16): bool
proc SDL_SetJoystickVirtualButton*(joystick: Joystick; btn: cint; down: bool): bool
proc SDL_SetJoystickVirtualHat*(joystick: Joystick; hat: cint; val: uint8): bool
proc SDL_SetJoystickVirtualTouchpad*(joystick: Joystick; touchpad, finger: cint; down: bool; x, y, pressure: cfloat): bool
proc SDL_SendJoystickVirtualSensorData*(joystick: Joystick; kind: SensorKind; sensor_timestamp: uint64; data: ptr cfloat; val_cnt: cint): bool
proc SDL_GetJoystickProperties*(joystick: Joystick): PropertyId
proc SDL_GetJoystickName*(joystick: Joystick): cstring
proc SDL_GetJoystickPath*(joystick: Joystick): cstring
proc SDL_GetJoystickPlayerIndex*(joystick: Joystick): cint
proc SDL_SetJoystickPlayerIndex*(joystick: Joystick; player_idx: cint): bool
proc SDL_GetJoystickGUID*(joystick: Joystick): Guid
proc SDL_GetJoystickVendor*(joystick: Joystick): uint16
proc SDL_GetJoystickProduct*(joystick: Joystick): uint16
proc SDL_GetJoystickProductVersion*(joystick: Joystick): uint16
proc SDL_GetJoystickFirmwareVersion*(joystick: Joystick): uint16
proc SDL_GetJoystickSerial*(joystick: Joystick): cstring
proc SDL_GetJoystickType*(joystick: Joystick): JoystickKind
proc SDL_GetJoystickGUIDInfo*(guid: Guid; vendor, product, version, crc16: ptr uint16)
proc SDL_JoystickConnected*(joystick: Joystick): bool
proc SDL_GetJoystickID*(joystick: Joystick): JoystickId
proc SDL_GetNumJoystickAxes*(joystick: Joystick): cint
proc SDL_GetNumJoystickBalls*(joystick: Joystick): cint
proc SDL_GetNumJoystickHats*(joystick: Joystick): cint
proc SDL_GetNumJoystickButtons*(joystick: Joystick): cint
proc SDL_SetJoystickEventsEnabled*(enabled: bool)
proc SDL_JoystickEventsEnabled*(): bool
proc SDL_UpdateJoysticks*()
proc SDL_GetJoystickAxis*(joystick: Joystick; axis: cint): int16
proc SDL_GetJoystickAxisInitialState*(joystick: Joystick; axis: cint; state: ptr int16): bool
proc SDL_GetJoystickBall*(joystick: Joystick; ball: cint; dx, dy: ptr cint): bool
proc SDL_GetJoystickHat*(joystick: Joystick; hat: cint): uint8
proc SDL_GetJoystickButton*(joystick: Joystick; btn: cint): bool
proc SDL_RumbleJoystick*(joystick: Joystick; low_frequency_rumble, high_frequency_rumble: uint16; duration_ms: uint32): bool
proc SDL_RumbleJoystickTriggers*(joystick: Joystick; left_rumble, right_rumble: uint16; duration_ms: uint32): bool
proc SDL_SetJoystickLED*(joystick: Joystick; r, g, b: uint8): bool
proc SDL_SendJoystickEffect*(joystick: Joystick; data: pointer; sz: cint): bool
proc SDL_CloseJoystick*(joystick: Joystick)
proc SDL_GetJoystickConnectionState*(joystick: Joystick): JoystickConnectionState
proc SDL_GetJoystickPowerInfo*(joystick: Joystick; percent: ptr cint): PowerState
{.pop.}

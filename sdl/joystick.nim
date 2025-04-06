import common, power
from properties import PropertyId
from sensor     import SensorKind

const
    JoystickAxisMax* = 32767'i32
    JoystickAxisMin* = -32768'i32

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

    HatState* {.size: sizeof(uint8).} = enum
        Centred   = 0x00
        Up        = 0x01
        Right     = 0x02
        Down      = 0x04
        Left      = 0x08
        RightUp   = 0x02 or 0x01 # Right | Up
        RightDown = 0x02 or 0x04 # Right | Down
        LeftUp    = 0x08 or 0x01 # Left  | Up
        LeftDown  = 0x08 or 0x04 # Left  | Down

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
        version*     : uint32 = uint32 sizeof(VirtualJoystickDesc) # via `SDL_INIT_INTERFACE`
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

    JoystickButton* = distinct cint
    JoystickAxis*   = distinct cint
    JoystickBall*   = distinct cint
    JoystickHat*    = distinct cint

proc `$`*(id: JoystickId): string      {.borrow.}
proc `$`*(btn: JoystickButton): string {.borrow.}
proc `$`*(axis: JoystickAxis): string  {.borrow.}
proc `$`*(ball: JoystickBall): string  {.borrow.}
proc `$`*(hat: JoystickHat): string    {.borrow.}

converter `Joystick -> bool`*(joystick: Joystick): bool = nil != pointer joystick
converter `JoystickId -> bool`*(id: JoystickId): bool   = 0 != int id

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
proc SDL_SetJoystickVirtualAxis*(joystick: Joystick; axis: JoystickAxis; val: int16): bool
proc SDL_SetJoystickVirtualBall*(joystick: Joystick; ball: JoystickBall; xrel, yrel: int16): bool
proc SDL_SetJoystickVirtualButton*(joystick: Joystick; btn: JoystickButton; down: bool): bool
proc SDL_SetJoystickVirtualHat*(joystick: Joystick; hat: JoystickHat; val: HatState): bool
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
proc SDL_GetJoystickAxis*(joystick: Joystick; axis: JoystickAxis): int16
proc SDL_GetJoystickAxisInitialState*(joystick: Joystick; axis: JoystickAxis; state: ptr int16): bool
proc SDL_GetJoystickBall*(joystick: Joystick; ball: JoystickBall; dx, dy: ptr cint): bool
proc SDL_GetJoystickHat*(joystick: Joystick; hat: JoystickHat): HatState
proc SDL_GetJoystickButton*(joystick: Joystick; btn: JoystickButton): bool
proc SDL_RumbleJoystick*(joystick: Joystick; low_freq_rumble, high_freq_rumble: uint16; duration_ms: uint32): bool
proc SDL_RumbleJoystickTriggers*(joystick: Joystick; left_rumble, right_rumble: uint16; duration_ms: uint32): bool
proc SDL_SetJoystickLED*(joystick: Joystick; r, g, b: uint8): bool
proc SDL_SendJoystickEffect*(joystick: Joystick; data: pointer; sz: cint): bool
proc SDL_CloseJoystick*(joystick: Joystick)
proc SDL_GetJoystickConnectionState*(joystick: Joystick): JoystickConnectionState
proc SDL_GetJoystickPowerInfo*(joystick: Joystick; percent: ptr cint): PowerState
{.pop.}

{.push inline.}

proc lock_joysticks*()      = SDL_LockJoysticks()
proc unlock_joysticks*()    = SDL_UnlockJoysticks()
proc have_joystick*(): bool = SDL_HasJoystick()

proc get_joysticks*(): seq[JoystickId] =
    var cnt: cint
    let sticks = SDL_GetJoysticks(cnt.addr)
    if sticks != nil:
        result = new_seq_of_cap[JoystickId](cnt)
        for i in 0..<cnt:
            result.add sticks[i]
        sdl_free sticks

proc index*(id: JoystickId): int32 =
    result = int32 SDL_GetJoystickPlayerIndexForID(id)
    sdl_assert result != -1, &"Failed to get index for joystick with id '{id}'"

proc name*(id: JoystickId): string       = $SDL_GetJoystickNameForID(id)
proc path*(id: JoystickId): string       = $SDL_GetJoystickPathForID(id)
proc guid*(id: JoystickId): Guid         = SDL_GetJoystickGUIDForID id
proc vendor*(id: JoystickId): uint16     = SDL_GetJoystickVendorForID id
proc product*(id: JoystickId): uint16    = SDL_GetJoystickProductForID id
proc version*(id: JoystickId): uint16    = SDL_GetJoystickProductVersionForID id
proc kind*(id: JoystickId): JoystickKind = SDL_GetJoystickTypeForID id

proc open*(id: JoystickId): Joystick =
    result = SDL_OpenJoystick(id)
    sdl_assert result, &"Failed to open joystick with id '{id}'"

proc joystick*(id: JoystickId): Joystick =
    result = SDL_GetJoystickFromID(id)
    sdl_assert result, &"Failed to get joystick from id '{id}'"

proc joystick*(player_idx: int32): Joystick =
    result = SDL_GetJoystickFromPlayerIndex(cint player_idx)
    sdl_assert result, &"Failed to get joystick from player index '{player_idx}'"

proc attach*(desc: VirtualJoystickDesc): JoystickId =
    result = SDL_AttachVirtualJoystick(desc.addr)
    sdl_assert result, &"Failed to attach virtual joystick (desc: {desc})"

proc detach*(id: JoystickId): bool {.discardable.} =
    ## `id` Should be a `JoystickId` previously returned from `attach`
    result = SDL_DetachVirtualJoystick(id)
    sdl_assert result, &"Failed to detach virtual joystick from joystick with id '{id}'"

proc is_virtual*(id: JoystickId): bool = SDL_IsJoystickVirtual id

proc set_virtual_axis*(joystick: Joystick; axis: JoystickAxis; val: int16): bool {.discardable.} =
    result = SDL_SetJoystickVirtualAxis(joystick, axis, val)
    sdl_assert result, &"Failed to set virtual axis for joystick (axis: {axis}; val: {val})"
proc `virtual_axis=`*(joystick: Joystick; val: tuple[axis: JoystickAxis; val: int16]) =
    set_virtual_axis joystick, val.axis, val.val

proc set_virtual_ball*(joystick: Joystick; ball: JoystickBall; xrel, yrel: int16): bool {.discardable.} =
    result = SDL_SetJoystickVirtualBall(joystick, ball, xrel, yrel)
    sdl_assert result, &"Failed to set virtual ball for joystick (ball: {ball}; xrel: {xrel}; yrel: {yrel})"
proc `virtual_ball=`*(joystick: Joystick; val: tuple[ball: JoystickBall; xrel, yrel: int16]) =
    set_virtual_ball joystick, val.ball, val.xrel, val.yrel

proc set_virtual_button*(joystick: Joystick; btn: JoystickButton; down: bool): bool {.discardable.} =
    result = SDL_SetJoystickVirtualButton(joystick, btn, down)
    sdl_assert result, &"Failed to set virtual button for joystick (button: {btn}; down: {down})"
proc `virtual_button=`*(joystick: Joystick; val: tuple[btn: JoystickButton; down: bool]) =
    set_virtual_button joystick, val.btn, val.down

proc set_virtual_hat*(joystick: Joystick; hat: JoystickHat; val: HatState): bool {.discardable.} =
    result = SDL_SetJoystickVirtualHat(joystick, hat, val)
    sdl_assert result, &"Failed to set virtual hat for joystick (hat: {hat}; val: {val})"
proc `virtual_hat=`*(joystick: Joystick; val: tuple[hat: JoystickHat; val: HatState]) =
    set_virtual_hat joystick, val.hat, val.val

proc set_virtual_touchpad*(joystick: Joystick; touchpad, finger: distinct SomeInteger; down: bool; x, y, pressure: distinct SomeFloat): bool {.discardable.} =
    result = SDL_SetJoystickVirtualTouchpad(joystick, cint touchpad, cint finger, down, cfloat x, cfloat y, cfloat pressure)
    sdl_assert result, &"Failed to set virtual touchpad for joystick (touchpad: {touchpad}; finger: {finger}; down: {down}; x: {x}; y: {y}; pressure: {pressure})"
proc `virtual_touchpad=`*(joystick: Joystick; val: tuple[touchpad, finger: distinct SomeInteger; down: bool; x, y, pressure: distinct SomeFloat]) =
    set_virtual_touchpad joystick, val.touchpad, val.finger, val.down, val.x, val.y, val.pressure

proc set_player_index*(joystick: Joystick; idx: SomeInteger): bool {.discardable.} =
    result = SDL_SetJoystickPlayerIndex(joystick, cint idx)
    sdl_assert result, &"Failed to set joystick player index to '{idx}'"
proc `player_index=`*(joystick: Joystick; idx: SomeInteger) = set_player_index joystick, idx

proc send_sensor_data*(joystick: Joystick; kind: SensorKind; timestamp: uint64; data: openArray[float32]): bool {.discardable.} =
    result = SDL_SendJoystickVirtualSensorData(joystick, kind, timestamp, data[0].addr, cint data.len)
    sdl_assert result, &"Failed to send sensor data to joystick (kind: {kind}; timestamp: {timestamp}; data: {data})"

proc properties*(joystick: Joystick): PropertyId   = SDL_GetJoystickProperties joystick
proc name*(joystick: Joystick): string             = $SDL_GetJoystickName(joystick)
proc path*(joystick: Joystick): string             = $SDL_GetJoystickPath(joystick)
proc player_index*(joystick: Joystick): int32      = int32 SDL_GetJoystickPlayerIndex joystick
proc guid*(joystick: Joystick): Guid               = SDL_GetJoystickGUID joystick
proc vendor*(joystick: Joystick): uint16           = SDL_GetJoystickVendor joystick
proc product*(joystick: Joystick): uint16          = SDL_GetJoystickProduct joystick
proc product_version*(joystick: Joystick): uint16  = SDL_GetJoystickProductVersion joystick
proc firmware_version*(joystick: Joystick): uint16 = SDL_GetJoystickFirmwareVersion joystick
proc serial*(joystick: Joystick): string           = $SDL_GetJoystickSerial(joystick)
proc kind*(joystick: Joystick): JoystickKind       = SDL_GetJoystickType joystick
proc is_connected*(joystick: Joystick): bool       = SDL_JoystickConnected joystick
proc id*(joystick: Joystick): JoystickId           = SDL_GetJoystickID joystick
proc axis_count*(joystick: Joystick): int32        = int32 SDL_GetNumJoystickBalls joystick
proc balls_count*(joystick: Joystick): int32       = int32 SDL_GetNumJoystickHats joystick
proc hats_count*(joystick: Joystick): int32        = int32 SDL_GetNumJoystickButtons joystick
proc joystick_events_enabled*(): bool              = SDL_JoystickEventsEnabled()
proc guid_info*(guid: Guid): tuple[vendor, product, version, crc16: uint16] =
    SDL_GetJoystickGUIDInfo guid, result.vendor.addr, result.product.addr, result.version.addr, result.crc16.addr

proc set_joystick_events_enabled*(enabled: bool) =
    SDL_SetJoystickEventsEnabled enabled

proc update_joysticks*() =
    SDL_UpdateJoysticks()

proc joystick_axis*(joystick: Joystick; axis: JoystickAxis): int16 =
    SDL_GetJoystickAxis joystick, axis

proc joystick_axis_intial_state*(joystick: Joystick; axis: JoystickAxis): int16 =
    let success = SDL_GetJoystickAxisInitialState(joystick, axis, result.addr)
    sdl_assert success, &"Failed to get initisal state for joystick axis '{axis}'"

proc delta*(joystick: Joystick; ball: JoystickBall): tuple[dx, dy: int32] =
    let success = SDL_GetJoystickBall(joystick, ball, result.dx.addr, result.dy.addr)
    sdl_assert success, &"Failed to get joystick ball deltas for ball '{ball}'"

proc state*(joystick: Joystick; hat: JoystickHat): HatState =
    SDL_GetJoystickHat joystick, hat

proc pressed*(joystick: Joystick; btn: JoystickButton): bool =
    SDL_GetJoystickButton joystick, btn

proc rumble*(joystick: Joystick; low_freq_rumble, high_freq_rumble: uint16; duration_ms: SomeInteger): bool {.discardable.} =
    result = SDL_RumbleJoystick(joystick, low_freq_rumble, high_freq_rumble, uint32 duration_ms)
    sdl_assert result, &"Failed to rumble joystick (low frequency rumble: {low_freq_rumble}; high frequency rumble: {high_freq_rumble}; duration: {duration_ms}ms)"

proc rumble_triggers*(joystick: Joystick; left_rumble, right_rumble: uint16; duration_ms: SomeInteger): bool {.discardable.} =
    result = SDL_RumbleJoystickTriggers(joystick, left_rumble, right_rumble, uint32 duration_ms)
    sdl_assert result, &"Failed to rumble joystick triggers (left rumble: {left_rumble}; right rumble: {right_rumble}; duration: {duration_ms}ms)"

proc set_led*(joystick: Joystick; r, g, b: uint8): bool {.discardable.} =
    SDL_SetJoystickLED(joystick, r, g, b)
proc `led=`*(joystick: Joystick; rgb: tuple[r, g, b: uint8]) = set_led joystick, rgb.r, rgb.g, rgb.b

proc send_effect*[T](joystick: Joystick; data: openArray[T]): bool {.discardable.} =
    result = SDL_SendJoystickEffect(joystick, data[0].addr, cint (data.len * sizeof T))
    sdl_assert result, "Failed to send effect to joystick"

proc close*(joystick: Joystick) =
    SDL_CloseJoystick joystick

proc connection_state*(joystick: Joystick): JoystickConnectionState =
    SDL_GetJoystickConnectionState joystick

proc power_info*(joystick: Joystick): tuple[state: PowerState; percent: int32] =
    result.state = SDL_GetJoystickPowerInfo(joystick, result.percent.addr)

{.pop.}

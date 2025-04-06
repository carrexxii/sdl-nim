import common, joystick, power, sensor
from properties import PropertyId
from iostream   import IoStream
from timer      import Milliseconds

type
    GamepadKind* {.size: sizeof(cint).} = enum
        Unknown
        Standard
        XBox360
        XBoxOne
        PS3
        PS4
        PS5
        NintendoSwitchPro
        NintendoSwitchJoyconLeft
        NintendoSwitchJoyconRight
        NintendoSwitchJoyconPair

    GamepadButton* {.size: sizeof(cint).} = enum
        Invalid = -1
        South
        East
        West
        North
        Back
        Guide
        Start
        LeftStick
        RightStick
        LeftShoulder
        RightShoulder
        DPadUp
        DPadDown
        DPadLeft
        DPadRight
        Misc1
        RightPaddle1
        LeftPaddle1
        RightPaddle2
        LeftPaddle2
        Touchpad
        Misc2
        Misc3
        Misc4
        Misc5
        Misc6

    GamepadButtonLabel* {.size: sizeof(cint).} = enum
        Unknown
        A
        B
        X
        Y
        Cross
        Circle
        Square
        Triangle

    GamepadAxis* {.size: sizeof(cint).} = enum
        Invalid = -1
        LeftX
        LeftY
        RightX
        RightY
        LeftTrigger
        RightTrigger

    GamepadBindingKind* {.size: sizeof(cint).} = enum
        None
        Button
        Axis
        Hat

type
    Gamepad*   = distinct pointer
    GamepadId* = distinct JoystickId

    GamepadBinding* = object
        input_kind* : GamepadBindingKind
        input*      : GamepadBindingInput
        output_kind*: GamepadBindingKind
        output*     : GamepadBindingOutput

    GamepadBindingInput* {.union.} = object
        btn* : cint
        axis*: AxisInput
        hat* : HatInput

    AxisInput* = object
        axis*    : int32
        axis_min*: int32
        axis_max*: int32

    HatInput* = object
        hat*     : int32
        hat_mask*: int32

    GamepadBindingOutput* {.union.} = object
        btn* : GamepadButton
        axis*: AxisOutput

    AxisOutput* = object
        axis*    : GamepadAxis
        axis_min*: int32
        axis_max*: int32

converter `Gamepad -> bool`*(gamepad: Gamepad): bool = nil != pointer gamepad
converter `GamepadId -> bool`*(id: GamepadId): bool  = 0 != int id

proc `$`*(id: GamepadId): string {.borrow.}

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_AddGamepadMapping*(mapping: cstring): cint
proc SDL_AddGamepadMappingsFromIO*(stream: IoStream; close_io: bool): cint
proc SDL_AddGamepadMappingsFromFile*(file: cstring): cint
proc SDL_ReloadGamepadMappings*(): bool
proc SDL_GetGamepadMappings*(cnt: ptr cint): cstringArray
proc SDL_GetGamepadMappingForGUID*(guid: Guid): cstring
proc SDL_GetGamepadMapping*(gamepad: Gamepad): cstring
proc SDL_SetGamepadMapping*(id: GamepadId; mapping: cstring): bool

proc SDL_HasGamepad*(): bool
proc SDL_GetGamepads*(cnt: ptr cint): ptr UncheckedArray[GamepadId]
proc SDL_IsGamepad*(id: JoystickId): bool
proc SDL_GetGamepadNameForID*(id: GamepadId): cstring
proc SDL_GetGamepadPathForID*(id: GamepadId): cstring
proc SDL_GetGamepadPlayerIndexForID*(id: GamepadId): cint
proc SDL_GetGamepadGUIDForID*(id: GamepadId): Guid
proc SDL_GetGamepadVendorForID*(id: GamepadId): uint16
proc SDL_GetGamepadProductForID*(id: GamepadId): uint16
proc SDL_GetGamepadProductVersionForID*(id: GamepadId): uint16
proc SDL_GetGamepadTypeForID*(id: GamepadId): GamepadKind
proc SDL_GetRealGamepadTypeForID*(id: GamepadId): GamepadKind
proc SDL_GetGamepadMappingForID*(id: GamepadId): cstring
proc SDL_OpenGamepad*(id: GamepadId): Gamepad
proc SDL_GetGamepadFromID*(id: GamepadId): Gamepad
proc SDL_GetGamepadFromPlayerIndex*(player_idx: cint): Gamepad
proc SDL_GetGamepadProperties*(gamepad: Gamepad): PropertyId
proc SDL_GetGamepadID*(gamepad: Gamepad): GamepadId
proc SDL_GetGamepadName*(gamepad: Gamepad): cstring
proc SDL_GetGamepadPath*(gamepad: Gamepad): cstring
proc SDL_GetGamepadType*(gamepad: Gamepad): GamepadKind
proc SDL_GetRealGamepadType*(gamepad: Gamepad): GamepadKind
proc SDL_GetGamepadPlayerIndex*(gamepad: Gamepad): cint
proc SDL_SetGamepadPlayerIndex*(gamepad: Gamepad; player_idx: cint): bool
proc SDL_GetGamepadVendor*(gamepad: Gamepad): uint16
proc SDL_GetGamepadProduct*(gamepad: Gamepad): uint16
proc SDL_GetGamepadProductVersion*(gamepad: Gamepad): uint16
proc SDL_GetGamepadFirmwareVersion*(gamepad: Gamepad): uint16
proc SDL_GetGamepadSerial*(gamepad: Gamepad): cstring
proc SDL_GetGamepadSteamHandle*(gamepad: Gamepad): uint64
proc SDL_GetGamepadConnectionState*(gamepad: Gamepad): JoystickConnectionState
proc SDL_GetGamepadPowerInfo*(gamepad: Gamepad; percent: ptr cint): PowerState
proc SDL_GamepadConnected*(gamepad: Gamepad): bool
proc SDL_GetGamepadJoystick*(gamepad: Gamepad): Joystick
proc SDL_SetGamepadEventsEnabled*(enabled: bool)
proc SDL_GamepadEventsEnabled*(): bool
proc SDL_GetGamepadBindings*(gamepad: Gamepad; cnt: ptr cint): ptr UncheckedArray[ptr GamepadBinding]
proc SDL_UpdateGamepads*()
proc SDL_GetGamepadTypeFromString*(str: cstring): GamepadKind
proc SDL_GetGamepadStringForType*(kind: GamepadKind): cstring
proc SDL_GetGamepadAxisFromString*(str: cstring): GamepadAxis
proc SDL_GetGamepadStringForAxis*(axis: GamepadAxis): cstring
proc SDL_GamepadHasAxis*(gamepad: Gamepad; axis: GamepadAxis): bool
proc SDL_GetGamepadAxis*(gamepad: Gamepad; axis: GamepadAxis): int16
proc SDL_GetGamepadButtonFromString*(str: cstring): GamepadButton
proc SDL_GetGamepadStringForButton*(btn: GamepadButton): cstring
proc SDL_GamepadHasButton*(gamepad: Gamepad; btn: GamepadButton): bool
proc SDL_GetGamepadButton*(gamepad: Gamepad; btn: GamepadButton): bool
proc SDL_GetGamepadButtonLabelForType*(kind: GamepadKind; btn: GamepadButton): GamepadButtonLabel
proc SDL_GetGamepadButtonLabel*(gamepad: Gamepad; btn: GamepadButton): GamepadButtonLabel
proc SDL_GetNumGamepadTouchpads*(gamepad: Gamepad): cint
proc SDL_GetNumGamepadTouchpadFingers*(gamepad: Gamepad; touchpad: cint): cint
proc SDL_GetGamepadTouchpadFinger*(gamepad: Gamepad; touchpad, finger: cint; down: ptr bool; x, y, pressure: ptr cfloat): bool
proc SDL_GamepadHasSensor*(gamepad: Gamepad; kind: SensorKind): bool
proc SDL_SetGamepadSensorEnabled*(gamepad: Gamepad; kind: SensorKind; enabled: bool): bool
proc SDL_GamepadSensorEnabled*(gamepad: Gamepad; kind: SensorKind): bool
proc SDL_GetGamepadSensorDataRate*(gamepad: Gamepad; kind: SensorKind): cfloat
proc SDL_GetGamepadSensorData*(gamepad: Gamepad; kind: SensorKind; data: ptr cfloat; val_cnt: cint): bool
proc SDL_RumbleGamepad*(gamepad: Gamepad; low_frequency_rumble, high_frequency_rumble: uint16; duration_ms: uint32): bool
proc SDL_RumbleGamepadTriggers*(gamepad: Gamepad; left_rumble, right_rumble: uint16; duration_ms: uint32): bool
proc SDL_SetGamepadLED*(gamepad: Gamepad; r, g, b: uint8): bool
proc SDL_SendGamepadEffect*(gamepad: Gamepad; data: pointer; sz: cint): bool
proc SDL_CloseGamepad*(gamepad: Gamepad)
proc SDL_GetGamepadAppleSFSymbolsNameForButton*(gamepad: Gamepad; btn: GamepadButton): cstring
proc SDL_GetGamepadAppleSFSymbolsNameForAxis*(gamepad: Gamepad; axis: GamepadAxis): cstring
{.pop.}

# TODO: mappings

{.push inline.}

proc have_gamepad*(): bool = SDL_HasGamepad()

proc get_gamepads*(): seq[GamepadId] =
    var cnt: cint
    let gps = SDL_GetGamepads(cnt.addr)
    if gps != nil:
        result = new_seq_of_cap[GamepadId](cnt)
        for i in 0..<cnt:
            result.add gps[i]
        sdl_free gps

proc is_gamepad*(id: JoystickId): bool      = SDL_IsGamepad id
proc name*(id: GamepadId): string           = $SDL_GetGamepadNameForID(id)
proc path*(id: GamepadId): string           = $SDL_GetGamepadPathForID(id)
proc player_index*(id: GamepadId): int32    = int32 SDL_GetGamepadPlayerIndexForID id
proc guid*(id: GamepadId): Guid             = SDL_GetGamepadGUIDForID id
proc vendor*(id: GamepadId): uint16         = SDL_GetGamepadVendorForID id
proc product*(id: GamepadId): uint16        = SDL_GetGamepadProductForID id
proc version*(id: GamepadId): uint16        = SDL_GetGamepadProductVersionForID id
proc kind*(id: GamepadId): GamepadKind      = SDL_GetGamepadTypeForID id
proc real_kind*(id: GamepadId): GamepadKind = SDL_GetRealGamepadTypeForID id
proc mapping*(id: GamepadId): string        = $SDL_GetGamepadMappingForID(id)

proc open*(id: GamepadId): Gamepad =
    result = SDL_OpenGamepad(id)
    sdl_assert result, &"Failed to open gamepad with id '{id}'"

proc gamepad*(id: GamepadId): Gamepad =
    result = SDL_GetGamepadFromID(id)
    sdl_assert result, &"Failed to get gamepad from id '{id}'"

proc gamepad*(player_idx: SomeInteger): Gamepad =
    result = SDL_GetGamepadFromPlayerIndex(cint player_idx)
    sdl_assert result, &"Failed to get gamepad from player index '{player_idx}'"

proc properties*(gamepad: Gamepad): PropertyId   = SDL_GetGamepadProperties gamepad
proc id*(gamepad: Gamepad): GamepadId            = SDL_GetGamepadID gamepad
proc name*(gamepad: Gamepad): string             = $SDL_GetGamepadName(gamepad)
proc path*(gamepad: Gamepad): string             = $SDL_GetGamepadPath(gamepad)
proc kind*(gamepad: Gamepad): GamepadKind        = SDL_GetGamepadType gamepad
proc real_kind*(gamepad: Gamepad): GamepadKind   = SDL_GetRealGamepadType gamepad
proc player_index*(gamepad: Gamepad): int32      = int32 SDL_GetGamepadPlayerIndex gamepad
proc vendor*(gamepad: Gamepad): uint16           = SDL_GetGamepadVendor gamepad
proc product*(gamepad: Gamepad): uint16          = SDL_GetGamepadProduct gamepad
proc product_version*(gamepad: Gamepad): uint16  = SDL_GetGamepadProductVersion gamepad
proc firmware_version*(gamepad: Gamepad): uint16 = SDL_GetGamepadFirmwareVersion gamepad
proc serial*(gamepad: Gamepad): string           = $SDL_GetGamepadSerial(gamepad)
proc steam_handle*(gamepad: Gamepad): uint64     = SDL_GetGamepadSteamHandle gamepad
proc is_connected*(gamepad: Gamepad): bool       = SDL_GamepadConnected gamepad
proc joystick*(gamepad: Gamepad): Joystick       = SDL_GetGamepadJoystick gamepad
proc gamepad_events_enabled*(): bool             = SDL_GamepadEventsEnabled()
proc kind*(str: string): GamepadKind             = SDL_GetGamepadTypeFromString cstring str
proc `$`*(kind: GamepadKind): string             = $SDL_GetGamepadStringForType(kind)
proc axis*(str: string): GamepadAxis             = SDL_GetGamepadAxisFromString cstring str
proc `$`*(axis: GamepadAxis): string             = $SDL_GetGamepadStringForAxis(axis)
proc button*(str: string): GamepadButton         = SDL_GetGamepadButtonFromString cstring str
proc `$`*(btn: GamepadButton): string            = $SDL_GetGamepadStringForButton(btn)
proc connection_state*(gamepad: Gamepad): JoystickConnectionState      = SDL_GetGamepadConnectionState gamepad
proc has_axis*(gamepad: Gamepad; axis: GamepadAxis): bool              = SDL_GamepadHasAxis gamepad, axis
proc axis*(gamepad: Gamepad; axis: GamepadAxis): int16                 = SDL_GetGamepadAxis gamepad, axis
proc has_button*(gamepad: Gamepad; btn: GamepadButton): bool           = SDL_GamepadHasButton gamepad, btn
proc button*(gamepad: Gamepad; btn: GamepadButton): bool               = SDL_GetGamepadButton gamepad, btn
proc label*(kind: GamepadKind; btn: GamepadButton): GamepadButtonLabel = SDL_GetGamepadButtonLabelForType kind, btn
proc label*(gamepad: Gamepad; btn: GamepadButton): GamepadButtonLabel  = SDL_GetGamepadButtonLabel gamepad, btn
proc power_info*(gamepad: Gamepad): tuple[state: PowerState; percent: int32] =
    result.state = SDL_GetGamepadPowerInfo(gamepad, result.percent.addr)

proc set_player_index*(gamepad: Gamepad; player_idx: SomeInteger): bool {.discardable.} =
    result = SDL_SetGamepadPlayerIndex(gamepad, cint player_idx)
    sdl_assert result, &"Failed to set gamepad player index to '{player_idx}'"
proc `player_index=`*(gamepad: Gamepad; player_idx: SomeInteger) = set_player_index gamepad, player_idx

proc gamepad_events_enabled*(enabled: bool) =
    SDL_SetGamepadEventsEnabled enabled

proc update_gamepads*() =
    SDL_UpdateGamepads()

proc touchpad_count*(gamepad: Gamepad): int32 =
    int32 SDL_GetNumGamepadTouchpads gamepad

proc touchpad_finger_count*(gamepad: Gamepad; touchpad: SomeInteger): int32 =
    int32 SDL_GetNumGamepadTouchpadFingers(gamepad, cint touchpad)

proc touchpad_finger*(gamepad: Gamepad; touchpad, finger: distinct SomeInteger): tuple[down: bool; x, y, pressure: float32] =
    let success = SDL_GetGamepadTouchpadFinger(gamepad, cint touchpad, cint finger, result.down.addr,
                                               result.x.addr, result.y.adr, result.pressure.addr)
    sdl_assert success, &"Failed to get touchpad finger data for gamepad (touchpad: {touchpad}; finger: {finger})"

proc has_sensor*(gamepad: Gamepad; kind: SensorKind): bool   = SDL_GamepadHasSensor gamepad, kind
proc is_enabled*(gamepad: Gamepad; kind: SensorKind): bool   = SDL_GamepadSensorEnabled gamepad, kind
proc data_rate*(gamepad: Gamepad; kind: SensorKind): float32 = float32 SDL_GetGamepadSensorDataRate(gamepad, kind)

proc enable_sensor*(gamepad: Gamepad; kind: SensorKind): bool {.discardable.} =
    result = SDL_SetGamepadSensorEnabled(gamepad, kind, true)
    sdl_assert result, &"Failed to enable sensor '{kind}'"
proc disable_sensor*(gamepad: Gamepad; kind: SensorKind): bool {.discardable.} =
    result = SDL_SetGamepadSensorEnabled(gamepad, kind, false)
    sdl_assert result, &"Failed to disable sensor '{kind}'"

proc sensor_data*[N: static[int]](gamepad: Gamepad; kind: SensorKind): array[N, float32] =
    let success = SDL_GetGamepadSensorData(gamepad, kind, result[0].addr, N)
    sdl_assert success, &"Failed to get sensor data of {N} values"

proc rumble*(gamepad: Gamepad; low_freq, high_freq: uint16; duration: Milliseconds): bool {.discardable.} =
    result = SDL_RumbleGamepad(gamepad, low_freq, high_freq, uint32 duration)
    sdl_assert result, &"Failed to rumble gamepad (low frequency: {low_freq}; high frequency: {high_freq}; duration: {uint32 duration}ms)"

proc rumble_triggers*(gamepad: Gamepad; left, right: uint16; duration: Milliseconds): bool {.discardable.} =
    result = SDL_RumbleGamepadTriggers(gamepad, left, right, uint32 duration)
    sdl_assert result, &"Failed to rumble gamepad (left rumble: {left}; right rumble: {right}; duration: {uint32 duration}ms)"

proc set_led*(gamepad: Gamepad; r, g, b: uint8): bool {.discardable.} =
    result = SDL_SetGamepadLED(gamepad, r, g, b)
    sdl_assert result, &"Failed to set LED colour to ({r}, {g}, {b})"
proc set_led*(gamepad: Gamepad; rgb: array[3, uint8]): bool {.discardable.} =
    set_led gamepad, rgb[0], rgb[1], rgb[2]
proc `led=`*(gamepad: Gamepad; rgb: array[3, uint8]) = set_led gamepad, rgb[0], rgb[1], rgb[2]

proc send_effect*[T](gamepad: Gamepad; data: openArray[T]): bool {.discardable.} =
    let sz = cint (data.len * sizeof T)
    result = SDL_SendGamepadEffect(gamepad, data[0].addr, sz)
    sdl_assert result, &"Failed to send effect to gamepad ({data})"

proc close*(gamepad: Gamepad) =
    SDL_CloseGamepad gamepad

{.pop.}

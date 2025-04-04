import common, joystick, power, sensor
from properties import PropertyId
from iostream   import IoStream

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
    Gamepad* = distinct pointer

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

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_AddGamepadMapping*(mapping: cstring): cint
proc SDL_AddGamepadMappingsFromIO*(stream: IoStream; close_io: bool): cint
proc SDL_AddGamepadMappingsFromFile*(file: cstring): cint
proc SDL_ReloadGamepadMappings*(): bool
proc SDL_GetGamepadMappings*(cnt: ptr cint): cstringArray
proc SDL_GetGamepadMappingForGUID*(guid: Guid): cstring
proc SDL_GetGamepadMapping*(gamepad: Gamepad): cstring
proc SDL_SetGamepadMapping*(id: JoystickId; mapping: cstring): bool
proc SDL_HasGamepad*(): bool
proc SDL_GetGamepads*(cnt: ptr cint): ptr UncheckedArray[JoystickId]
proc SDL_IsGamepad*(id: JoystickId): bool
proc SDL_GetGamepadNameForID*(id: JoystickId): cstring
proc SDL_GetGamepadPathForID*(id: JoystickId): cstring
proc SDL_GetGamepadPlayerIndexForID*(id: JoystickId): cint
proc SDL_GetGamepadGUIDForID*(id: JoystickId): Guid
proc SDL_GetGamepadVendorForID*(id: JoystickId): uint16
proc SDL_GetGamepadProductForID*(id: JoystickId): uint16
proc SDL_GetGamepadProductVersionForID*(id: JoystickId): uint16
proc SDL_GetGamepadTypeForID*(id: JoystickId): GamepadKind
proc SDL_GetRealGamepadTypeForID*(id: JoystickId): GamepadKind
proc SDL_GetGamepadMappingForID*(id: JoystickId): cstring
proc SDL_OpenGamepad*(id: JoystickId): Gamepad
proc SDL_GetGamepadFromID*(id: JoystickId): Gamepad
proc SDL_GetGamepadFromPlayerIndex*(player_idx: cint): Gamepad
proc SDL_GetGamepadProperties*(gamepad: Gamepad): PropertyId
proc SDL_GetGamepadID*(gamepad: Gamepad): JoystickId
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

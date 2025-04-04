import common

type PowerState* = enum
    Error = -1
    Unknown
    OnBattery
    NoBattery
    Charging
    Charged

proc SDL_GetPowerInfo*(secs, percent: ptr cint): PowerState {.importc, cdecl, dynlib: SdlLib.}

proc power_info*(): tuple[state: PowerState; secs, percent: int32] {.inline.} =
    result.state = SDL_GetPowerInfo(result.secs.addr, result.percent.addr)

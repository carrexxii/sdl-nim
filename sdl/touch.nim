import common
from mouse import MouseId

type
    TouchDeviceKind* {.size: sizeof(cint).} = enum
        Invalid = -1
        Direct
        IndirectAbsolute
        IndirectRelative

type
    TouchId*  = distinct uint64
    FingerId* = distinct uint64

    Finger* = object
        id*      : FingerId
        x*, y*   : float32
        pressure*: float32

const TouchMouseId* = cast[MouseId](-1)
const MouseTouchId* = cast[TouchId](-1)

proc `$`*(id: TouchId): string  {.borrow.}
proc `$`*(id: FingerId): string {.borrow.}

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_GetTouchDevices*(cnt: ptr cint): ptr UncheckedArray[TouchId]
proc SDL_GetTouchDeviceName*(id: TouchId): cstring
proc SDL_GetTouchDeviceType*(id: TouchId): TouchDeviceKind
proc SDL_GetTouchFingers*(id: TouchId; cnt: ptr cint): ptr UncheckedArray[ptr Finger]
{.pop.}

{.push inline.}

proc get_touch_devices*(): seq[TouchId] =
    var cnt: cint
    let devs = SDL_GetTouchDevices(cnt.addr)
    sdl_assert devs != nil, "Failed to get touch devices"

    if devs != nil:
        result = new_seq_of_cap[TouchId](cnt)
        for i in 0..<cnt:
            result.add devs[i]
        sdl_free devs

proc name*(id: TouchId): string          = $SDL_GetTouchDeviceName(id)
proc kind*(id: TouchId): TouchDeviceKind = SDL_GetTouchDeviceType id

# TODO: this is probably better without the extra allocation and a special wrapper type for the array
proc get_touch_fingers*(id: TouchId): seq[Finger] =
    var cnt: cint
    let fingers = SDL_GetTouchFingers(id, cnt.addr)
    sdl_assert fingers != nil, &"Failed to get touch fingers for id '{id}'"

    if fingers != nil:
        result = new_seq_of_cap[Finger](cnt)
        for i in 0..<cnt:
            result.add fingers[i][]
        sdl_free fingers

{.pop.}

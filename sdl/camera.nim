import std/options, common
from properties import PropertiesId
from surface    import Surface
from pixels     import PixelFormat, Colourspace

type
    CameraPosition* {.size: sizeof(cint).} = enum
        Unknown
        FrontFacing
        BackFacing

    CameraPermission* = enum
        Denied   = -1
        Waiting  = 0
        Approved = 1

type
    CameraId* = distinct uint32
    Camera*   = distinct pointer
    CameraSpec* = object
        fmt*        : PixelFormat
        colourspace*: Colourspace
        w*, h*      : int32
        fps_numer*  : int32
        fps_denom*  : int32

proc `$`*(id: CameraId): string {.borrow.}

converter `CameraId -> bool`*(id: CameraId): bool = 0 != int id
converter `Camera -> bool`*(cam: Camera): bool    = nil != pointer cam

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_GetNumCameraDrivers*(): cint
proc SDL_GetCameraDriver*(idx: cint): cstring
proc SDL_GetCurrentCameraDriver*(): cstring
proc SDL_GetCameras*(cnt: ptr cint): ptr UncheckedArray[CameraId]
proc SDL_GetCameraSupportedFormats(inst_id: CameraId; cnt: ptr cint): ptr UncheckedArray[ptr CameraSpec]
proc SDL_GetCameraName*(inst_id: CameraId): cstring
proc SDL_GetCameraPosition*(inst_id: CameraId): CameraPosition
proc SDL_OpenCamera*(inst_id: CameraId; spec: ptr CameraSpec): Camera
proc SDL_GetCameraPermissionState*(cam: Camera): CameraPermission
proc SDL_GetCameraID*(cam: Camera): CameraId
proc SDL_GetCameraProperties*(cam: Camera): PropertiesId
proc SDL_GetCameraFormat*(cam: Camera; spec: ptr CameraSpec): bool
proc SDL_AcquireCameraFrame*(cam: Camera; timestamp_ns: ptr uint64): Surface
proc SDL_ReleaseCameraFrame*(cam: Camera; frame: Surface)
proc SDL_CloseCamera*(cam: Camera)
{.pop.}

{.push inline.}

proc camera_driver_count*(): int32 =
    int32 SDL_GetNumCameraDrivers()

proc camera_driver_name*(idx: SomeInteger): string =
    let name = SDL_GetCameraDriver(int32 idx)
    sdl_assert name != nil, &"Failed to get camera driver name for camera index '{idx}'"
    $name

proc current_camera_driver*(): string =
    let name = SDL_GetCurrentCameraDriver()
    sdl_assert name != nil, &"Failed to get current camera driver name"
    $name

proc cameras*(): seq[CameraId] =
    ## This copies and then frees SDL's memory
    var cnt: cint
    let cams = SDL_GetCameras(cnt.addr)
    sdl_assert cams != nil, "Failed to get a list of available cameras"

    result = new_seq_of_cap[CameraId](cnt)
    for i in 0..<cnt:
        result.add cams[i]
    sdl_free cams

proc supported_formats*(id: CameraId): seq[CameraSpec] =
    ## This copies and then frees SDL's memory
    var cnt: cint
    let fmts = SDL_GetCameraSupportedFormats(id, cnt.addr)
    sdl_assert fmts != nil, &"Failed to get supported formats for camera (id: {id})"

    result = new_seq_of_cap[CameraSpec](cnt)
    for i in 0..<cnt:
        result.add fmts[i][]
    sdl_free fmts

proc name*(id: CameraId): string =
    let name = SDL_GetCameraName(id)
    sdl_assert name != nil, &"Failed to get name for camera (id: {id})"
    $name

proc position*(id: CameraId): CameraPosition =
    SDL_GetCameraPosition id
proc pos*(id: CameraId): CameraPosition = position id

proc open*(id: CameraId; spec: Option[CameraSpec]): Camera =
    let pspec = if spec.is_some: (get spec).addr else: nil
    result = SDL_OpenCamera(id, pspec)
    sdl_assert result, &"Failed to open camera (id: {id}; spec: {spec})"

proc close*(cam: Camera) =
    SDL_CloseCamera cam

proc permission_state*(cam: Camera; close_if_denied = true): CameraPermission =
    result = SDL_GetCameraPermissionState(cam)
    if result == Denied and close_if_denied:
        close cam

proc id*(cam: Camera): CameraId =
    result = SDL_GetCameraID(cam)
    sdl_assert result, "Failed to get id for camera"

proc properties*(cam: Camera): PropertiesId =
    SDL_GetCameraProperties cam
proc props*(cam: Camera): PropertiesId = properties cam

proc format*(cam: Camera): CameraSpec =
    let success = SDL_GetCameraFormat(cam, result.addr)
    sdl_assert success, "Failed to get format spec for camera"
proc fmt*(cam: Camera): CameraSpec = format cam

proc acquire_frame*(cam: Camera): tuple[time: uint64; frame: Surface] =
    ## Returns a frame if one is available.
    ## Check frame via `if result.frame: ...` to make sure it is a frame
    result.frame = SDL_AcquireCameraFrame(cam, result.time.addr)

proc release_frame*(cam: Camera; frame: Surface | tuple[time: uint64; frame: Surface]) =
    when frame is Surface:
        SDL_ReleaseCameraFrame cam, frame
    else:
        SDL_ReleaseCameraFrame cam, frame.frame

{.pop.}

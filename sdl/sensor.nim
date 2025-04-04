import common
from properties import PropertyId

const StandardGravity* = 9.80665'f32

type SensorKind* = enum
    Invalid = -1
    Unknown
    Accel
    Gyro
    AccelL
    GyroL
    AccelR
    GyroR

type
    Sensor*   = distinct pointer
    SensorId* = distinct uint32

proc `$`*(id: SensorId): string {.borrow.}

converter `Sensor -> bool`*(sensor: Sensor): bool = nil != pointer sensor

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_GetSensors*(cnt: ptr cint): ptr UncheckedArray[SensorId]
proc SDL_GetSensorNameForID*(id: SensorId): cstring
proc SDL_GetSensorTypeForID*(id: SensorId): SensorKind
proc SDL_GetSensorNonPortableTypeForID*(id: SensorId): cint
proc SDL_OpenSensor*(id: SensorId): Sensor
proc SDL_GetSensorFromID*(id: SensorId): Sensor
proc SDL_GetSensorProperties*(sensor: Sensor): PropertyId
proc SDL_GetSensorName*(sensor: Sensor): cstring
proc SDL_GetSensorType*(sensor: Sensor): SensorKind
proc SDL_GetSensorNonPortableType*(sensor: Sensor): cint
proc SDL_GetSensorID*(sensor: Sensor): SensorId
proc SDL_GetSensorData*(sensor: Sensor; data: ptr cfloat; val_cnt: cint): bool
proc SDL_CloseSensor*(sensor: Sensor)
proc SDL_UpdateSensors*()
{.pop.}

proc get_sensors*(): seq[SensorId] =
    var cnt: cint
    let sensors = SDL_GetSensors(cnt.addr)
    sdl_assert sensors != nil, "Failed to get a list of sensors"

    if sensors != nil:
        result = new_seq_of_cap[SensorId](cnt)
        for i in 0..<cnt:
            result.add sensors[i]
        sdl_free sensors

proc name*(id: SensorId): string     = $SDL_GetSensorNameForID(id)
proc kind*(id: SensorId): SensorKind = SDL_GetSensorTypeForID id

proc open*(id: SensorId): Sensor =
    result = SDL_OpenSensor(id)
    sdl_assert result, &"Failed to open sensor (id: {id})"

proc sensor*(id: SEnsorId): Sensor =
    result = SDL_GetSensorFromID(id)
    sdl_assert result, &"Failed to get sensor (if: {id})"

proc properties*(sensor: Sensor): PropertyId = SDL_GetSensorProperties sensor
proc name*(sensor: Sensor): string           = $SDL_GetSensorName(sensor)
proc kind*(sensor: Sensor): SensorKind       = SDL_GetSensorType sensor
proc id*(sensor: Sensor): SensorId           = SDL_GetSensorID sensor

proc data*[N: static[int]](sensor: Sensor): array[N, float32] =
    let success = SDL_GetSensorData(sensor, result[0].addr, N)
    sdl_assert success, "Failed to get sensor data"

proc close*(sensor: Sensor) =
    SDL_CloseSensor sensor

proc update_sensors*() =
    SDL_UpdateSensors()

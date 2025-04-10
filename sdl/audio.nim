import std/options, common
from properties import PropertiesId
from iostream   import IoStream

const
    MaskBitSize*   = 0xFF'u32
    MaskFloat*     = uint32 (1 shl 8)
    MaskBigEndian* = uint32 (1 shl 12)
    MaskSigned*    = uint32 (1 shl 15)

type Format* {.size: sizeof(cint).} = enum
    Unknown = 0x0000
    U8      = 0x0008
    S8      = 0x8008
    S16Le   = 0x8010
    S32Le   = 0x8020
    F32Le   = 0x8120
    S16Be   = 0x9010
    S32Be   = 0x9020
    F32Be   = 0x9120

type
    DeviceId* = distinct uint32
    Stream*   = distinct pointer

    Spec* = object
        fmt*     : Format
        channels*: int32
        freq*    : int32

    PostmixCallback* = proc(user_data: pointer; spec: ptr Spec; buf: ptr float32; buf_len: int32)       {.cdecl.}
    StreamCallback*  = proc(user_data: pointer; stream: Stream; additional_amount, total_amount: int32) {.cdecl.}

proc SDL_DestroyAudioStream*(stream: Stream) {.importc, cdecl, dynlib: SdlLib.}
proc `=destroy`*(stream: Stream) =
    SDL_DestroyAudioStream stream

func `$`*(id: DeviceId): string      {.borrow.}
func `==`*(id1, id2: DeviceId): bool {.borrow.}

converter `DeviceId -> bool`*(id: DeviceId): bool = id != DeviceId 0
converter `Stream -> bool`*(stream: Stream): bool = nil != pointer stream

func format*(signed, big_endian, flt, size: uint16): Format =
    Format ((signed     shl 15) or
            (big_endian shl 12) or
            (flt        shl 8 ) or
            (size and MaskBitSize))

const
    DefaultPlayback*  = DeviceId 0xFFFF_FFFF'u32
    DefaultRecording* = DeviceId 0xFFFF_FFFE'u32

{.push inline.}
func bit_size*(x: Format): uint32  = (uint32 x) and MaskBitSize
func byte_size*(x: Format): uint32 = bit_size(x) div 8

func is_float*(x: Format): bool         = bool ((uint32 x) and MaskFloat)
func is_big_endian*(x: Format): bool    = bool ((uint32 x) and MaskFloat)
func is_little_endian*(x: Format): bool = not is_big_endian x
func is_signed*(x: Format): bool        = bool ((uint32 x) and MaskSigned)
func is_int*(x: Format): bool           = not is_float x
func is_unsigned*(x: Format): bool      = not is_signed x

func frame_size*(x: Spec | ptr Spec): int32 = byte_size(x.fmt) * x.channels
{.pop.}

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_GetNumAudioDrivers*(): cint
proc SDL_GetAudioDriver*(idx: cint): cstring
proc SDL_GetCurrentAudioDriver*(): cstring
proc SDL_GetAudioPlaybackDevices*(cnt: ptr cint): ptr UncheckedArray[DeviceId]
proc SDL_GetAudioRecordingDevices*(cnt: ptr cint): ptr UncheckedArray[DeviceId]
proc SDL_GetAudioDeviceName*(id: DeviceId): cstring
proc SDL_GetAudioDeviceFormat*(id: DeviceId; spec: ptr Spec; sample_frames: ptr cint): bool
proc SDL_GetAudioDeviceChannelMap*(id: DeviceId; cnt: ptr cint): ptr UncheckedArray[cint]

proc SDL_OpenAudioDevice*(id: DeviceId; spec: ptr Spec): DeviceId
proc SDL_IsAudioDevicePhysical*(id: DeviceId): bool
proc SDL_IsAudioDevicePlayback*(id: DeviceId): bool
proc SDL_PauseAudioDevice*(id: DeviceId): bool
proc SDL_ResumeAudioDevice*(id: DeviceId): bool
proc SDL_AudioDevicePaused*(id: DeviceId): bool
proc SDL_GetAudioDeviceGain*(id: DeviceId): cfloat
proc SDL_SetAudioDeviceGain*(id: DeviceId; gain: cfloat): bool
proc SDL_CloseAudioDevice*(id: DeviceId)

proc SDL_BindAudioStreams*(id: DeviceId; streams: ptr Stream; stream_cnt: cint): bool
proc SDL_BindAudioStream*(id: DeviceId; stream: Stream): bool
proc SDL_UnbindAudioStreams*(streams: ptr Stream; stream_cnt: cint)
proc SDL_UnbindAudioStream*(stream: Stream)
proc SDL_GetAudioStreamDevice*(stream: Stream): DeviceId
proc SDL_CreateAudioStream*(src_spec, dst_spec: ptr Spec): Stream
proc SDL_GetAudioStreamProperties*(stream: Stream): PropertiesId
proc SDL_GetAudioStreamFormat*(stream: Stream; src_spec, dst_spec: ptr Spec): bool
proc SDL_SetAudioStreamFormat*(stream: Stream; src_spec, dst_spec: ptr Spec): bool
proc SDL_GetAudioStreamFrequencyRatio*(stream: Stream): cfloat
proc SDL_SetAudioStreamFrequencyRatio*(stream: Stream; ratio: cfloat): bool
proc SDL_GetAudioStreamGain*(stream: Stream): cfloat
proc SDL_SetAudioStreamGain*(stream: Stream; gain: cfloat): bool
proc SDL_GetAudioStreamInputChannelMap*(stream: Stream; cnt: ptr cint): ptr cint
proc SDL_GetAudioStreamOutputChannelMap*(stream: Stream; cnt: ptr cint): ptr cint
proc SDL_SetAudioStreamInputChannelMap*(stream: Stream; chmap: ptr cint; cnt: cint): bool
proc SDL_SetAudioStreamOutputChannelMap*(stream: Stream; chmap: ptr cint; cnt: cint): bool
proc SDL_PutAudioStreamData*(stream: Stream; buf: pointer; len: cint): bool
proc SDL_GetAudioStreamData*(stream: Stream; buf: pointer; len: cint): cint
proc SDL_GetAudioStreamAvailable*(stream: Stream): cint
proc SDL_GetAudioStreamQueued*(stream: Stream): cint
proc SDL_FlushAudioStream*(stream: Stream): bool
proc SDL_ClearAudioStream*(stream: Stream): bool
proc SDL_PauseAudioStreamDevice*(stream: Stream): bool
proc SDL_ResumeAudioStreamDevice*(stream: Stream): bool
proc SDL_AudioStreamDevicePaused*(stream: Stream): bool
proc SDL_LockAudioStream*(stream: Stream): bool
proc SDL_UnlockAudioStream*(stream: Stream): bool
proc SDL_SetAudioStreamGetCallback*(stream: Stream; cb: StreamCallback; user_data: pointer): bool
proc SDL_SetAudioStreamPutCallback*(stream: Stream; cb: StreamCallback; user_data: pointer): bool
proc SDL_OpenAudioDeviceStream*(id: DeviceId; spec: ptr Spec; cb: StreamCallback; user_data: pointer): Stream
proc SDL_SetAudioPostmixCallback*(id: DeviceId; cb: PostmixCallback; user_data: pointer): bool
proc SDL_LoadWAV_IO*(stream: IoStream; close_io: bool; spec: ptr Spec; audio_buf: ptr ptr uint8; audio_len: ptr uint32): bool
proc SDL_LoadWAV*(path: cstring; spec: ptr Spec; audio_buf: ptr ptr uint8; audio_len: ptr uint32): bool
proc SDL_MixAudio*(dst, src: ptr uint8; fmt: Format; len: uint32; volume: cfloat): bool
proc SDL_ConvertAudioSamples*(src_spec: ptr Spec; src_data: ptr uint8; src_len: cint; dst_spec: ptr Spec; dst_data: ptr ptr uint8; dst_len: ptr cint): bool
proc SDL_GetAudioFormatName*(fmt: Format): cstring
proc SDL_GetSilenceValueForFormat*(fmt: Format): cint
{.pop.}

# TODO: Channel maps
# TODO: wav loading

{.push inline.}

proc get_driver_count*(): int32            = int32 SDL_GetNumAudioDrivers()
proc get_driver_count*(idx: int32): string = $SDL_GetAudioDriver(cint idx)
proc get_current_driver*(): string         = $SDL_GetCurrentAudioDriver()

proc get_playback_devices*(): seq[DeviceId] =
    var cnt: cint
    let ids = SDL_GetAudioPlaybackDevices(cnt.addr)
    sdl_assert ids != nil, "Failed to get audio playback devices"

    result = new_seq_of_cap[DeviceId](cnt)
    for i in 0..<cnt:
        result.add ids[i]

proc get_recording_devices*(): seq[DeviceId] =
    var cnt: cint
    let ids = SDL_GetAudioRecordingDevices(cnt.addr)
    sdl_assert ids != nil, "Failed to get audio recording devices"

    result = new_seq_of_cap[DeviceId](cnt)
    for i in 0..<cnt:
        result.add ids[i]

proc name*(id: DeviceId): string = $SDL_GetAudioDeviceName(id)
proc format*(id: DeviceId): tuple[spec: Spec; buf_sz: int32] =
    ## `buf_sz` is returned as `-1` on error
    let success = SDL_GetAudioDeviceFormat(id, result.spec.addr, result.buf_sz.addr)
    sdl_assert success, &"Failed to get audio device format (id: {id})"
    if not success:
        result.buf_sz = -1

proc open*(id: DeviceId; spec: Option[Spec]): DeviceId {.discardable.} =
    let spec = if spec.is_some: (get spec).addr else: nil
    result = SDL_OpenAudioDevice(id, spec)
    sdl_assert result, &"Failed to open audio device (id: {id}; spec: {spec[]})"

proc is_physical*(id: DeviceId): bool = SDL_IsAudioDevicePhysical id
proc is_playback*(id: DeviceId): bool = SDL_IsAudioDevicePlayback id
proc is_paused*(id: DeviceId): bool   = SDL_AudioDevicePaused id

proc pause*(id: DeviceId): bool {.discardable.} =
    result = SDL_PauseAudioDevice(id)
    sdl_assert result, &"Failed to pause audio device (id: {id})"
proc resume*(id: DeviceId): bool {.discardable.} =
    result = SDL_ResumeAudioDevice(id)
    sdl_assert result, &"Failed to resume audio device (id: {id})"
proc gain*(id: DeviceId): float32 =
    ## Returns `-1.0f` on failure
    result = SDL_GetAudioDeviceGain(id)
    sdl_assert result != -1.0'f32, &"Failed to get audio device gain (id: {id})"

proc set_gain*(id: DeviceId; gain: SomeFloat): bool {.discardable.} =
    result = SDL_SetAudioDeviceGain(id, cfloat gain)
    sdl_assert result, &"Failed to set audio device gain to '{gain}' (id: {id})"

proc `gain=`*(id: DeviceId; gain: SomeFloat) = set_gain id, gain

proc close*(id: DeviceId) =
    SDL_CloseAudioDevice id

proc link*(id: DeviceId; streams: Stream | openArray[Stream]): bool {.discardable.} =
    when streams is Stream:
        result = SDL_BindAudioStream(id, streams)
    else:
        result = SDL_BindAudioStreams(id, streams[0].addr, cint streams.len)
    sdl_assert result, &"Failed to bind stream(s) to audio device (id: {id})"

proc unlink*(streams: Stream | openArray[Stream]) =
    when streams in Stream:
        SDL_UnbindAudioStream streams
    else:
        SDL_UnbindAudioStreams streams[0].addr, cint streams.len

proc create_stream*(src_spec, dst_spec: Spec): Stream =
    result = SDL_CreateAudioStream(src_spec.addr, dst_spec.addr)
    sdl_assert result, &"Failed to create stream (src_spec: {src_spec}; dst_spec: {dst_spec})"

proc device*(stream: Stream): DeviceId         = SDL_GetAudioStreamDevice stream
proc properties*(stream: Stream): PropertiesId = SDL_GetAudioStreamProperties stream
proc gain*(stream: Stream): float32            = float32 SDL_GetAudioStreamGain stream
proc is_pause*(stream: Stream): bool           = SDL_AudioStreamDevicePaused stream
proc name*(fmt: Format): string                = $SDL_GetAudioFormatName(fmt)
proc silence_value*(fmt: Format): int32        = int32 SDL_GetSilenceValueForFormat fmt

proc frequency_ratio*(stream: Stream): float32 =
    result = float32 SDL_GetAudioStreamFrequencyRatio(stream)
    sdl_assert result != 0.0'f32, "Failed to get frequency ratio for audio stream"

proc format*(stream: Stream): tuple[src, dst: Spec] =
    let success = SDL_GetAudioStreamFormat(stream, result.src.addr, result.dst.addr)
    sdl_assert success, "Failed to get audio stream format"

proc data*[T](stream: Stream; buf_sz = 1024 div sizeof T): seq[T] =
    result.set_len buf_sz
    let bytes = SDL_GetAudioStreamData(stream, result[0].addr, cint result.len)
    sdl_assert bytes != -1, &"Failed to get audio stream data (buffer size: {buf_sz})"
    if bytes != -1:
        result.set_len bytes

proc bytes_available*(stream: Stream): int32 =
    result = int32 SDL_GetAudioStreamAvailable(stream)
    sdl_assert result != -1, "Failed to get number of available bytes"

proc bytes_queued*(stream: Stream): int32 =
    result = int32 SDL_GetAudioStreamQueued(stream)
    sdl_assert result != -1, "Failed to get number of queued bytes"

proc set_format*(stream: Stream; src_spec, dst_spec: Spec): bool {.discardable.} =
    let success = SDL_SetAudioStreamFormat(stream, src_spec.addr, dst_spec.addr)
    sdl_assert success, &"Failed to set audio stream format to (src_spec: {src_spec}; dst_spec: {dst_spec})"
proc `format=`*(stream: Stream; src_spec, dst_spec: Spec): bool {.discardable.} = set_format stream, src_spec, dst_spec

proc set_frequency_ratio*(stream: Stream; ratio: SomeFloat): bool {.discardable.} =
    result = SDL_SetAudioStreamFrequencyRatio(stream, cfloat ratio)
    sdl_assert result, &"Failed to set frequency ratio for audio stream to '{ratio}'"
proc `frequency_ratio=`*(stream: Stream; ratio: SomeFloat) = set_frequency_ratio stream, ratio

proc set_gain*(stream: Stream; gain: SomeFloat): bool {.discardable.} =
    result = SDL_SetAudioStreamGain(stream, cfloat gain)
    sdl_assert result, &"Failed to set gain for audio stream to '{gain}'"
proc `gain=`*(stream: Stream; gain: SomeFloat) = set_gain stream, gain

proc set_get_callback*(stream: Stream; cb: StreamCallback; data: pointer = nil): bool {.discardable.} =
    result = SDL_SetAudioStreamGetCallback(stream, cb, data)
    sdl_assert result, "Failed to set 'get' callback for audio stream"
proc `get_callback=`*(stream: Stream; cb: StreamCallback; data: pointer = nil) = set_get_callback stream, cb, data

proc set_set_callback*(stream: Stream; cb: StreamCallback; data: pointer = nil): bool {.discardable.} =
    result = SDL_SetAudioStreamPutCallback(stream, cb, data)
    sdl_assert result, "Failed to set 'set' callback for audio stream"
proc `set_callback=`*(stream: Stream; cb: StreamCallback; data: pointer = nil) = set_set_callback stream, cb, data

proc set_postmix_callback*(id: DeviceId; cb: PostmixCallback; data: pointer = nil): bool {.discardable.} =
    result = SDL_SetAudioPostmixCallback(id, cb, data)
    sdl_assert result, "Failed to set postmix callback"
proc `postmix_callback=`*(id: DeviceId; cb: PostmixCallback; data: pointer = nil) = set_postmix_callback id, cb, data

proc put_data*[T](stream: Stream; data: openArray[T]): bool {.discardable.} =
    let sz = cint (data.len * sizeof T)
    result = SDL_PutAudioStreamData(stream, data[0].addr, sz)
    sdl_assert result, &"Failed to put data ({sz}B / {sz/1024:.2f}kB) into audio stream"

proc flush*(stream: Stream): bool {.discardable.} =
    result = SDL_FlushAudioStream(stream)
    sdl_assert result, "Failed to flush audio stream"

proc clear*(stream: Stream): bool {.discardable.} =
    result = SDL_ClearAudioStream(stream)
    sdl_assert result, "Failed to clear audio stream"

proc pause*(stream: Stream): bool {.discardable.} =
    result = SDL_PauseAudioStreamDevice(stream)
    sdl_assert result, "Failed to pause audio stream"

proc resume*(stream: Stream): bool {.discardable.} =
    result = SDL_ResumeAudioStreamDevice(stream)
    sdl_assert result, "Failed to resume audio stream"

proc lock*(stream: Stream): bool {.discardable.} =
    result = SDL_LockAudioStream(stream)
    sdl_assert result, "Failed to lock audio stream"

proc unlock*(stream: Stream): bool {.discardable.} =
    result = SDL_UnlockAudioStream(stream)
    sdl_assert result, "Failed to unlock audio stream"

proc open*(id: DeviceId; spec: Option[Spec]; cb: Option[StreamCallback]; data: pointer = nil): Stream =
    let spec = if spec.is_some: (get spec).addr else: nil
    let cb   = if cb.is_some  : get cb          else: nil
    result = SDL_OpenAudioDeviceStream(id, spec, cb, data)
    sdl_assert result, &"Failed to open stream for audio device (id: {id}; spec: {spec[]})"

proc mix*[T](dst, src: openArray[T]; fmt: Format; volume: SomeFloat; len: SomeInteger = min(dst.len, src.len)*sizeof T): bool {.discardable.} =
    result = SDL_MixAudio(dst[0].addr, src[0].addr, fmt, cint len, volume)
    sdl_assert result, &"Failed to mix audio (format: {fmt}; volume: {volume})"

proc convert*[T](src_spec: Spec; src_data: openArray[T]; dst_spec: Spec; dst_data: openArray[T]): bool {.discardable.} =
    result = SDL_ConvertAudioSamples(src_spec.addr, src_data[0].addr, cint src_data.len, dst_spec.addr, dst_data[0].addr, cint dst_data.len)
    sdl_assert result, &"Failed to convert audio samples (source spec: {src_spec}; destination spec: {dst_spec})"

{.pop.}

import common
from properties import PropertyId
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

    Spec* = distinct pointer
    SpecObj* = object
        fmt*     : Format
        channels*: int32
        freq*    : int32

    PostmixCallback* = proc(user_data: pointer; spec: Spec; buf: ptr float32; buf_len: int32)           {.cdecl.}
    StreamCallback*  = proc(user_data: pointer; stream: Stream; additional_amount, total_amount: int32) {.cdecl.}

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

func frame_size*(x: Spec | SpecObj): int32 = byte_size(x.fmt) * x.channels
{.pop.}

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_GetNumAudioDrivers*(): cint
proc SDL_GetAudioDriver*(idx: cint): cstring
proc SDL_GetCurrentAudioDriver*(): cstring
proc SDL_GetAudioPlaybackDevices*(cnt: ptr cint): ptr UncheckedArray[DeviceId]
proc SDL_GetAudioRecordingDevices*(cnt: ptr cint): ptr UncheckedArray[DeviceId]
proc SDL_GetAudioDeviceName*(id: DeviceId): cstring
proc SDL_GetAudioDeviceFormat*(id: DeviceId; spec: Spec; sample_frames: ptr cint): bool
proc SDL_GetAudioDeviceChannelMap*(id: DeviceId; cnt: ptr cint): ptr UncheckedArray[cint]
proc SDL_OpenAudioDevice*(id: DeviceId; spec: Spec): DeviceId
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
proc SDL_CreateAudioStream*(src_spec, dst_spec: Spec): Stream
proc SDL_GetAudioStreamProperties*(stream: Stream): PropertyId
proc SDL_GetAudioStreamFormat*(stream: Stream; src_spec, dst_spec: Spec): bool
proc SDL_SetAudioStreamFormat*(stream: Stream; src_spec, dst_spec: Spec): bool
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
proc SDL_DestroyAudioStream*(stream: Stream)
proc SDL_OpenAudioDeviceStream*(id: DeviceId; spec: Spec; cb: StreamCallback; user_data: pointer): Stream
proc SDL_SetAudioPostmixCallback*(id: DeviceId; cb: PostmixCallback; user_data: pointer): bool
proc SDL_LoadWAV_IO*(stream: IoStream; close_io: bool; spec: Spec; audio_buf: ptr ptr uint8; audio_len: ptr uint32): bool
proc SDL_LoadWAV*(path: cstring; spec: Spec; audio_buf: ptr ptr uint8; audio_len: ptr uint32): bool
proc SDL_MixAudio*(dst, src: ptr uint8; fmt: Format; len: uint32; volume: cfloat): bool
proc SDL_ConvertAudioSamples*(src_spec: Spec; src_data: ptr uint8; src_len: cint; dst_spec: Spec; dst_data: ptr ptr uint8; dst_len: ptr cint): bool
proc SDL_GetAudioFormatName*(fmt: Format): cstring
proc SDL_GetSilenceValueForFormat*(fmt: Format): cint
{.pop.}

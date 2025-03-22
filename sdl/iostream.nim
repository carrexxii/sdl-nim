import common, properties

type
    IoStatus* = enum
        isReady
        isError
        isEof
        isNotReady
        isReadOnly
        isWriteOnly

    IoWhence* = enum
        iwSeekSet
        iwSeekCur
        iwSeekEnd

type
    IoStream* = distinct pointer

    IoStreamInterface* = object
        version*: uint32
        size*   : proc(user_data: pointer): int64
        seek*   : proc(user_data: pointer; offset: int64; whence: IoWhence): int64
        read*   : proc(user_data: pointer; dst: pointer; sz: uint; status: ptr IoStatus): uint
        write*  : proc(user_data: pointer; dst: pointer; sz: uint; status: ptr IoStatus): uint
        flush*  : proc(user_data: pointer; status: ptr IoStatus): bool
        close*  : proc(user_data: pointer): bool

converter `IoStream -> bool`*(p: IoStream): bool = cast[pointer](p) != nil

{.push importc, dynlib: SdlLib.}
proc SDL_IOFromFile*(file, mode: cstring): IoStream
proc SDL_IOFromMem*(mem: pointer; sz: csize_t): IoStream
proc SDL_IOFromConstMem*(mem: pointer; sz: csize_t): IoStream
proc SDL_IOFromDynamicMem*(): IoStream

proc SDL_OpenIO*(iface: ptr IoStreamInterface; user_data: pointer): IoStream
proc SDL_CloseIO*(ctx: IoStream): bool
proc SDL_GetIOProperties*(ctx: IoStream): PropertyId
proc SDL_GetIOStatus*(ctx: IoStream): IoStatus
proc SDL_GetIOSize*(ctx: IoStream): int64
proc SDL_SeekIO*(ctx: IoStream; offset: int64; whence: IoWhence): int64
proc SDL_TellIO*(ctx: IoStream): int64
proc SDL_ReadIO*(ctx: IoStream; dst: pointer; sz: csize_t): csize_t
proc SDL_WriteIO*(ctx: IoStream; src: pointer; sz: csize_t): csize_t
proc SDL_FlushIO*(ctx: IoStream): bool
proc SDL_LoadFile_IO*(src: IoStream; data_sz: ptr csize_t; close_io: bool): pointer
proc SDL_LoadFile*(file: cstring; data_sz: ptr csize_t): pointer
proc SDL_SaveFile_IO*(src: IoStream; data: pointer; data_sz: csize_t; close_io: bool): bool
proc SDL_SaveFile*(file: cstring; data: pointer; data_sz: csize_t): bool
proc SDL_ReadU8*(src: IoStream; val: ptr uint8): bool
proc SDL_ReadS8*(src: IoStream; val: ptr int8): bool
proc SDL_ReadU16LE*(src: IoStream; val: ptr uint16): bool
proc SDL_ReadS16LE*(src: IoStream; val: ptr int16): bool
proc SDL_ReadU16BE*(src: IoStream; val: ptr uint16): bool
proc SDL_ReadS16BE*(src: IoStream; val: ptr int16): bool
proc SDL_ReadU32LE*(src: IoStream; val: ptr uint32): bool
proc SDL_ReadS32LE*(src: IoStream; val: ptr int32): bool
proc SDL_ReadU32BE*(src: IoStream; val: ptr uint32): bool
proc SDL_ReadS32BE*(src: IoStream; val: ptr int32): bool
proc SDL_ReadU64LE*(src: IoStream; val: ptr uint64): bool
proc SDL_ReadS64LE*(src: IoStream; val: ptr int64): bool
proc SDL_ReadU64BE*(src: IoStream; val: ptr uint64): bool
proc SDL_ReadS64BE*(src: IoStream; val: ptr int64): bool
proc SDL_WriteU8*(dst: IoStream; val: uint8): bool
proc SDL_WriteS8*(dst: IoStream; val: int8): bool
proc SDL_WriteU16LE*(dst: IoStream; val: uint16): bool
proc SDL_WriteS16LE*(dst: IoStream; val: int16): bool
proc SDL_WriteU16BE*(dst: IoStream; val: uint16): bool
proc SDL_WriteS16BE*(dst: IoStream; val: int16): bool
proc SDL_WriteU32LE*(dst: IoStream; val: uint32): bool
proc SDL_WriteS32LE*(dst: IoStream; val: int32): bool
proc SDL_WriteU32BE*(dst: IoStream; val: uint32): bool
proc SDL_WriteS32BE*(dst: IoStream; val: int32): bool
proc SDL_WriteU64LE*(dst: IoStream; val: uint64): bool
proc SDL_WriteS64LE*(dst: IoStream; val: int64): bool
proc SDL_WriteU64BE*(dst: IoStream; val: uint64): bool
proc SDL_WriteS64BE*(dst: IoStream; val: int64): bool
{.pop.}

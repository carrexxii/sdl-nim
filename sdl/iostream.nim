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

    IoFileMode* = enum
        ## Update = read and write
        ifmRead                  = "r"
        ifmWrite                 = "w"
        ifmAppend                = "a"
        ifmUpdate                = "r+"
        ifmUpdateEmpty           = "w+"
        ifmAppendProtected       = "a+"
        ifmReadBinary            = "rb"
        ifmWriteBinary           = "wb"
        ifmAppendBinary          = "ab"
        ifmUpdateBinary          = "r+b"
        ifmUpdateEmptyBinary     = "w+b"
        ifmAppendProtectedBinary = "a+b"

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

{.push inline.}

proc `=destroy`*(stream: IoStream) =
    sdl_assert SDL_CloseIO stream, &"Failed to close IoStream"

proc iostream_from_file*(file: string; mode: IoFileMode): IoStream =
    result = SDL_IOFromFile(cstring file, cstring $mode)
    sdl_assert result, &"Failed to create IoStream from file '{file}' for '{mode}'"

proc iostream_from_mem*[T](mem: pointer; sz: SomeInteger): IoStream =
    result = SDL_IOFromMem(mem, csize_t sz)
    sdl_assert result, &"Failed to create IoStream from memory (size: {sz}B/{(float sz)/1024:.2f}kB)"
proc iostream_from_mem*[T](data: openArray[T]): IoStream =
    let sz = data.len*sizeof T
    iostream_from_mem data[0].addr, sz

proc properties*(stream: IoStream): PropertyId =
    result = SDL_GetIOProperties stream
    sdl_assert result != InvalidProperty, &"Failed to get properties for stream"

proc status*(stream: IoStream): IoStatus =
    SDL_GetIOStatus stream

proc size*(stream: IoStream): int =
    result = int64 SDL_GetIOSize stream
    sdl_assert result >= 0, &"Failed to get the size of stream"

proc seek*(stream: IoStream; offset: SomeInteger; whence: IoWhence): int =
    result = int SDL_SeekIO(stream, int64 offset, whence)
    sdl_assert result != -1, &"Failed to seek in stream to {offset} ({whence})"

proc offset*(stream: IoStream): int =
    result = int SDL_TellIO stream
    sdl_assert result != -1, &"Failed to get the offset for stream"

proc read*(stream: IoStream; dst: pointer; sz: SomeInteger): int =
    int SDL_ReadIO stream, dst, csize_t sz
proc read*[T](stream: IoStream; dst: var openArray[T]): int =
    read stream, dst[0].addr, dst.len*sizeof T

proc write*(stream: IoStream; src: pointer; sz: SomeInteger): int =
    ## Returns the number of bytes written
    int SDL_WriteIO stream, src, csize_t sz
proc write*[T](stream: IoStream; data: openArray[T]): int =
    ## Returns the number of elements written
    result = write(stream, data[0].addr, data.len*sizeof T)
    result = result div sizeof T

proc flush*(stream: IoStream): bool =
    SDL_FlushIO stream

proc read*[T](stream: IoStream; dst: var T): bool =
    when T is uint8 : stream.SDL_ReadU8    dst.addr
    elif T is  int8 : stream.SDL_ReadS8    dst.addr
    elif T is uint16: stream.SDL_ReadU16LE dst.addr
    elif T is  int16: stream.SDL_ReadS16LE dst.addr
    elif T is uint32: stream.SDL_ReadU32LE dst.addr
    elif T is  int32: stream.SDL_ReadS32LE dst.addr
    elif T is uint64: stream.SDL_ReadU64LE dst.addr
    elif T is  int64: stream.SDL_ReadS64LE dst.addr
    else:
        quit &"`read` does not have implementation for value of type '{$T}'"

proc read_be*[T](stream: IoStream; dst: var T): bool =
    when T is uint8 : stream.SDL_ReadU8    dst.addr
    elif T is  int8 : stream.SDL_ReadS8    dst.addr
    elif T is uint16: stream.SDL_ReadU16BE dst.addr
    elif T is  int16: stream.SDL_ReadS16BE dst.addr
    elif T is uint32: stream.SDL_ReadU32BE dst.addr
    elif T is  int32: stream.SDL_ReadS32BE dst.addr
    elif T is uint64: stream.SDL_ReadU64BE dst.addr
    elif T is  int64: stream.SDL_ReadS64BE dst.addr
    else:
        quit &"`read_be` does not have implementation for value of type '{$T}'"

proc write*[T](stream: IoStream; src: T): bool =
    when T is uint8 : stream.SDL_WriteU8    src
    elif T is  int8 : stream.SDL_WriteS8    src
    elif T is uint16: stream.SDL_WriteU16LE src
    elif T is  int16: stream.SDL_WriteS16LE src
    elif T is uint32: stream.SDL_WriteU32LE src
    elif T is  int32: stream.SDL_WriteS32LE src
    elif T is uint64: stream.SDL_WriteU64LE src
    elif T is  int64: stream.SDL_WriteS64LE src
    else:
        quit &"`write` does not have implementation for value of type '{$T}'"

proc write_be*[T](stream: IoStream; src: T): bool =
    when T is uint8 : stream.SDL_WriteU8    src
    elif T is  int8 : stream.SDL_WriteS8    src
    elif T is uint16: stream.SDL_WriteU16BE src
    elif T is  int16: stream.SDL_WriteS16BE src
    elif T is uint32: stream.SDL_WriteU32BE src
    elif T is  int32: stream.SDL_WriteS32BE src
    elif T is uint64: stream.SDL_WriteU64BE src
    elif T is  int64: stream.SDL_WriteS64BE src
    else:
        quit &"`write_be` does not have implementation for value of type '{$T}'"

{.pop.}

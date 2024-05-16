import pixels, rect

type
    BlitMap* = distinct pointer

    FlipMode* {.size: sizeof(cint).} = enum
        None
        Horizontal
        Vertical

    SurfaceObj* = object
        flags       : uint32
        format      : ptr PixelFormat
        w*, h*      : int32
        pitch*      : int32
        pixels      : pointer
        reserved    : pointer
        locked      : int32
        blitmap_list: pointer
        clip_rect   : Rect
        map         : BlitMap
        ref_count   : int32
    Surface* = ptr SurfaceObj

import pixels, rect

type FlipMode* {.size: sizeof(cint).} = enum
    fmNone
    fmHorizontal
    fmVertical

type
    BlitMap* = distinct pointer

    SurfaceObj* = object
        flags*      : uint32
        format*     : ptr PixelFormat
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


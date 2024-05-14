type
    Surface* = distinct pointer

    FlipMode* {.size: sizeof(cint).} = enum
        None
        Horizontal
        Vertical

import bitgen, common

type BlendMode* = distinct uint32
BlendMode.gen_bit_ops(
    bmBlend, bmAdd, bmMod, bmMul,
    bmBlendPremultiplied, bmAddPremultiplied
)
const
    bmNone*    = BlendMode 0
    bmInvalid* = BlendMode 0x7FFF_FFF

type
    BlendOperation* {.size: sizeof(cint).} = enum
        Add    = 0x1
        Sub    = 0x2
        RevSub = 0x3
        Min    = 0x4
        Max    = 0x5

    BlendFactor* {.size: sizeof(cint).} = enum
        Zero = 0x1
        One  = 0x2

        SrcColour         = 0x3
        OneMinusSrcColour = 0x4
        SrcAlpha          = 0x5
        OneMinusSrcAlpha  = 0x6

        DstColour         = 0x7
        OneMinusDstColour = 0x8
        DstAlpha          = 0x9
        OneMinusDstAlpha  = 0xA

proc SDL_ComposeCustomBlendMode*(src_colour_factor, dst_colour_factor: BlendFactor; colour_op: BlendOperation;
                                 src_alpha_factor , dst_alpha_factor : BlendFactor; alpha_op : BlendOperation;
                                 ): BlendMode {.importc, cdecl, dynlib: SdlLib.}

type
    Alpha* {.size: sizeof(cint).} = enum
        aTransparent = 0
        aOpaque      = 255

    PixelKind* {.size: sizeof(cint).} = enum
        pkUnknown
        pkIndex1
        pkIndex4
        pkIndex8
        pkPacked8
        pkPacked16
        pkPacked32
        pkArrayU8
        pkArrayU16
        pkArrayU32
        pkArrayF16
        pkArrayF32

    BitmapOrder* {.size: sizeof(cint).} = enum
        boNone
        bo4321
        bo1234

    PackedOrder* {.size: sizeof(cint).} = enum
        poNone
        poXRGB
        poRGBX
        poARGB
        poRGBA
        poXBGR
        poBGRX
        poABGR
        poBGRA

    ArrayOrder* {.size: sizeof(cint).} = enum
        aoNone
        aoRGB
        aoRGBA
        aoARGB
        aoBGR
        aoBGRA
        aoABGR

    PixelOrder* = BitmapOrder | PackedOrder | ArrayOrder

    PackedLayout* {.size: sizeof(cint).} = enum
        plNone
        pl332
        pl4444
        pl1555
        pl5551
        pl565
        pl8888
        pl2101010
        pl1010102

    # TODO
    Colourspace* {.size: sizeof(cint).} = enum
        xxx

#[ -------------------------------------------------------------------- ]#

template pixel_format*(kind: PixelKind; order: PixelOrder; layout: PackedLayout; bits, bytes: int): int =
    (1          shl 28) or
    (kind.ord   shl 24) or
    (order.ord  shl 20) or
    (layout.ord shl 16) or
    (bits       shl 8)  or
    (bytes      shl 0)

# TODO
type PixelFormat* {.size: sizeof(int32).} = enum
    pxFmtUnknown
    pxFmtArgb8 = pixel_format(pkPacked32, poARGB, pl8888, 32, 4)
    pxFmtRgba8 = pixel_format(pkPacked32, poRGBA, pl8888, 32, 4)
    pxFmtAbgr8 = pixel_format(pkPacked32, poABGR, pl8888, 32, 4)
    pxFmtBgra8 = pixel_format(pkPacked32, poBGRA, pl8888, 32, 4)

type Pixel* = distinct uint32

template pixel_flag*(px: Pixel)     = (px shr 28) and 0x0F
template pixel_kind*(px: Pixel)     = (px shr 24) and 0x0F
template pixel_order*(px: Pixel)    = (px shr 20) and 0x0F
template pixel_layout*(px: Pixel)   = (px shr 16) and 0x0F
template bits_per_pixel*(px: Pixel) = (px shr 8 ) and 0xFF

type
    Colour* = object
        b*, g*, r*: uint8 = 0
        a*: uint8 = 255
    ColourF* = object
        b*, g*, r*: float32 = 0.0
        a*: float32 = 1.0

    Palette* = ptr PaletteObj
    PaletteObj = object
        colour_cnt*: int32
        colours*   : ptr UncheckedArray[Colour]
        version*   : uint32
        ref_cnt*   : int32

func colour*(r, g, b: uint8; a = 255'u8): Colour   =  Colour(r: r, g: g, b: b, a: a)
func colour*(r, g, b: float32; a = 1'f32): ColourF = ColourF(r: r, g: g, b: b, a: a)
func colour*(hex: uint32): Colour =
    Colour(r: uint8(hex and 0x0000_00FF'u32),
           g: uint8(hex and 0x0000_FF00'u32),
           b: uint8(hex and 0x00FF_0000'u32),
           a: uint8(hex and 0xFF00_0000'u32))

converter uint32_to_colour*(rgba: uint32): Colour = colour rgba

func `+`*[T: Colour | ColourF](a, b: T): T = colour a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a
func `-`*[T: Colour | ColourF](a, b: T): T = colour a.r - b.r, a.g - b.g, a.b - b.b, a.a - b.a

func fourcc*(a, b, c, d: uint8): uint32 =
    a shl 0  or
    b shl 8  or
    c shl 16 or
    d shl 24

const
    Black*   = colour(0  , 0  , 0  )
    White*   = colour(255, 255, 255)
    Red*     = colour(255, 0  , 0  )
    Lime*    = colour(0  , 255, 0  )
    Blue*    = colour(0  , 0  , 255)
    Yellow*  = colour(255, 255, 0  )
    Cyan*    = colour(0  , 255, 255)
    Magenta* = colour(255, 0  , 255)
    Silver*  = colour(192, 192, 192)
    Grey*    = colour(128, 128, 128)
    Maroon*  = colour(128, 0  , 0  )
    Olive*   = colour(128, 128, 0  )
    Green*   = colour(0  , 128, 0  )
    Purple*  = colour(128, 0  , 128)
    Teal*    = colour(0  , 128, 128)
    Navy*    = colour(0  , 0  , 128)

    FBlack*   = colour(0.0, 0.0, 0.0)
    FWhite*   = colour(1.0, 1.0, 1.0)
    FRed*     = colour(1.0, 0.0, 0.0)
    FLime*    = colour(0.0, 1.0, 0.0)
    FBlue*    = colour(0.0, 0.0, 1.0)
    FYellow*  = colour(1.0, 1.0, 0.0)
    FCyan*    = colour(0.0, 1.0, 1.0)
    FMagenta* = colour(1.0, 0.0, 1.0)
    FSilver*  = colour(0.8, 0.8, 0.8)
    FGrey*    = colour(0.5, 0.5, 0.5)
    FMaroon*  = colour(0.5, 0.0, 0.0)
    FOlive*   = colour(0.5, 0.5, 0.0)
    FGreen*   = colour(0.0, 0.5, 0.0)
    FPurple*  = colour(0.5, 0.0, 0.5)
    FTeal*    = colour(0.0, 0.5, 0.5)
    FNavy*    = colour(0.0, 0.0, 0.5)

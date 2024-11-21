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
        r*, g*, b*: uint8 = 0
        a*: uint8 = 255
    FColour* = object
        r*, g*, b*: float32 = 0.0
        a*: float32 = 1.0

    Palette* = object
        colour_count*: int32
        colours*     : ptr UncheckedArray[Colour]
        version*     : uint32
        ref_count*   : int32

func colour*(r, g, b: SomeInteger; a: SomeInteger = 255): Colour =
    Colour(r: uint8 r, g: uint8 g, b: uint8 b, a: uint8 a)
func fcolour*(r, g, b: SomeNumber; a: SomeNumber = 1.0): FColour =
    FColour(r: float32 r, g: float32 g, b: float32 b, a: float32 a)

func `+`*[T: Colour | FColour](a, b: T): T = colour a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a
func `-`*[T: Colour | FColour](a, b: T): T = colour a.r - b.r, a.g - b.g, a.b - b.b, a.a - b.a

func fourcc*(a, b, c, d: uint8): uint32 =
    a shl 0  or
    b shl 8  or
    c shl 16 or
    d shl 24

const
    Black*   = colour(0  , 0  , 0  , 255)
    White*   = colour(255, 255, 255, 255)
    Red*     = colour(255, 0  , 0  , 255)
    Lime*    = colour(0  , 255, 0  , 255)
    Blue*    = colour(0  , 0  , 255, 255)
    Yellow*  = colour(255, 255, 0  , 255)
    Cyan*    = colour(0  , 255, 255, 255)
    Magenta* = colour(255, 0  , 255, 255)
    Silver*  = colour(192, 192, 192, 255)
    Grey*    = colour(128, 128, 128, 255)
    Maroon*  = colour(128, 0  , 0  , 255)
    Olive*   = colour(128, 128, 0  , 255)
    Green*   = colour(0  , 128, 0  , 255)
    Purple*  = colour(128, 0  , 128, 255)
    Teal*    = colour(0  , 128, 128, 255)
    Navy*    = colour(0  , 0  , 128, 255)

    FBlack*   = fcolour(0.0, 0.0, 0.0, 1.0)
    FWhite*   = fcolour(1.0, 1.0, 1.0, 1.0)
    FRed*     = fcolour(1.0, 0.0, 0.0, 1.0)
    FLime*    = fcolour(0.0, 1.0, 0.0, 1.0)
    FBlue*    = fcolour(0.0, 0.0, 1.0, 1.0)
    FYellow*  = fcolour(1.0, 1.0, 0.0, 1.0)
    FCyan*    = fcolour(0.0, 1.0, 1.0, 1.0)
    FMagenta* = fcolour(1.0, 0.0, 1.0, 1.0)
    FSilver*  = fcolour(0.8, 0.8, 0.8, 1.0)
    FGrey*    = fcolour(0.5, 0.5, 0.5, 1.0)
    FMaroon*  = fcolour(0.5, 0.0, 0.0, 1.0)
    FOlive*   = fcolour(0.5, 0.5, 0.0, 1.0)
    FGreen*   = fcolour(0.0, 0.5, 0.0, 1.0)
    FPurple*  = fcolour(0.5, 0.0, 0.5, 1.0)
    FTeal*    = fcolour(0.0, 0.5, 0.5, 1.0)
    FNavy*    = fcolour(0.0, 0.0, 0.5, 1.0)

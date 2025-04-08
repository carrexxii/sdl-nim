import std/options, common

type
    PixelKind* {.size: sizeof(cint).} = enum
        Unknown
        Index1, Index4, Index8
        Packed8, Packed16, Packed32
        ArrayU8, ArrayU16, ArrayU32
        ArrayF16, ArrayF32

    BitmapOrder* {.size: sizeof(cint).} = enum
        None
        O4321
        O1234

    PackedOrder* {.size: sizeof(cint).} = enum
        None
        Xrgb
        Rgbx
        Argb
        Rgba
        Xbgr
        Bgrx
        Abgr
        Bgra

    ArrayOrder* {.size: sizeof(cint).} = enum
        None
        Rgb
        Rgba
        Argb
        Bgr
        Bgra
        Abgr

    PackedLayout* {.size: sizeof(cint).} = enum
        None
        L332
        L4444
        L1555
        L5551
        L565
        L8888
        L2101010
        L1010102

    PixelFormat* {.size: sizeof(uint32).} = enum
        Unknown   = 0
        Index1Lsb = 0x1110_0100

        Index1Msb    = 0x1120_0100
        Index2Lsb    = 0x1C10_0200
        Index2Msb    = 0x1C20_0200
        Index4Lsb    = 0x1210_0400
        Index4Msb    = 0x1220_0400
        Index8       = 0x1300_0801
        Rgb332       = 0x1411_0801
        Xrgb4444     = 0x1512_0C02
        Xbgr4444     = 0x1552_0C02
        Xrgb1555     = 0x1513_0F02
        Xbgr1555     = 0x1553_0F02
        Argb4444     = 0x1532_1002
        Rgba4444     = 0x1542_1002
        Abgr4444     = 0x1572_1002
        Bgra4444     = 0x1582_1002
        Argb1555     = 0x1533_1002
        Rgba5551     = 0x1544_1002
        Abgr1555     = 0x1573_1002
        Bgra5551     = 0x1584_1002
        Rgb565       = 0x1515_1002
        Bgr565       = 0x1555_1002
        Rgb24        = 0x1710_1803
        Bgr24        = 0x1740_1803
        Xrgb8888     = 0x1616_1804
        Rgbx8888     = 0x1626_1804
        Xbgr8888     = 0x1656_1804
        Bgrx8888     = 0x1666_1804
        Argb8888     = 0x1636_2004
        Rgba8888     = 0x1646_2004
        Abgr8888     = 0x1676_2004
        Bgra8888     = 0x1686_2004
        Xrgb2101010  = 0x1617_2004
        Xbgr2101010  = 0x1657_2004
        Argb2101010  = 0x1637_2004
        Abgr2101010  = 0x1677_2004
        Rgb48        = 0x1810_3006
        Bgr48        = 0x1840_3006
        Rgba64       = 0x1820_4008
        Argb64       = 0x1830_4008
        Bgra64       = 0x1850_4008
        Abgr64       = 0x1860_4008
        Rgb48Float   = 0x1A10_3006
        Bgr48Float   = 0x1A40_3006
        Rgba64Float  = 0x1A20_4008
        Argb64Float  = 0x1A30_4008
        Bgra64Float  = 0x1A50_4008
        Abgr64Float  = 0x1A60_4008
        Rgb96Float   = 0x1B10_600C
        Bgr96Float   = 0x1B40_600C
        Rgba128Float = 0x1B20_8010
        Argb128Float = 0x1B30_8010
        Bgra128Float = 0x1B50_8010
        Abgr128Float = 0x1B60_8010

        Yv12        = 0x3231_5659
        Iyuv        = 0x5655_5949
        Yuy2        = 0x3259_5559
        Uyvy        = 0x5956_5955
        Yvyu        = 0x5559_5659
        Nv12        = 0x3231_564E
        Nv21        = 0x3132_564E
        P010        = 0x3031_3050
        ExternalOes = 0x2053_454F

        Mjpg = 0x4750_4A4D

    ColourKind* {.size: sizeof(cint).} = enum
        Unknown = 0
        Rgb     = 1
        Ycbcr   = 2

    ColourRange* {.size: sizeof(cint).} = enum
        Unknown = 0
        Limited = 1
        Full    = 2

    ColourPrimaries* {.size: sizeof(cint).} = enum
        Unknown     = 0
        Bt709       = 1
        Unspecified = 2
        Bt470M      = 4
        Bt470Bg     = 5
        Bt601       = 6
        Smpte240    = 7
        GenericFilm = 8
        Bt2020      = 9
        Xyz         = 10
        Smpte431    = 11
        Smpte432    = 12
        Ebu3213     = 22
        Custom      = 31

    TransferCharacteristics* {.size: sizeof(cint).} = enum
        Unknown      = 0
        Bt709        = 1
        Unspecified  = 2
        Gamma22      = 4
        Gamma28      = 5
        Bt601        = 6
        Smpte240     = 7
        Linear       = 8
        Log100       = 9
        Log100Sqrt10 = 10
        Iec61966     = 11
        Bt1361       = 12
        Srgb         = 13
        Bt202010Bit  = 14
        Bt202012Bit  = 15
        Pq           = 16
        Smpte428     = 17
        Hlg          = 18
        Custom       = 31

    MatrixCoefficients* {.size: sizeof(cint).} = enum
        Identity         = 0
        Bt709            = 1
        Unspecified      = 2
        Fcc              = 4
        Bt470Bg          = 5
        Bt601            = 6
        Smpte240         = 7
        Ycgco            = 8
        Bt2020Ncl        = 9
        Bt2020Cl         = 10
        Smpte2085        = 11
        ChromaDerivedNcl = 12
        ChromaDerivedCl  = 13
        Ictcp            = 14
        Custom           = 31

    ChromaLocation* {.size: sizeof(cint).} = enum
        None    = 0
        Left    = 1
        Centre  = 2
        TopLeft = 3

    Colourspace* {.size: sizeof(cint).} = enum
        Unknown       = 0
        Srgb          = 0x1200_05A0
        SrgbLinear    = 0x1200_0500
        Hdr10         = 0x1200_2600
        Jpeg          = 0x2200_04C6
        Bt601Limited  = 0x2110_18C6
        Bt601Full     = 0x2210_18C6
        Bt709Limited  = 0x2110_0421
        Bt709Full     = 0x2210_0421
        Bt2020Limited = 0x2110_2609
        Bt2020Full    = 0x2210_2609

const
    Rgba32* = PixelFormat.Abgr8888
    Argb32* = PixelFormat.Bgra8888
    Bgra32* = PixelFormat.Argb8888
    Abgr32* = PixelFormat.Rgba8888
    Rgbx32* = PixelFormat.Xbgr8888
    Xrgb32* = PixelFormat.Bgrx8888
    Bgrx32* = PixelFormat.Xrgb8888
    Xbgr32* = PixelFormat.Rgbx8888

    RgbDefault* = Colourspace.Srgb
    YuvDefault* = Colourspace.Jpeg

type
    Pixel* = distinct uint32

    Colour* = object
        r*: uint8
        g*: uint8
        b*: uint8
        a*: uint8

    ColourF* = object
        r*: float32
        g*: float32
        b*: float32
        a*: float32

    Palette* = distinct pointer
    PaletteObj* = object
        colour_cnt*: int32
        colours*   : ptr UncheckedArray[Colour]
        version: uint32
        ref_cnt: int32

    PixelFormatDetails* = distinct pointer
    PixelFormatDetailsObj* = object
        fmt*         : PixelFormat
        bits_per_px* : uint8
        bytes_per_px*: uint8
        _            : array[2, byte]
        rmask* , gmask* , bmask* , amask*: uint32
        rbits* , gbits* , bbits* , abits* : uint8
        rshift*, gshift*, bshift*, ashift*: uint8

proc SDL_DestroyPalette*(palette: Palette) {.importc, cdecl, dynlib: SdlLib.}
proc `=destroy`*(palette: Palette) =
    SDL_DestroyPalette palette

converter `Palette -> bool`*(palette: Palette): bool                       = nil != pointer palette
converter `PixelFormatDetails -> bool`*(details: PixelFormatDetails): bool = nil != pointer details
converter to_uint32*(fmt: Pixel): uint32 = uint32 fmt

func pixel_format*(kind: PixelKind; order: PackedOrder; layout: PackedLayout; bits, bytes: distinct SomeInteger): Pixel =
    Pixel (
        (1             shl 28) or
        (kind.ord      shl 24) or
        (order.ord     shl 20) or
        (layout.ord    shl 16) or
        ((int32 bits)  shl 8 ) or
        ((int32 bytes) shl 0 )
    )

func colour*(r, g, b: uint8; a = 255'u8): Colour   =  Colour(r: r, g: g, b: b, a: a)
func colour*(r, g, b: float32; a = 1'f32): ColourF = ColourF(r: r, g: g, b: b, a: a)
func colour*(hex: uint32): Colour =
    Colour(r: uint8(hex and 0x0000_00FF'u32),
           g: uint8(hex and 0x0000_FF00'u32),
           b: uint8(hex and 0x00FF_0000'u32),
           a: uint8(hex and 0xFF00_0000'u32))

converter to_colour*(rgba: uint32): Colour = colour rgba

func `+`*[T: Colour | ColourF](a, b: T): T = colour a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a
func `-`*[T: Colour | ColourF](a, b: T): T = colour a.r - b.r, a.g - b.g, a.b - b.b, a.a - b.a

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_GetPixelFormatName(fmt: PixelFormat): cstring
proc SDL_GetMasksForPixelFormat*(fmt: PixelFormat; bpp: ptr cint; rmask, gmask, bmask, amask: ptr uint32): bool
proc SDL_GetPixelFormatForMasks*(bpp: cint; rmask, gmask, bmask, amask: uint32): PixelFormat
proc SDL_GetPixelFormatDetails*(fmt: PixelFormat): PixelFormatDetails
proc SDL_CreatePalette*(colour_cnt: cint): Palette
proc SDL_SetPaletteColors*(palette: Palette; colors: ptr Colour; fst_colour, colour_cnt: cint): bool
proc SDL_MapRGB*(fmt: PixelFormatDetails; palette: Palette; r, g, b: uint8): Pixel
proc SDL_MapRGBA*(fmt: PixelFormatDetails; palette: Palette; r, g, b, a: uint8): Pixel
proc SDL_GetRGB*(px: Pixel; fmt: PixelFormatDetails; palette: Palette; r, g, b: ptr uint8)
proc SDL_GetRGBA*(px: Pixel; fmt: PixelFormatDetails; palette: Palette; r, g, b, a: ptr uint8)
{.pop.}

{.push inline.}

proc name*(fmt: PixelFormat): string                = $SDL_GetPixelFormatName(fmt)
proc details*(fmt: PixelFormat): PixelFormatDetails = SDL_GetPixelFormatDetails fmt

proc mask*(fmt: PixelFormat): tuple[bpp: int32; r, g, b, a: uint32] =
    let success = SDL_GetMasksForPixelFormat(fmt, result.bpp.addr, result.r.addr, result.g.addr, result.b.addr, result.a.addr)
    sdl_assert success, &"Failed to get masks for pixel format '{fmt}'"

proc format*(bpp: SomeInteger; rmask, gmask, bmask, amask: uint32): PixelFormat =
    SDL_GetPixelFormatForMasks cint bpp, rmask, gmask, bmask, amask

proc create_palette*(colour_cnt: SomeInteger): Palette =
    result = SDL_CreatePalette(cint colour_cnt)
    sdl_assert result, &"Failed to create palette with {colour_cnt} colours"

proc set_colours*(palette: Palette; colours: openArray[Colour]; fst_colour: SomeInteger = 0): bool {.discardable.} =
    result = SDL_SetPaletteColors(palette, colours[0].addr, cint fst_colour, cint colours.len)
    sdl_assert result, &"Failed to set colours for palette (starting from {fst_colour} -> {colours})"
proc `colours=`*(palette: Palette; colours: openArray[Colour]) = set_colours palette, colours

proc map*(fmt: PixelFormatDetails; palette: Palette; r, g, b: uint8): Pixel    = SDL_MapRGB fmt, palette, r, g, b
proc map*(fmt: PixelFormatDetails; palette: Palette; r, g, b, a: uint8): Pixel = SDL_MapRGBA fmt, palette, r, g, b, a

proc rgb*(px: Pixel; fmt: PixelFormatDetails; palette: Option[Palette]): tuple[r, g, b: uint8] =
    let palette = if palette.is_some: get(palette) else: Palette nil
    SDL_GetRGB px, fmt, palette, result.r.addr, result.g.addr, result.b.addr

proc rgba*(px: Pixel; fmt: PixelFormatDetails; palette: Option[Palette]): tuple[r, g, b, a: uint8] =
    let palette = if palette.is_some: get(palette) else: Palette nil
    SDL_GetRGBA px, fmt, palette, result.r.addr, result.g.addr, result.b.addr, result.a.addr

{.pop.}

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

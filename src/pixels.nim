import common

type
    Alpha* {.size: sizeof(int32).} = enum
        Transparent = 0
        Opaque      = 255

    PixelKind* {.size: sizeof(int32).} = enum
        Unknown
        Index1
        Index4
        Index8
        Packed8
        Packed16
        Packed32
        ArrayU8
        ArrayU16
        ArrayU32
        ArrayF16
        ArrayF32

    BitmapOrder* {.size: sizeof(int32).} = enum
        None
        N4321
        N1234

    PackedOrder* {.size: sizeof(int32).} = enum
        None
        XRGB
        RGBX
        ARGB
        RGBA
        XBGR
        BGRX
        ABGR
        BGRA

    ArrayOrder* {.size: sizeof(int32).} = enum
        None
        RGB
        RGBA
        ARGB
        BGR
        BGRA
        ABGR

    PixelOrder* = BitmapOrder | PackedOrder | ArrayOrder

    PackedLayout* {.size: sizeof(int32).} = enum
        None
        N332
        N4444
        N1555
        N5551
        N565
        N8888
        N2101010
        N1010102

    # TODO
    PixelFormat* {.size: sizeof(int32).} = enum
        Unknown

func `==`*(a, b: PixelFormat): bool = a == b

type Pixel* = distinct uint32

template pixel_format*(kind: PixelKind; order: PixelOrder; layout: PackedLayout; bits, bytes: int): PixelFormat =
    (1      shl 28) or
    (kind   shl 24) or
    (order  shl 20) or
    (layout shl 16) or
    (bits   shl 8)  or
    (bytes  shl 0)

template pixel_flag*(px: Pixel)     = (px shr 28) and 0x0F
template pixel_kind*(px: Pixel)     = (px shr 24) and 0x0F
template pixel_order*(px: Pixel)    = (px shr 20) and 0x0F
template pixel_layout*(px: Pixel)   = (px shr 16) and 0x0F
template bits_per_pixel*(px: Pixel) = (px shr 8)  and 0xFF

type
    Colour* = object
        r*, g*, b*, a*: uint8
    FColour* = object
        r*, g*, b*, a*: float

    Palette* = object
        colour_count*: int32
        colours*     : Colour
        version      : uint32
        ref_count    : int32

template four_cc*(a, b, c, d: uint8) =
    a shl 0  or
    b shl 8  or
    c shl 16 or
    d shl 24

# TODO

#define SDL_BYTESPERPIXEL(X) \
    # (SDL_ISPIXELFORMAT_FOURCC(X) ? \
    #     ((((X) == SDL_PIXELFORMAT_YUY2) || \
    #       ((X) == SDL_PIXELFORMAT_UYVY) || \
    #       ((X) == SDL_PIXELFORMAT_YVYU) || \
    #       ((X) == SDL_PIXELFORMAT_P010)) ? 2 : 1) : (((X) >> 0) & 0xFF))

#define SDL_ISPIXELFORMAT_INDEXED(format)   \
    # (!SDL_ISPIXELFORMAT_FOURCC(format) && \
    #  ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX1) || \
    #   (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX2) || \
    #   (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX4) || \
    #   (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX8)))

#define SDL_ISPIXELFORMAT_PACKED(format) \
    # (!SDL_ISPIXELFORMAT_FOURCC(format) && \
    #  ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED8) || \
    #   (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED16) || \
    #   (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED32)))

#define SDL_ISPIXELFORMAT_ARRAY(format) \
    # (!SDL_ISPIXELFORMAT_FOURCC(format) && \
    #  ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU8) || \
    #   (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU16) || \
    #   (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU32) || \
    #   (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF16) || \
    #   (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF32)))

#define SDL_ISPIXELFORMAT_ALPHA(format)   \
    # ((SDL_ISPIXELFORMAT_PACKED(format) && \
    #  ((SDL_PIXELORDER(format) == SDL_PACKEDORDER_ARGB) || \
    #   (SDL_PIXELORDER(format) == SDL_PACKEDORDER_RGBA) || \
    #   (SDL_PIXELORDER(format) == SDL_PACKEDORDER_ABGR) || \
    #   (SDL_PIXELORDER(format) == SDL_PACKEDORDER_BGRA))))

#define SDL_ISPIXELFORMAT_10BIT(format)    \
    #   (!SDL_ISPIXELFORMAT_FOURCC(format) && \
    #    ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED32) && \
    #     (SDL_PIXELLAYOUT(format) == SDL_PACKEDLAYOUT_2101010)))

#define SDL_ISPIXELFORMAT_FLOAT(format)    \
    #   (!SDL_ISPIXELFORMAT_FOURCC(format) && \
    #    ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF16) || \
    #     (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF32)))

#define SDL_ISPIXELFORMAT_FOURCC(format)    \
    # ((format) && (SDL_PIXELFLAG(format) != 1))

# typedef enum SDL_PixelFormatEnum
# {
#     SDL_PIXELFORMAT_UNKNOWN,
#     SDL_PIXELFORMAT_INDEX1LSB = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX1, SDL_BITMAPORDER_4321, 0, 1, 0),
#     SDL_PIXELFORMAT_INDEX1MSB = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX1, SDL_BITMAPORDER_1234, 0, 1, 0),
#     SDL_PIXELFORMAT_INDEX2LSB = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX2, SDL_BITMAPORDER_4321, 0, 2, 0),
#     SDL_PIXELFORMAT_INDEX2MSB = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX2, SDL_BITMAPORDER_1234, 0, 2, 0),
#     SDL_PIXELFORMAT_INDEX4LSB = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX4, SDL_BITMAPORDER_4321, 0, 4, 0),
#     SDL_PIXELFORMAT_INDEX4MSB = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX4, SDL_BITMAPORDER_1234, 0, 4, 0),
#     SDL_PIXELFORMAT_INDEX8 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX8, 0, 0, 8, 1),
#     SDL_PIXELFORMAT_RGB332 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED8, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_332, 8, 1),
#     SDL_PIXELFORMAT_XRGB4444 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_4444, 12, 2),
#     SDL_PIXELFORMAT_RGB444 = SDL_PIXELFORMAT_XRGB4444,
#     SDL_PIXELFORMAT_XBGR4444 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_4444, 12, 2),
#     SDL_PIXELFORMAT_BGR444 = SDL_PIXELFORMAT_XBGR4444,
#     SDL_PIXELFORMAT_XRGB1555 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_1555, 15, 2),
#     SDL_PIXELFORMAT_RGB555 = SDL_PIXELFORMAT_XRGB1555,
#     SDL_PIXELFORMAT_XBGR1555 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_1555, 15, 2),
#     SDL_PIXELFORMAT_BGR555 = SDL_PIXELFORMAT_XBGR1555,
#     SDL_PIXELFORMAT_ARGB4444 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_4444, 16, 2),
#     SDL_PIXELFORMAT_RGBA4444 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_4444, 16, 2),
#     SDL_PIXELFORMAT_ABGR4444 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_4444, 16, 2),
#     SDL_PIXELFORMAT_BGRA4444 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_4444, 16, 2),
#     SDL_PIXELFORMAT_ARGB1555 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_1555, 16, 2),
#     SDL_PIXELFORMAT_RGBA5551 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_5551, 16, 2),
#     SDL_PIXELFORMAT_ABGR1555 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_1555, 16, 2),
#     SDL_PIXELFORMAT_BGRA5551 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_5551, 16, 2),
#     SDL_PIXELFORMAT_RGB565 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_565, 16, 2),
#     SDL_PIXELFORMAT_BGR565 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_565, 16, 2),
#     SDL_PIXELFORMAT_RGB24 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU8, SDL_ARRAYORDER_RGB, 0, 24, 3),
#     SDL_PIXELFORMAT_BGR24 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU8, SDL_ARRAYORDER_BGR, 0, 24, 3),
#     SDL_PIXELFORMAT_XRGB8888 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_8888, 24, 4),
#     SDL_PIXELFORMAT_RGBX8888 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBX, SDL_PACKEDLAYOUT_8888, 24, 4),
#     SDL_PIXELFORMAT_XBGR8888 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_8888, 24, 4),
#     SDL_PIXELFORMAT_BGRX8888 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_BGRX, SDL_PACKEDLAYOUT_8888, 24, 4),
#     SDL_PIXELFORMAT_ARGB8888 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_8888, 32, 4),
#     SDL_PIXELFORMAT_RGBA8888 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_8888, 32, 4),
#     SDL_PIXELFORMAT_ABGR8888 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_8888, 32, 4),
#     SDL_PIXELFORMAT_BGRA8888 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_8888, 32, 4),
#     SDL_PIXELFORMAT_XRGB2101010 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_2101010, 32, 4),
#     SDL_PIXELFORMAT_XBGR2101010 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_2101010, 32, 4),
#     SDL_PIXELFORMAT_ARGB2101010 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_2101010, 32, 4),
#     SDL_PIXELFORMAT_ABGR2101010 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_2101010, 32, 4),
#     SDL_PIXELFORMAT_RGB48 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_RGB, 0, 48, 6),
#     SDL_PIXELFORMAT_BGR48 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_BGR, 0, 48, 6),
#     SDL_PIXELFORMAT_RGBA64 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_RGBA, 0, 64, 8),
#     SDL_PIXELFORMAT_ARGB64 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_ARGB, 0, 64, 8),
#     SDL_PIXELFORMAT_BGRA64 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_BGRA, 0, 64, 8),
#     SDL_PIXELFORMAT_ABGR64 = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_ABGR, 0, 64, 8),
#     SDL_PIXELFORMAT_RGB48_FLOAT = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_RGB, 0, 48, 6),
#     SDL_PIXELFORMAT_BGR48_FLOAT = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_BGR, 0, 48, 6),
#     SDL_PIXELFORMAT_RGBA64_FLOAT = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_RGBA, 0, 64, 8),
#     SDL_PIXELFORMAT_ARGB64_FLOAT = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_ARGB, 0, 64, 8),
#     SDL_PIXELFORMAT_BGRA64_FLOAT = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_BGRA, 0, 64, 8),
#     SDL_PIXELFORMAT_ABGR64_FLOAT = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_ABGR, 0, 64, 8),
#     SDL_PIXELFORMAT_RGB96_FLOAT = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_RGB, 0, 96, 12),
#     SDL_PIXELFORMAT_BGR96_FLOAT = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_BGR, 0, 96, 12),
#     SDL_PIXELFORMAT_RGBA128_FLOAT = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_RGBA, 0, 128, 16),
#     SDL_PIXELFORMAT_ARGB128_FLOAT = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_ARGB, 0, 128, 16),
#     SDL_PIXELFORMAT_BGRA128_FLOAT = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_BGRA, 0, 128, 16),
#     SDL_PIXELFORMAT_ABGR128_FLOAT = SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_ABGR, 0, 128, 16),

# #if SDL_BYTEORDER == SDL_BIG_ENDIAN
#     SDL_PIXELFORMAT_RGBA32 = SDL_PIXELFORMAT_RGBA8888,
#     SDL_PIXELFORMAT_ARGB32 = SDL_PIXELFORMAT_ARGB8888,
#     SDL_PIXELFORMAT_BGRA32 = SDL_PIXELFORMAT_BGRA8888,
#     SDL_PIXELFORMAT_ABGR32 = SDL_PIXELFORMAT_ABGR8888,
#     SDL_PIXELFORMAT_RGBX32 = SDL_PIXELFORMAT_RGBX8888,
#     SDL_PIXELFORMAT_XRGB32 = SDL_PIXELFORMAT_XRGB8888,
#     SDL_PIXELFORMAT_BGRX32 = SDL_PIXELFORMAT_BGRX8888,
#     SDL_PIXELFORMAT_XBGR32 = SDL_PIXELFORMAT_XBGR8888,
# #else
#     SDL_PIXELFORMAT_RGBA32 = SDL_PIXELFORMAT_ABGR8888,
#     SDL_PIXELFORMAT_ARGB32 = SDL_PIXELFORMAT_BGRA8888,
#     SDL_PIXELFORMAT_BGRA32 = SDL_PIXELFORMAT_ARGB8888,
#     SDL_PIXELFORMAT_ABGR32 = SDL_PIXELFORMAT_RGBA8888,
#     SDL_PIXELFORMAT_RGBX32 = SDL_PIXELFORMAT_XBGR8888,
#     SDL_PIXELFORMAT_XRGB32 = SDL_PIXELFORMAT_BGRX8888,
#     SDL_PIXELFORMAT_BGRX32 = SDL_PIXELFORMAT_XRGB8888,
#     SDL_PIXELFORMAT_XBGR32 = SDL_PIXELFORMAT_RGBX8888,
# #endif

#     SDL_PIXELFORMAT_YV12 = SDL_DEFINE_PIXELFOURCC('Y', 'V', '1', '2'),
#     SDL_PIXELFORMAT_IYUV = SDL_DEFINE_PIXELFOURCC('I', 'Y', 'U', 'V'),
#     SDL_PIXELFORMAT_YUY2 = SDL_DEFINE_PIXELFOURCC('Y', 'U', 'Y', '2'),
#     SDL_PIXELFORMAT_UYVY = SDL_DEFINE_PIXELFOURCC('U', 'Y', 'V', 'Y'),
#     SDL_PIXELFORMAT_YVYU = SDL_DEFINE_PIXELFOURCC('Y', 'V', 'Y', 'U'),
#     SDL_PIXELFORMAT_NV12 = SDL_DEFINE_PIXELFOURCC('N', 'V', '1', '2'),
#     SDL_PIXELFORMAT_NV21 = SDL_DEFINE_PIXELFOURCC('N', 'V', '2', '1'),
#     SDL_PIXELFORMAT_P010 = SDL_DEFINE_PIXELFOURCC('P', '0', '1', '0'),
#     SDL_PIXELFORMAT_EXTERNAL_OES = SDL_DEFINE_PIXELFOURCC('O', 'E', 'S', ' ')
# } SDL_PixelFormatEnum;

# typedef enum SDL_ColorType
# {
#     SDL_COLOR_TYPE_UNKNOWN = 0,
#     SDL_COLOR_TYPE_RGB = 1,
#     SDL_COLOR_TYPE_YCBCR = 2
# } SDL_ColorType;

# typedef enum SDL_ColorRange
# {
#     SDL_COLOR_RANGE_UNKNOWN = 0,
#     SDL_COLOR_RANGE_LIMITED = 1, /**< Narrow range, e.g. 16-235 for 8-bit RGB and luma, and 16-240 for 8-bit chroma */
#     SDL_COLOR_RANGE_FULL = 2    /**< Full range, e.g. 0-255 for 8-bit RGB and luma, and 1-255 for 8-bit chroma */
# } SDL_ColorRange;

# typedef enum SDL_ColorPrimaries
# {
#     SDL_COLOR_PRIMARIES_UNKNOWN = 0,
#     SDL_COLOR_PRIMARIES_BT709 = 1,                  /**< ITU-R BT.709-6 */
#     SDL_COLOR_PRIMARIES_UNSPECIFIED = 2,
#     SDL_COLOR_PRIMARIES_BT470M = 4,                 /**< ITU-R BT.470-6 System M */
#     SDL_COLOR_PRIMARIES_BT470BG = 5,                /**< ITU-R BT.470-6 System B, G / ITU-R BT.601-7 625 */
#     SDL_COLOR_PRIMARIES_BT601 = 6,                  /**< ITU-R BT.601-7 525 */
#     SDL_COLOR_PRIMARIES_SMPTE240 = 7,               /**< SMPTE 240M, functionally the same as SDL_COLOR_PRIMARIES_BT601 */
#     SDL_COLOR_PRIMARIES_GENERIC_FILM = 8,           /**< Generic film (color filters using Illuminant C) */
#     SDL_COLOR_PRIMARIES_BT2020 = 9,                 /**< ITU-R BT.2020-2 / ITU-R BT.2100-0 */
#     SDL_COLOR_PRIMARIES_XYZ = 10,                   /**< SMPTE ST 428-1 */
#     SDL_COLOR_PRIMARIES_SMPTE431 = 11,              /**< SMPTE RP 431-2 */
#     SDL_COLOR_PRIMARIES_SMPTE432 = 12,              /**< SMPTE EG 432-1 / DCI P3 */
#     SDL_COLOR_PRIMARIES_EBU3213 = 22,               /**< EBU Tech. 3213-E */
#     SDL_COLOR_PRIMARIES_CUSTOM = 31
# } SDL_ColorPrimaries;

# typedef enum SDL_TransferCharacteristics
# {
#     SDL_TRANSFER_CHARACTERISTICS_UNKNOWN = 0,
#     SDL_TRANSFER_CHARACTERISTICS_BT709 = 1,         /**< Rec. ITU-R BT.709-6 / ITU-R BT1361 */
#     SDL_TRANSFER_CHARACTERISTICS_UNSPECIFIED = 2,
#     SDL_TRANSFER_CHARACTERISTICS_GAMMA22 = 4,       /**< ITU-R BT.470-6 System M / ITU-R BT1700 625 PAL & SECAM */
#     SDL_TRANSFER_CHARACTERISTICS_GAMMA28 = 5,       /**< ITU-R BT.470-6 System B, G */
#     SDL_TRANSFER_CHARACTERISTICS_BT601 = 6,         /**< SMPTE ST 170M / ITU-R BT.601-7 525 or 625 */
#     SDL_TRANSFER_CHARACTERISTICS_SMPTE240 = 7,      /**< SMPTE ST 240M */
#     SDL_TRANSFER_CHARACTERISTICS_LINEAR = 8,
#     SDL_TRANSFER_CHARACTERISTICS_LOG100 = 9,
#     SDL_TRANSFER_CHARACTERISTICS_LOG100_SQRT10 = 10,
#     SDL_TRANSFER_CHARACTERISTICS_IEC61966 = 11,     /**< IEC 61966-2-4 */
#     SDL_TRANSFER_CHARACTERISTICS_BT1361 = 12,       /**< ITU-R BT1361 Extended Colour Gamut */
#     SDL_TRANSFER_CHARACTERISTICS_SRGB = 13,         /**< IEC 61966-2-1 (sRGB or sYCC) */
#     SDL_TRANSFER_CHARACTERISTICS_BT2020_10BIT = 14, /**< ITU-R BT2020 for 10-bit system */
#     SDL_TRANSFER_CHARACTERISTICS_BT2020_12BIT = 15, /**< ITU-R BT2020 for 12-bit system */
#     SDL_TRANSFER_CHARACTERISTICS_PQ = 16,           /**< SMPTE ST 2084 for 10-, 12-, 14- and 16-bit systems */
#     SDL_TRANSFER_CHARACTERISTICS_SMPTE428 = 17,     /**< SMPTE ST 428-1 */
#     SDL_TRANSFER_CHARACTERISTICS_HLG = 18,          /**< ARIB STD-B67, known as "hybrid log-gamma" (HLG) */
#     SDL_TRANSFER_CHARACTERISTICS_CUSTOM = 31
# } SDL_TransferCharacteristics;

# typedef enum SDL_MatrixCoefficients
# {
#     SDL_MATRIX_COEFFICIENTS_IDENTITY = 0,
#     SDL_MATRIX_COEFFICIENTS_BT709 = 1,              /**< ITU-R BT.709-6 */
#     SDL_MATRIX_COEFFICIENTS_UNSPECIFIED = 2,
#     SDL_MATRIX_COEFFICIENTS_FCC = 4,                /**< US FCC */
#     SDL_MATRIX_COEFFICIENTS_BT470BG = 5,            /**< ITU-R BT.470-6 System B, G / ITU-R BT.601-7 625, functionally the same as SDL_MATRIX_COEFFICIENTS_BT601 */
#     SDL_MATRIX_COEFFICIENTS_BT601 = 6,              /**< ITU-R BT.601-7 525 */
#     SDL_MATRIX_COEFFICIENTS_SMPTE240 = 7,           /**< SMPTE 240M */
#     SDL_MATRIX_COEFFICIENTS_YCGCO = 8,
#     SDL_MATRIX_COEFFICIENTS_BT2020_NCL = 9,         /**< ITU-R BT.2020-2 non-constant luminance */
#     SDL_MATRIX_COEFFICIENTS_BT2020_CL = 10,         /**< ITU-R BT.2020-2 constant luminance */
#     SDL_MATRIX_COEFFICIENTS_SMPTE2085 = 11,         /**< SMPTE ST 2085 */
#     SDL_MATRIX_COEFFICIENTS_CHROMA_DERIVED_NCL = 12,
#     SDL_MATRIX_COEFFICIENTS_CHROMA_DERIVED_CL = 13,
#     SDL_MATRIX_COEFFICIENTS_ICTCP = 14,             /**< ITU-R BT.2100-0 ICTCP */
#     SDL_MATRIX_COEFFICIENTS_CUSTOM = 31
# } SDL_MatrixCoefficients;

# typedef enum SDL_ChromaLocation
# {
#     SDL_CHROMA_LOCATION_NONE = 0,   /**< RGB, no chroma sampling */
#     SDL_CHROMA_LOCATION_LEFT = 1,   /**< In MPEG-2, MPEG-4, and AVC, Cb and Cr are taken on midpoint of the left-edge of the 2x2 square. In other words, they have the same horizontal location as the top-left pixel, but is shifted one-half pixel down vertically. */
#     SDL_CHROMA_LOCATION_CENTER = 2, /**< In JPEG/JFIF, H.261, and MPEG-1, Cb and Cr are taken at the center of the 2x2 square. In other words, they are offset one-half pixel to the right and one-half pixel down compared to the top-left pixel. */
#     SDL_CHROMA_LOCATION_TOPLEFT = 3 /**< In HEVC for BT.2020 and BT.2100 content (in particular on Blu-rays), Cb and Cr are sampled at the same location as the group's top-left Y pixel ("co-sited", "co-located"). */
# } SDL_ChromaLocation;

#define SDL_DEFINE_COLORSPACE(type, range, primaries, transfer, matrix, chroma) \
    # (((Uint32)(type) << 28) | ((Uint32)(range) << 24) | ((Uint32)(chroma) << 20) | \
    # ((Uint32)(primaries) << 10) | ((Uint32)(transfer) << 5) | ((Uint32)(matrix) << 0))

#define SDL_COLORSPACETYPE(X)       (SDL_ColorType)(((X) >> 28) & 0x0F)
#define SDL_COLORSPACERANGE(X)      (SDL_ColorRange)(((X) >> 24) & 0x0F)
#define SDL_COLORSPACECHROMA(X)     (SDL_ChromaLocation)(((X) >> 20) & 0x0F)
#define SDL_COLORSPACEPRIMARIES(X)  (SDL_ColorPrimaries)(((X) >> 10) & 0x1F)
#define SDL_COLORSPACETRANSFER(X)   (SDL_TransferCharacteristics)(((X) >> 5) & 0x1F)
#define SDL_COLORSPACEMATRIX(X)     (SDL_MatrixCoefficients)((X) & 0x1F)

#define SDL_ISCOLORSPACE_MATRIX_BT601(X)        (SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT601 || SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT470BG)
#define SDL_ISCOLORSPACE_MATRIX_BT709(X)        (SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT709)
#define SDL_ISCOLORSPACE_MATRIX_BT2020_NCL(X)   (SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT2020_NCL)
#define SDL_ISCOLORSPACE_LIMITED_RANGE(X)       (SDL_COLORSPACERANGE(X) != SDL_COLOR_RANGE_FULL)
#define SDL_ISCOLORSPACE_FULL_RANGE(X)          (SDL_COLORSPACERANGE(X) == SDL_COLOR_RANGE_FULL)

# typedef enum SDL_Colorspace
# {
#     SDL_COLORSPACE_UNKNOWN,
#     SDL_COLORSPACE_SRGB =   /**< Equivalent to DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709 */
#         SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_RGB,
#                               SDL_COLOR_RANGE_FULL,
#                               SDL_COLOR_PRIMARIES_BT709,
#                               SDL_TRANSFER_CHARACTERISTICS_SRGB,
#                               SDL_MATRIX_COEFFICIENTS_IDENTITY,
#                               SDL_CHROMA_LOCATION_NONE),
#     SDL_COLORSPACE_SRGB_LINEAR =   /**< Equivalent to DXGI_COLOR_SPACE_RGB_FULL_G10_NONE_P709  */
#         SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_RGB,
#                               SDL_COLOR_RANGE_FULL,
#                               SDL_COLOR_PRIMARIES_BT709,
#                               SDL_TRANSFER_CHARACTERISTICS_LINEAR,
#                               SDL_MATRIX_COEFFICIENTS_IDENTITY,
#                               SDL_CHROMA_LOCATION_NONE),
#     SDL_COLORSPACE_HDR10 =   /**< Equivalent to DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020  */
#         SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_RGB,
#                               SDL_COLOR_RANGE_FULL,
#                               SDL_COLOR_PRIMARIES_BT2020,
#                               SDL_TRANSFER_CHARACTERISTICS_PQ,
#                               SDL_MATRIX_COEFFICIENTS_IDENTITY,
#                               SDL_CHROMA_LOCATION_NONE),
#     SDL_COLORSPACE_JPEG =     /**< Equivalent to DXGI_COLOR_SPACE_YCBCR_FULL_G22_NONE_P709_X601 */
#         SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
#                               SDL_COLOR_RANGE_FULL,
#                               SDL_COLOR_PRIMARIES_BT709,
#                               SDL_TRANSFER_CHARACTERISTICS_BT601,
#                               SDL_MATRIX_COEFFICIENTS_BT601,
#                               SDL_CHROMA_LOCATION_NONE),
#     SDL_COLORSPACE_BT601_LIMITED =  /**< Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P601 */
#         SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
#                               SDL_COLOR_RANGE_LIMITED,
#                               SDL_COLOR_PRIMARIES_BT601,
#                               SDL_TRANSFER_CHARACTERISTICS_BT601,
#                               SDL_MATRIX_COEFFICIENTS_BT601,
#                               SDL_CHROMA_LOCATION_LEFT),
#     SDL_COLORSPACE_BT601_FULL =     /**< Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P601 */
#         SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
#                               SDL_COLOR_RANGE_FULL,
#                               SDL_COLOR_PRIMARIES_BT601,
#                               SDL_TRANSFER_CHARACTERISTICS_BT601,
#                               SDL_MATRIX_COEFFICIENTS_BT601,
#                               SDL_CHROMA_LOCATION_LEFT),
#     SDL_COLORSPACE_BT709_LIMITED =  /**< Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P709 */
#         SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
#                               SDL_COLOR_RANGE_LIMITED,
#                               SDL_COLOR_PRIMARIES_BT709,
#                               SDL_TRANSFER_CHARACTERISTICS_BT709,
#                               SDL_MATRIX_COEFFICIENTS_BT709,
#                               SDL_CHROMA_LOCATION_LEFT),
#     SDL_COLORSPACE_BT709_FULL =     /**< Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P709 */
#         SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
#                               SDL_COLOR_RANGE_FULL,
#                               SDL_COLOR_PRIMARIES_BT709,
#                               SDL_TRANSFER_CHARACTERISTICS_BT709,
#                               SDL_MATRIX_COEFFICIENTS_BT709,
#                               SDL_CHROMA_LOCATION_LEFT),
#     SDL_COLORSPACE_BT2020_LIMITED =  /**< Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P2020 */
#         SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
#                               SDL_COLOR_RANGE_LIMITED,
#                               SDL_COLOR_PRIMARIES_BT2020,
#                               SDL_TRANSFER_CHARACTERISTICS_PQ,
#                               SDL_MATRIX_COEFFICIENTS_BT2020_NCL,
#                               SDL_CHROMA_LOCATION_LEFT),
#     SDL_COLORSPACE_BT2020_FULL =     /**< Equivalent to DXGI_COLOR_SPACE_YCBCR_FULL_G22_LEFT_P2020 */
#         SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
#                               SDL_COLOR_RANGE_FULL,
#                               SDL_COLOR_PRIMARIES_BT2020,
#                               SDL_TRANSFER_CHARACTERISTICS_PQ,
#                               SDL_MATRIX_COEFFICIENTS_BT2020_NCL,
#                               SDL_CHROMA_LOCATION_LEFT),
#     SDL_COLORSPACE_RGB_DEFAULT = SDL_COLORSPACE_SRGB,
#     SDL_COLORSPACE_YUV_DEFAULT = SDL_COLORSPACE_JPEG
# } SDL_Colorspace;

# typedef struct SDL_PixelFormat
# {
#     SDL_PixelFormatEnum format;
#     SDL_Palette *palette;
#     Uint8 bits_per_pixel;
#     Uint8 bytes_per_pixel;
#     Uint8 padding[2];
#     Uint32 Rmask;
#     Uint32 Gmask;
#     Uint32 Bmask;
#     Uint32 Amask;
#     Uint8 Rloss;
#     Uint8 Gloss;
#     Uint8 Bloss;
#     Uint8 Aloss;
#     Uint8 Rshift;
#     Uint8 Gshift;
#     Uint8 Bshift;
#     Uint8 Ashift;
#     int refcount;
#     struct SDL_PixelFormat *next;
# } SDL_PixelFormat;

# extern DECLSPEC const char* SDLCALL SDL_GetPixelFormatName(SDL_PixelFormatEnum format);
# extern DECLSPEC SDL_bool SDLCALL SDL_GetMasksForPixelFormatEnum(SDL_PixelFormatEnum format,
#                                                             int *bpp,
#                                                             Uint32 * Rmask,
#                                                             Uint32 * Gmask,
#                                                             Uint32 * Bmask,
#                                                             Uint32 * Amask);
# extern DECLSPEC SDL_PixelFormatEnum SDLCALL SDL_GetPixelFormatEnumForMasks(int bpp,
#                                                           Uint32 Rmask,
#                                                           Uint32 Gmask,
#                                                           Uint32 Bmask,
#                                                           Uint32 Amask);
# extern DECLSPEC SDL_PixelFormat * SDLCALL SDL_CreatePixelFormat(SDL_PixelFormatEnum pixel_format);
# extern DECLSPEC void SDLCALL SDL_DestroyPixelFormat(SDL_PixelFormat *format);
# extern DECLSPEC SDL_Palette *SDLCALL SDL_CreatePalette(int ncolors);
# extern DECLSPEC int SDLCALL SDL_SetPixelFormatPalette(SDL_PixelFormat * format,
                                                    #   SDL_Palette *palette);
# extern DECLSPEC int SDLCALL SDL_SetPaletteColors(SDL_Palette * palette,
                                                #  const SDL_Color * colors,
                                                #  int firstcolor, int ncolors);
# extern DECLSPEC void SDLCALL SDL_DestroyPalette(SDL_Palette * palette);
# extern DECLSPEC Uint32 SDLCALL SDL_MapRGB(const SDL_PixelFormat * format,
                                        #   Uint8 r, Uint8 g, Uint8 b);
# extern DECLSPEC Uint32 SDLCALL SDL_MapRGBA(const SDL_PixelFormat * format,
                                        #    Uint8 r, Uint8 g, Uint8 b,
                                        #    Uint8 a);
# extern DECLSPEC void SDLCALL SDL_GetRGB(Uint32 pixel,
                                        # const SDL_PixelFormat * format,
                                        # Uint8 * r, Uint8 * g, Uint8 * b);
# extern DECLSPEC void SDLCALL SDL_GetRGBA(Uint32 pixel,
                                        #  const SDL_PixelFormat * format,
                                        #  Uint8 * r, Uint8 * g, Uint8 * b,
                                        #  Uint8 * a);

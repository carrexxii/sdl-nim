import std/unicode, common, init, bitgen, pixels, rect, properties, gpu, surface, renderer
from iostream import IoStream

# TODO: default colours

const DefaultFontSize = 16

type FontStyleFlag = distinct uint32
FontStyleFlag.gen_bit_ops fontBold, fontItalic, fontUnderline, fontStrikethrough
const fontNormal* = FontStyleFlag 0

type SubstringFlag* = distinct uint32
SubstringFlag.gen_bit_ops(
    _, _, _, _,
    _, _, _, _,
    substrTextStart, substrLineStart, substrLineEnd, substrTextEnd,
)
const substrDirectionMask* = SubstringFlag 0x0000_00FF

type
    UnicodeBomM* {.size: sizeof(cint).} = enum
        Native  = 0xFEFF
        Swapped = 0xFFFE

    Hinting* {.size: sizeof(cint).} = enum
        Normal
        Light
        Mono
        None
        LightSubpixel

    HorizontalAlignment* {.size: sizeof(cint).} = enum
        Invalid = -1
        Left    = 0
        Centre  = 1
        Right   = 2

    Direction* {.size: sizeof(cint).} = enum
        Invalid = 0
        Ltr = 4
        Rtl
        Ttb
        Btt

    ImageKind* {.size: sizeof(cint).} = enum
        Invalid
        Alpha
        Colour
        Sdf

    DrawCommand* {.size: sizeof(cint).} = enum
        Noop
        Fill
        Copy

    TextEngineWinding* {.size: sizeof(cint).} = enum
        Invalid = -1
        Clockwise
        CounterClockwise

type
    Font*       = distinct pointer
    TextLayout* = distinct pointer

    Text* = distinct pointer
    TextObj* = object
        text*   : cstring
        ln_cnt* : cint
        ref_cnt*: cint
        data*   : ptr TextData

    Substring* = object
        flags*      : SubstringFlag
        offset*     : int32
        len*        : int32
        ln_idx*     : int32
        cluster_idx*: int32
        rect*       : SdlRect

    AtlasDrawSequence* = object
        atlas_tex*: gpu.Texture
        xy*, uv*  : ptr SdlPointF
        vtx_cnt*  : int32
        idxs*     : ptr int32
        idx_cnt*  : int32
        img_kind* : ImageKind
        next*     : ptr AtlasDrawSequence

    FillOperation* = object
        cmd* : DrawCommand
        rect*: SdlRect

    CopyOperation* = object
        cmd*        : DrawCommand
        text_offset*: int32
        glyph_font* : Font
        glyph_idx*  : uint32
        src*, dst*  : SdlRect
        _           : pointer

    DrawOperation* = ptr DrawOperationObj
    DrawOperationObj* {.union.} = object
        cmd* : DrawCommand
        fill*: FillOperation
        copy*: CopyOperation

    TextData* = object
        font*               : Font
        colour*             : SdlColourF
        needs_layout_update*: bool
        layout*             : TextLayout
        x*, y*, w*, h*      : int32
        op_cnt*             : int32
        ops*                : DrawOperation
        cluster_cnt*        : int32
        clusters*           : Substring
        props*              : PropertiesId
        needs_engine_update*: bool
        engine*             : TextEngine
        engine_text*        : pointer

    TextEngine* = distinct pointer
    TextEngineObj* = object
        version*     : uint32
        user_data*   : pointer
        create_text* : proc(user_data: pointer; text: Text): bool {.cdecl.}
        destroy_text*: proc(user_data: pointer; text: Text)       {.cdecl.}

template `.`*(engine: TextEngine; field: untyped): untyped = cast[ptr TextEngineObj](engine).field
template `.`*(text: Text; field: untyped): untyped         = cast[ptr TextObj](engine).field

proc TTF_CloseFont*(font: Font) {.importc, cdecl, dynlib: SdlTtfLib.}
proc `=destroy`*(font: Font) =
    TTF_CloseFont font

proc TTF_DestroySurfaceTextEngine*(engine: TextEngine)  {.importc, cdecl, dynlib: SdlTtfLib.}
proc TTF_DestroyRendererTextEngine*(engine: TextEngine) {.importc, cdecl, dynlib: SdlTtfLib.}
proc TTF_DestroyGPUTextEngine*(engine: TextEngine)      {.importc, cdecl, dynlib: SdlTtfLib.}
proc `=destroy`*(engine: TextEngine) =
    case cast[int](engine.user_data)
    of 1: TTF_DestroyRendererTextEngine engine
    of 2: TTF_DestroyGPUTextEngine engine
    else: TTF_DestroySurfaceTextEngine engine

proc TTF_DestroyText*(text: Text) {.importc, cdecl, dynlib: SdlTtfLib.}
proc `=destroy`*(text: Text) =
    TTF_DestroyText text

converter `Font -> bool`*(font: Font): bool               = nil != pointer font
converter `TextLayout -> bool`*(tlay: TextLayout): bool   = nil != pointer tlay
converter `Text -> bool`*(text: Text): bool               = nil != pointer text
converter `TextEngine -> bool`*(engine: TextEngine): bool = nil != pointer engine

proc `$`*(font: Font): string = "0x" & $cast[uint](font)

{.push importc, cdecl, dynlib: SdlTtfLib.}
proc TTF_Version*(): Version
proc TTF_GetFreeTypeVersion*(major, minor, patch: ptr cint)
proc TTF_GetHarfBuzzVersion*(major, minor, patch: ptr cint)
proc TTF_Init*(): bool
proc TTF_OpenFont*(file: cstring; pt_sz: cfloat): Font
proc TTF_OpenFontIO*(src: IoStream; close_io: bool; pt_sz: cfloat): Font
proc TTF_OpenFontWithProperties*(props: PropertiesId): Font
proc TTF_CopyFont*(existing_font: Font): Font
proc TTF_Quit*()
proc TTF_WasInit*(): cint
proc TTF_GetFontProperties*(font: Font): PropertiesId
proc TTF_GetFontGeneration*(font: Font): uint32
proc TTF_AddFallbackFont*(font, fallback: Font): bool
proc TTF_RemoveFallbackFont*(font, fallback: Font)
proc TTF_ClearFallbackFonts*(font: Font)
proc TTF_SetFontSize*(font: Font; pt_sz: cfloat): bool
proc TTF_SetFontSizeDPI*(font: Font; pt_sz: cfloat; hdpi, vdpi: cint): bool
proc TTF_GetFontSize*(font: Font): cfloat
proc TTF_GetFontDPI*(font: Font; hdpi, vdpi: ptr cint): bool
proc TTF_SetFontStyle*(font: Font; style: FontStyleFlag)
proc TTF_GetFontStyle*(font: Font): FontStyleFlag
proc TTF_SetFontOutline*(font: Font; outline: cint): bool
proc TTF_GetFontOutline*(font: Font): cint
proc TTF_SetFontHinting*(font: Font; hinting: Hinting)
proc TTF_GetNumFontFaces*(font: Font): cint
proc TTF_GetFontHinting*(font: Font): Hinting
proc TTF_SetFontSDF*(font: Font; enabled: bool): bool
proc TTF_GetFontSDF*(font: Font): bool
proc TTF_SetFontWrapAlignment*(font: Font; align: HorizontalAlignment)
proc TTF_GetFontWrapAlignment*(font: Font): HorizontalAlignment
proc TTF_GetFontHeight*(font: Font): cint
proc TTF_GetFontAscent*(font: Font): cint
proc TTF_GetFontDescent*(font: Font): cint
proc TTF_SetFontLineSkip*(font: Font; lineskip: cint)
proc TTF_GetFontLineSkip*(font: Font): cint
proc TTF_SetFontKerning*(font: Font; enabled: bool)
proc TTF_GetFontKerning*(font: Font): bool
proc TTF_FontIsFixedWidth*(font: Font): bool
proc TTF_FontIsScalable*(font: Font): bool
proc TTF_GetFontFamilyName*(font: Font): cstring
proc TTF_GetFontStyleName*(font: Font): cstring
proc TTF_SetFontDirection*(font: Font; dir: Direction): bool
proc TTF_GetFontDirection*(font: Font): Direction

proc TTF_StringToTag*(string: cstring): uint32
proc TTF_TagToString*(tag: uint32; str: cstring; sz: csize_t)
proc TTF_SetFontScript*(font: Font; script: uint32): bool
proc TTF_GetFontScript*(font: Font): uint32
proc TTF_GetGlyphScript*(ch: uint32): uint32
proc TTF_SetFontLanguage*(font: Font; lang_bcp47: cstring): bool
proc TTF_FontHasGlyph*(font: Font; ch: uint32): bool
proc TTF_GetGlyphImage*(font: Font; ch: uint32; image_kind: ptr ImageKind): Surface
proc TTF_GetGlyphImageForIndex*(font: Font; glyph_idx: uint32; image_kind: ptr ImageKind): Surface
proc TTF_GetGlyphMetrics*(font: Font; ch: uint32; minx, maxx, miny, maxy, advance: ptr cint): bool
proc TTF_GetGlyphKerning*(font: Font; prev_ch, ch: uint32; kerning: ptr cint): bool
proc TTF_GetStringSize*(font: Font; text: cstring; len: csize_t; w, h: ptr cint): bool
proc TTF_GetStringSizeWrapped*(font: Font; text: cstring; len: csize_t; wrap_w: cint; w, h: ptr cint): bool
proc TTF_MeasureString*(font: Font; text: cstring, len: csize_t; max_w: cint; measured_w: ptr cint; measured_len: ptr csize_t): bool

proc TTF_RenderText_Solid*(font: Font; text: cstring; len: csize_t; fg: SdlColour): Surface
proc TTF_RenderText_Solid_Wrapped*(font: Font; text: cstring; len: csize_t; fg: SdlColour; wrap_len: cint): Surface
proc TTF_RenderGlyph_Solid*(font: Font; ch: uint32; fg: SdlColour): Surface
proc TTF_RenderText_Shaded*(font: Font; text: cstring; len: csize_t; fg, bg: SdlColour): Surface
proc TTF_RenderText_Shaded_Wrapped*(font: Font; text: cstring; len: csize_t; fg, bg: SdlColour; wrap_w: cint): Surface
proc TTF_RenderGlyph_Shaded*(font: Font; ch: uint32; fg, bg: SdlColour): Surface
proc TTF_RenderText_Blended*(font: Font; text: cstring; len: csize_t, fg: SdlColour): Surface
proc TTF_RenderText_Blended_Wrapped*(font: Font; text: cstring; len: csize_t; fg: SdlColour; wrap_w: cint): Surface
proc TTF_RenderGlyph_Blended*(font: Font; ch: uint32; fg: SdlColour): Surface
proc TTF_RenderText_LCD*(font: Font; text: cstring; len: csize_t; fg, bg: SdlColour): Surface
proc TTF_RenderText_LCD_Wrapped*(font: Font; text: cstring; len: csize_t; fg, bg: SdlColour; wrap_w: cint): Surface
proc TTF_RenderGlyph_LCD*(font: Font; ch: uint32; fg, bg: SdlColour): Surface

proc TTF_CreateSurfaceTextEngine(): TextEngine
proc TTF_DrawSurfaceText*(text: Text; x, y: cint; surf: Surface): bool
proc TTF_CreateRendererTextEngine(ren: Renderer): TextEngine
proc TTF_CreateRendererTextEngineWithProperties(props: PropertiesId): TextEngine
proc TTF_DrawRendererText*(text: Text; x, y: cfloat): bool
proc TTF_CreateGPUTextEngine(dev: Device): TextEngine
proc TTF_CreateGPUTextEngineWithProperties(props: PropertiesId): TextEngine
proc TTF_GetGPUTextDrawData*(text: Text): ptr AtlasDrawSequence
proc TTF_SetGPUTextEngineWinding*(engine: TextEngine; winding: TextEngineWinding)
proc TTF_GetGPUTextEngineWinding*(engine: TextEngine): TextEngineWinding

proc TTF_CreateText*(engine: TextEngine; font: Font; text: cstring; len: csize_t): Text
proc TTF_GetTextProperties*(text: Text): PropertiesId
proc TTF_SetTextEngine*(text: Text; engine: TextEngine): bool
proc TTF_GetTextEngine*(text: Text): TextEngine
proc TTF_SetTextFont*(text: Text; font: Font): bool
proc TTF_GetTextFont*(text: Text): Font
proc TTF_SetTextDirection*(text: Text; dir: Direction): bool
proc TTF_GetTextDirection*(text: Text): Direction
proc TTF_SetTextScript*(text: Text; script: uint32): bool
proc TTF_GetTextScript*(text: Text): uint32
proc TTF_SetTextColor*(text: Text; r, g, b, a: uint8): bool
proc TTF_SetTextColorFloat*(text: Text; r, g, b, a: cfloat): bool
proc TTF_GetTextColor*(text: Text; r, g, b, a: ptr uint8): bool
proc TTF_GetTextColorFloat*(text: Text; r, g, b, a: ptr cfloat): bool
proc TTF_SetTextPosition*(text: Text; x, y: cint): bool
proc TTF_GetTextPosition*(text: Text; x, y: ptr cint): bool
proc TTF_SetTextWrapWidth*(text: Text; wrap_w: cint): bool
proc TTF_GetTextWrapWidth*(text: Text; wrap_w: ptr cint): bool
proc TTF_SetTextWrapWhitespaceVisible*(text: Text; visible: bool): bool
proc TTF_TextWrapWhitespaceVisible*(text: Text): bool
proc TTF_SetTextString*(text: Text; string: cstring; len: csize_t): bool
proc TTF_InsertTextString*(text: Text; offset: cint; str: cstring; len: csize_t): bool
proc TTF_AppendTextString*(text: Text; str: cstring; len: csize_t): bool
proc TTF_DeleteTextString*(text: Text; offset, len: cint): bool
proc TTF_GetTextSize*(text: Text; w, h: ptr cint): bool
proc TTF_GetTextSubString*(text: Text; offset: cint; substr: ptr Substring): bool
proc TTF_GetTextSubStringForLine*(text: Text; line: cint; substr: ptr Substring): bool
proc TTF_GetTextSubStringsForRange*(text: Text; offset, len: cint; cnt: ptr cint): ptr UncheckedArray[Substring]
proc TTF_GetTextSubStringForPoint*(text: Text; x, y: cint; substr: ptr Substring): bool
proc TTF_GetPreviousTextSubString*(text: Text; substr, prev: ptr Substring): bool
proc TTF_GetNextTextSubString*(text: Text; substr, next: ptr Substring): bool
proc TTF_UpdateText*(text: Text): bool
{.pop.}

{.push inline.}

# TODO: tags, scripts

proc version*(): Version = TTF_Version()
proc freetype_version*(): Version =
    var major, minor, patch: cint
    TTF_GetFreeTypeVersion major.addr, minor.addr, patch.addr
    version major, minor, patch
proc harfbuzz_version*(): Version =
    var major, minor, patch: cint
    TTF_GetHarfBuzzVersion major.addr, minor.addr, patch.addr
    version major, minor, patch

proc init*(): bool {.discardable.} =
    result = TTF_Init()
    sdl_assert result, "Failed to initialize SDL_TTF"

proc open_font*(path: string; sz: SomeNumber): Font =
    result = TTF_OpenFont(cstring path, cfloat sz)
    sdl_assert result, &"Failed to open font file from '{path}' ({sz}pt)"
proc open_font*(stream: IoStream; sz: SomeFloat; close_io = false): Font =
    result = TTF_OpenFontIO(stream, close_io, cfloat sz)
    sdl_assert result, &"Failed to open font from stream '{cast[uint](stream)}' ({sz}pt)"
proc open_font*(props: PropertiesId): Font =
    result = TTF_OpenFontWithProperties(props)
    sdl_assert result, &"Failed to open font with properties ({cast[uint](props)})"

proc copy*(font: Font): Font =
    result = TTF_CopyFont(font)
    sdl_assert result, "Failed to copy font"

proc quit*()              = TTF_Quit()
proc init_count*(): int32 = int32 TTF_WasInit()

proc properties*(font: Font): PropertiesId = TTF_GetFontProperties font
proc generation*(font: Font): uint32 =
    result = TTF_GetFontGeneration(font)
    sdl_assert result != 0, &"Failed to get generation for font '{font}'"

proc add_fallback*(font, fallback: Font): bool {.discardable.} =
    result = TTF_AddFallbackFont(font, fallback)
    sdl_assert result, &"Failed to set fallback '{fallback}' for font '{font}'"

proc remove_fallback*(font, fallback: Font) = TTF_RemoveFallbackFont font, fallback
proc remove_fallbacks*(font: Font)          = TTF_ClearFallbackFonts font

proc size*(font: Font): float32                       = float32 TTF_GetFontSize font
proc style*(font: Font): FontStyleFlag                = TTF_GetFontStyle font
proc outline*(font: Font): int32                      = int32 TTF_GetFontOutline font
proc face_count*(font: Font): int32                   = int32 TTF_GetNumFontFaces font
proc hinting*(font: Font): Hinting                    = TTF_GetFontHinting font
proc sdf*(font: Font): bool                           = TTF_GetFontSDF font
proc wrap_alignment*(font: Font): HorizontalAlignment = TTF_GetFontWrapAlignment font
proc height*(font: Font): int32                       = int32 TTF_GetFontHeight font
proc ascent*(font: Font): int32                       = int32 TTF_GetFontAscent font
proc descent*(font: Font): int32                      = int32 TTF_GetFontDescent font
proc line_skip*(font: Font): int32                    = int32 TTF_GetFontLineSkip font
proc kerning*(font: Font): bool                       = TTF_GetFontKerning font
proc is_fixed_width*(font: Font): bool                = TTF_FontIsFixedWidth font
proc is_scalable*(font: Font): bool                   = TTF_FontIsScalable font
proc family_name*(font: Font): string                 = $TTF_GetFontFamilyName(font)
proc style_name*(font: Font): string                  = $TTF_GetFontStyleName(font)
proc direction*(font: Font): Direction                = TTF_GetFontDirection font
proc has_glyph*(font: Font; ch: Rune): bool           = TTF_FontHasGlyph font, uint32 ch
proc dpi*(font: Font): tuple[hdpi, vdpi: int32] =
    var hdpi, vdpi: cint
    let success = TTF_GetFontDPI(font, hdpi.addr, vdpi.addr)
    sdl_assert success, &"Failed to get dpi for font '{font}'"
    (int32 hdpi, int32 vdpi)

proc set_size_dpi*(font: Font; pt_sz: SomeNumber; hdpi, vdpi: SomeInteger): bool {.discardable.} =
    result = TTF_SetFontSizeDPI(font, cfloat pt_sz, cint hdpi, cint vdpi)
    sdl_assert result, &"Failed to set font size to {pt_sz} and DPI to {hdpi}/{vdpi}"

proc set_size*(font: Font; pt_sz: SomeNumber): bool {.discardable.} =
    result = TTF_SetFontSize(font, cfloat pt_sz)
    sdl_assert result, &"Failed to set font size to {pt_sz}"
proc `size=`*(font: Font; pt_sz: SomeNumber) = font.set_size pt_sz

proc set_style*(font: Font; style: FontStyleFlag) = TTF_SetFontStyle font, style
proc `style=`*(font: Font; style: FontStyleFlag)  = font.set_style style

proc set_outline*(font: Font; outline: SomeInteger): bool {.discardable.} =
    result = TTF_SetFontOutline(font, cint outline)
    sdl_assert result, &"Failed to set font outline to {outline}"
proc set_outline*(font: Font; outline: SomeInteger) = font.set_outline outline

proc set_hinting*(font: Font; hinting: Hinting) = TTF_SetFontHinting font, hinting
proc `hinting=`*(font: Font; hinting: Hinting)  = font.set_hinting hinting

proc set_sdf*(font: Font; enabled: bool): bool {.discardable.} =
    result = TTF_SetFontSDF(font, enabled)
    sdl_assert result, &"Failed to set font SDF to {enabled}"
proc `sdf=`*(font: Font; enabled: bool) = font.set_sdf enabled

proc set_wrap_alignment*(font: Font; align: HorizontalAlignment) = TTF_SetFontWrapAlignment font, align
proc `wrap_alignment=`*(font: Font; align: HorizontalAlignment)  = font.set_wrap_alignment align

proc set_line_skip*(font: Font; line_skip: SomeInteger) = TTF_SetFontLineSkip font, line_skip
proc `line_skip=`*(font: Font; line_skip: SomeInteger)  = font.set_line_skip cint line_skip

proc set_kerning*(font: Font; enabled: bool) = TTF_SetFontKerning font, enabled
proc `kerning=`*(font: Font; enabled: bool)  = font.set_kerning enabled

proc set_direction*(font: Font; dir: Direction): bool {.discardable.} =
    result = TTF_SetFontDirection(font, dir)
    sdl_assert result, &"Failed to set font direction to {dir}"
proc `direction=`*(font: Font; dir: Direction) = font.set_direction dir

proc set_language*(font: Font; lang_bcp47: string): bool {.discardable.} =
    result = TTF_SetFontLanguage(font, cstring lang_bcp47)
    sdl_assert result, &"Failed to set font language to '{lang_bcp47}'"
proc `language=`*(font: Font; lang_bcp47: string) = font.set_language lang_bcp47

proc glyph_image*(font: Font; ch: Rune): tuple[img: Surface; kind: ImageKind] =
    result.img = TTF_GetGlyphImage(font, uint32 ch, result.kind.addr)
    sdl_assert result.img, &"Failed to get image for glyph '{ch}' from font '{font}'"

proc glyph_image*(font: Font; idx: SomeInteger): tuple[img: Surface; kind: ImageKind] =
    result.img = TTF_GetGlyphImageForIndex(font, uint32 idx, result.kind.addr)
    sdl_assert result, &"Failed to get image for glyph index '{idx}' from font '{font}' (image kind: {img_kind})"

proc metrics*(font: Font; ch: Rune): tuple[minx, maxx, miny, maxy, adv: int32] =
    let success = TTF_GetGlyphMetrics(font, uint32 ch, result.minx.addr, result.maxx.addr, result.miny.addr, result.maxy.addr, result.adv.addr)
    sdl_assert success, &"Failed to get metrics for glyph '{ch}' from font '{font}'"

proc kerning*(font: Font; prev_ch, ch: Rune): int32 =
    let success = TTF_GetGlyphKerning(font, uint32 prev_ch, uint32 ch, result.addr)
    sdl_assert success, &"Failed to get kerning values for font '{font}' from '{prev_ch}' to '{ch}'"

proc size*(font: Font; text: string): tuple[w, h: int32] =
    let success = TTF_GetStringSize(font, cstring text, csize_t text.len, result.w.addr, result.h.addr)
    sdl_assert success, &"Failed to get string size for '{text}' from font '{font}'"

proc size_wrapped*(font: Font; text: string; wrap_w: SomeInteger): tuple[w, h: int32] =
    let success = TTF_GetStringSizeWrapped(font, cstring text, csize_t text.len, cint wrap_w, result.w.addr, result.h.addr)
    sdl_assert success, &"Failed to get string size for '{text}' wrapped at '{wrap_w}' from font '{font}'"

proc measure*(font: Font; text: string; max_w: SomeInteger = 0): tuple[w, len: int32] =
    let success = TTF_MeasureString(font, cstring text, csize_t text.len, cint max_w, result.w.addr, result.len.addr)
    sdl_assert success, &"Failed to measure string '{text}' with max width {max_w} from font '{font}'"

proc render_solid*(font: Font; text: string; fg: SdlColour = Black; wrap_len: SomeNumber = 0): Surface =
    result =
        if wrap_len == 0:
            TTF_RenderText_Solid font, cstring text, csize_t text.len, fg
        else:
            TTF_RenderText_Solid_Wrapped font, cstring text, csize_t text.len, fg, cint wrap_len
    sdl_assert result, &"Failed to render solid text '{text}' with font '{font}' (colour: {fg}; wrap length: {wrap_len})"

proc render_shaded*(font: Font; text: string; fg: SdlColour = Black; bg: SdlColour = White; wrap_len: SomeNumber = 0): Surface =
    result =
        if wrap_len == 0:
            TTF_RenderText_Shaded font, cstring text, csize_t text.len, fg, bg
        else:
            TTF_RenderText_Shaded_Wrapped font, cstring text, csize_t text.len, fg, bg, cint wrap_len
    sdl_assert result, &"Failed to render shaded text '{text}' with font '{font}' (fg: {fg}; bg: {bg}; wrap length: {wrap_len})"

proc render_blended*(font: Font; text: string; fg: SdlColour = Black; wrap_len: SomeNumber = 0): Surface =
    result =
        if wrap_len == 0:
            TTF_RenderText_Blended font, cstring text, csize_t text.len, fg
        else:
            TTF_RenderText_Blended_Wrapped font, cstring text, csize_t text.len, fg, cint wrap_len
    sdl_assert result, &"Failed to render blended text '{text}' with font '{font}' (fg: {fg}; wrap length: {wrap_len})"

proc render_lcd*(font: Font; text: string; fg: SdlColour = Black; bg: SdlColour = White; wrap_len: SomeNumber = 0): Surface =
    result =
        if wrap_len == 0:
            TTF_RenderText_LCD font, cstring text, csize_t text.len, fg, bg
        else:
            TTF_RenderText_LCD_Wrapped font, cstring text, csize_t text.len, fg, bg, cint wrap_len
    sdl_assert result, &"Failed to render LCD text '{text}' with font '{font}' (fg: {fg}; bg: {bg}; wrap length: {wrap_len})"

proc render_solid*(font: Font; ch: Rune; fg: SdlColour = Black): Surface =
    result = TTF_RenderGlyph_Solid(font, uint32 ch, fg)
    sdl_assert result, &"Failed to render solid glyph '{ch}' with font '{font}' (fg: {fg})"

proc render_shaded*(font: Font; ch: Rune; fg: SdlColour = Black; bg: SdlColour = White): Surface =
    result = TTF_RenderGlyph_Shaded(font, uint32 ch, fg, bg)
    sdl_assert result, &"Failed to render shaded glyph '{ch}' with font '{font}' (fg: {fg}; bg: {bg})"

proc render_blended*(font: Font; ch: Rune; fg: SdlColour = Black): Surface =
    result = TTF_RenderGlyph_Blended(font, uint32 ch, fg)
    sdl_assert result, &"Failed to render blended glyph '{ch}' with font '{font}' (fg: {fg})"

proc render_lcd*(font: Font; ch: Rune; fg: SdlColour = Black; bg: SdlColour = White): Surface =
    result = TTF_RenderGlyph_LCD(font, uint32 ch, fg, bg)
    sdl_assert result, &"Failed to render LCD glyph '{ch}' with font '{font}' (fg: {fg}; bg: {bg})"

proc create_text_engine*(): TextEngine =
    result = TTF_CreateSurfaceTextEngine()
    sdl_assert result, "Failed to create surface text engine"
proc create_text_engine*(ren: Renderer): TextEngine =
    result = TTF_CreateRendererTextEngine(ren)
    sdl_assert result, "Failed to create renderer text engine"
proc create_text_engine*(dev: Device): TextEngine =
    result = TTF_CreateGPUTextEngine(dev)
    sdl_assert result, "Failed to create text engine from GPU device"
proc create_text_engine*(props: PropertiesId; from_gpu: bool = false): TextEngine =
    result =
        if from_gpu:
            TTF_CreateRendererTextEngineWithProperties props
        else:
            TTF_CreateGPUTextEngineWithProperties props
    sdl_assert result, "Failed to create text engine from properties (from GPU: {from_gpu})"

proc draw*(surf: Surface; text: Text; x, y: SomeInteger): bool {.discardable.} =
    result = TTF_DrawSurfaceText(text, cint x, cint y, surf)
    sdl_assert result, &"Failed to draw text '{text}' to surface at ({x}, {y})"
proc draw*(text: Text; x, y: SomeNumber): bool {.discardable.} =
    result = TTF_DrawRendererText(text, cfloat x, cfloat y)
    sdl_assert result, &"Failed to draw text '{text}' with renderer at ({x}, {y})"

proc draw_data*(text: Text): ptr AtlasDrawSequence =
    result = TTF_GetGPUTextDrawData(text)
    sdl_assert result != nil, &"Failed to get GPU text draw data for text '{text}'"

proc winding*(engine: TextEngine): TextEngineWinding = TTF_GetGPUTextEngineWinding engine

proc set_winding*(engine: TextEngine; winding: TextEngineWinding) = TTF_SetGPUTextEngineWinding engine, winding
proc `winding=`*(engine: TextEngine; winding: TextEngineWinding)  = engine.set_winding winding

proc create_text*(engine: TextEngine; font: Font; text: string): Text =
    result = TTF_CreateText(engine, font, cstring text, csize_t text.len)
    sdl_assert result, &"Failed to create text from engine '{text}'"

proc properties*(text: Text): PropertiesId     = TTF_GetTextProperties text
proc engine*(text: Text): TextEngine           = TTF_GetTextEngine text
proc font*(text: Text): Font                   = TTF_GetTextFont text
proc direction*(text: Text): Direction         = TTF_GetTextDirection text
proc whitespace_visible*(text: Text): bool     = TTF_TextWrapWhitespaceVisible text
proc wrap_width*(text: Text): int32 =
    let success = TTF_GetTextWrapWidth(text, result.addr)
    sdl_assert success, &"Failed to get wrap width for text '{text}'"
proc position*(text: Text): tuple[x, y: int32] =
    let success = TTF_GetTextPosition(text, result.x.addr, result.y.addr)
    sdl_assert success, &"Failed to get position for text '{text}'"
proc colour*(text: Text): SdlColour =
    let success = TTF_GetTextColor(text, result.r.addr, result.g.addr, result.b.addr, result.a.addr)
    sdl_assert success, &"Failed to get colour for text '{text}'"
proc colourf*(text: Text): SdlColourF =
    let success = TTF_GetTextColorFloat(text, result.r.addr, result.g.addr, result.b.addr, result.a.addr)
    sdl_assert success, &"Failed to get colourf for text '{text}'"

proc set_engine*(text: Text; engine: TextEngine): bool {.discardable.} =
    result = TTF_SetTextEngine(text, engine)
    sdl_assert result, &"Failed to set engine for text '{text}'"
proc `engine=`*(text: Text; engine: TextEngine) = text.set_engine engine

proc set_font*(text: Text; font: Font): bool {.discardable.} =
    result = TTF_SetTextFont(text, font)
    sdl_assert result, &"Failed to set font for text '{text}'"
proc `font=`*(text: Text; font: Font) = text.set_font font

proc set_direction*(text: Text; dir: Direction): bool {.discardable.} =
    result = TTF_SetTextDirection(text, dir)
    sdl_assert result, &"Failed to set direction for text '{text}'"
proc `direction=`*(text: Text; dir: Direction) = text.set_direction dir

proc set_colour*(text: Text; colour: SdlColour | SdlColourF): bool {.discardable.} =
    result =
        when colour is SdlColour:
            TTF_SetTextColor text, colour.r, colour.g, colour.b, colour.g
        else:
            TTF_SetTextColorFloat text, colour.r, colour.g, colour.b, colour.g
    sdl_assert result, &"Failed to set colour for text '{text}' to {colour}"

proc set_position*(text: Text; x, y: SomeNumber): bool {.discardable.} =
    result = TTF_SetTextPosition(text, cint x, cint y)
    sdl_assert result, &"Failed to set position for text '{text}' to ({x}, {y})"
proc `position=`*(text: Text; x, y: SomeNumber) = text.set_position x, y

proc set_position*(text: Text; wrap_w: SomeNumber): bool {.discardable.} =
    result = TTF_SetTextWrapWidth(text, cint wrap_w)
    sdl_assert result, &"Failed to set wrap width for text '{text}' to {wrap_w}"
proc `position=`*(text: Text; wrap_w: SomeNumber) = text.set_position wrap_w

proc set_whitespace_visible*(text: Text; visible: bool): bool {.discardable.} =
    result = TTF_SetTextWrapWhitespaceVisible(text, visible)
    sdl_assert result, &"Failed to set wrap whitespace visibility for text '{text}' to {visible}"
proc `whitespace_visible=`*(text: Text; visible: bool) = text.set_whitespace_visible visible

proc set_str*(text: Text; str: string): bool {.discardable.} =
    result = TTF_SetTextString(text, cstring str, csize_t str.len)
    sdl_assert result, &"Failed to set string for text '{text}' to '{str}'"
proc `str=`*(text: Text; str: string) = text.set_str str

proc insert*(text: Text; str: string; offset: SomeInteger): bool {.discardable.} =
    result = TTF_SetTextString(text, cint offset, cstring str, csize_t str.len)
    sdl_assert result, &"Failed to insert string '{str}' into text '{text}' at {offset}"

proc append*(text: Text; str: string): bool {.discardable.} =
    result = TTF_AppendTextString(text, cstring str, csize_t str.len)
    sdl_assert result, &"Failed to append string '{str}' onto text '{text}'"

proc delete*(text: Text; offset, len: distinct SomeNumber): bool {.discardable.} =
    result = TTF_DeleteTextString(text, cint offset, cint len)
    sdl_assert result, &"Failed to delete from text '{text}' (offset: {offset}; length: {len})"

proc size*(text: Text): tuple[w, h: int32] =
    let success = TTF_GetTextSize(text, result.w.addr, result.h.addr)
    sdl_assert success, &"Failed to get size of text '{text}'"

# FIXME
proc substring*(text: Text; offset: SomeNumber): Substring =
    let success = TTF_GetTextSubString(text, cint offset, result.addr)
    sdl_assert success, &"Failed to get substring from text '{text}' (offset: {offset})"

proc substring*(text: Text; line: SomeNumber): Substring =
    let success = TTF_GetTextSubStringForLine(text, cint line, result.addr)
    sdl_assert success, &"Failed to get substring from text '{text}' (line: {offset})"

# proc substring*(text: Text; range: Slice[SomeInteger]): SubstringArray =
#     result.data = TTF_GetTextSubStringsForRange(text, cint range.a, cint (range.b - range.a), result.len.addr)
#     sdl_assert result.data, &"Failed to get substrings for range {range} for text '{text}'"
proc substring*(text: Text; range: Slice[SomeInteger]): seq[Substring] =
    var cnt: cint
    let data = TTF_GetTextSubStringsForRange(text, cint range.a, cint (range.b - range.a), cnt.addr)
    sdl_assert data, &"Failed to get substrings for range {range} for text '{text}'"

    if data != nil:
        result = new_seq_of_cap[Substring](cnt)
        for i in 0..<cnt:
            result.add $data[i]
        sdl_free data

proc substring*(text: Text; x, y: distinct SomeInteger): Substring =
    let success = TTF_GetTextSubStringForPoint(text, cint x, cint y, result.addr)
    sdl_assert success, &"Failed to get substring for text '{text}' at point ({x}, {y})"

proc update*(text: Text): bool {.discardable.} =
    result = TTF_UpdateText(text)
    sdl_assert result, &"Failed to update text '{text}'"

{.pop.}

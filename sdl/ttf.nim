import common, init, bitgen, pixels, rect, properties, surface, renderer
from std/unicode import Rune, `$`

# TODO: default colours

const
    DefaultFontSize = 16

    PropFontCreateFilenameString*           = cstring "SDL_ttf.font.create.filename"
    PropFontCreateIoStreamPointer*          = cstring "SDL_ttf.font.create.iostream"
    PropFontCreateIoStreamOffsetNumber*     = cstring "SDL_ttf.font.create.iostream.offset"
    PropFontCreateIoStreamAutocloseBoolean* = cstring "SDL_ttf.font.create.iostream.autoclose"
    PropFontCreateSizeFloat*                = cstring "SDL_ttf.font.create.size"
    PropFontCreateFaceNumber*               = cstring "SDL_ttf.font.create.face"
    PropFontCreateHorizontalDpiNumber*      = cstring "SDL_ttf.font.create.hdpi"
    PropFontCreateVerticalDpiNumber*        = cstring "SDL_ttf.font.create.vdpi"

    PropFontFacePointer* = cstring "SDL_ttf.font.face"

type FontStyle = distinct uint32
FontStyle.gen_bit_ops styleBold, styleItalic, styleUnderline, styleStrikethrough
const styleNormal* = FontStyle 0

type
    UnicodeBOM* {.size: sizeof(cint).} = enum
        unicodeNative  = 0xFEFF
        unicodeSwapped = 0xFFFE

    Hinting* {.size: sizeof(cint).} = enum
        hintNormal
        hintLight
        hintMono
        hintNone
        hintLightSubpixel

    HorizontalAlignment* {.size: sizeof(cint).} = enum
        alignInvalid = -1
        alignLeft    = 0
        alignCentre  = 1
        alignRight   = 2

    Direction* {.size: sizeof(cint).} = enum
        dirLtr
        dirRtl
        dirTtb
        dirBtt

    DrawCommand* {.size: sizeof(cint).} = enum
        drawCmdNoop
        drawCmdFill
        drawCmdCopy


type
    Font*       = distinct pointer
    TextLayout* = distinct pointer

    Text* = ptr TextObj
    TextObj* = object
        text*     : cstring
        colour*   : ColourF
        ln_count* : cint
        ref_count*: cint
        _         : TextData

    Substring* = ptr SubstringObj
    SubstringObj* = object
        offset*     : cint
        len*        : cint
        ln_idx*     : cint
        cluster_idx*: cint
        rect*       : Rect

    FillOperation* = ptr FillOperationObj
    FillOperationObj* = object
        cmd* : DrawCommand
        rect*: Rect

    CopyOperation* = ptr CopyOperationObj
    CopyOperationObj* = object
        cmd*        : DrawCommand
        text_offset*: cint
        glyph_index*: uint32
        src*, dst*  : Rect
        _           : pointer

    DrawOperation* = ptr DrawOperationObj
    DrawOperationObj* {.union.} = object
        cmd* : DrawCommand
        fill*: FillOperation
        copy*: CopyOperation

    TextData* = ptr TextDataObj
    TextDataObj* = object
        font*               : Font
        needs_layout_update*: bool
        layout*             : TextLayout
        w*, h*, num_ops*    : cint
        ops*                : DrawOperation
        cluster_count*      : cint
        props*              : PropertyId
        needs_engine_update*: bool
        engine*             : TextEngine
        engine_text*        : pointer

    TextEngine* = ptr TextEngineObj
    TextEngineObj* = object
        version*     : uint32
        user_data*   : pointer
        create_text* : proc(user_data: pointer; text: Text): bool
        destroy_text*: proc(user_data: pointer; text: Text)

converter `Font -> bool`*(font: Font): bool                      = cast[pointer](font) != nil
converter `TextLayout -> bool`*(tlay: TextLayout): bool          = cast[pointer](tlay) != nil
converter `Text -> bool`*(text: Text): bool                      = cast[pointer](text) != nil
converter `Substring -> bool`*(substr: Substring): bool          = cast[pointer](substr) != nil
converter `FillOperation -> bool`*(fill_op: FillOperation): bool = cast[pointer](fill_op) != nil
converter `CopyOperation -> bool`*(copy_op: CopyOperation): bool = cast[pointer](copy_op) != nil
converter `DrawOperation -> bool`*(draw_op: DrawOperation): bool = cast[pointer](draw_op) != nil
converter `TextData -> bool`*(text_data: TextData): bool         = cast[pointer](text_data) != nil
converter `TextEngine -> bool`*(engine: TextEngine): bool        = cast[pointer](engine) != nil

#[ -------------------------------------------------------------------- ]#

using
    font   : Font
    engine : TextEngine
    text   : Text
    surface: Surface

{.push dynlib: SdlTtfLib.}
proc ttf_version*(): Version                                  {.importc: "TTF_Version"           .}
proc ttf_get_freetype_version*(major, minor, patch: ptr cint) {.importc: "TTF_GetFreeTypeVersion".}
proc ttf_get_harfbuzz_version*(major, minor, patch: ptr cint) {.importc: "TTF_GetHarfBuzzVersion".}

proc ttf_init*(): bool                                       {.importc: "TTF_Init"                  .}
proc ttf_open_font*(file: cstring; pt_sz: cfloat): Font      {.importc: "TTF_OpenFont"              .}
proc ttf_open_font_with_properties*(props: PropertyId): Font {.importc: "TTF_OpenFontWithProperties".}
proc ttf_get_font_properties*(font): PropertyId              {.importc: "TTF_GetFontProperties"     .}
proc ttf_close_font*(font)                                   {.importc: "TTF_CloseFont"             .}
proc ttf_quit*()                                             {.importc: "TTF_Quit"                  .}
proc ttf_was_init*(): cint                                   {.importc: "TTF_WasInit"               .}

proc ttf_font_is_fixed_width*(font): bool                                {.importc: "TTF_FontIsFixedWidth"    .}
proc ttf_font_is_scalable*(font): bool                                   {.importc: "TTF_FontIsScalable"      .}
proc ttf_font_has_glyph*(font; ch: uint32): bool                         {.importc: "TTF_FontHasGlyph"        .}
proc ttf_set_font_size*(font; pt_sz: cfloat): bool                       {.importc: "TTF_SetFontSize"         .}
proc ttf_set_font_size_dpi*(font; pt_sz: cfloat; hdpi, vdpi: cint): bool {.importc: "TTF_SetFontSizeDPI"      .}
proc ttf_set_font_style*(font; style: FontStyle)                         {.importc: "TTF_SetFontStyle"        .}
proc ttf_get_font_style*(font): FontStyle                                {.importc: "TTF_GetFontStyle"        .}
proc ttf_set_font_outline*(font; outline: cint): bool                    {.importc: "TTF_SetFontOutline"      .}
proc ttf_get_font_outline*(font): cint                                   {.importc: "TTF_GetFontOutline"      .}
proc ttf_set_font_hinting*(font; hinting: Hinting)                       {.importc: "TTF_SetFontHinting"      .}
proc ttf_get_font_hinting*(font): Hinting                                {.importc: "TTF_GetFontHinting"      .}
proc ttf_get_font_sdf*(font): bool                                       {.importc: "TTF_GetFontSDF"          .}
proc ttf_set_font_sdf*(font; enabled: bool): bool                        {.importc: "TTF_SetFontSDF"          .}
proc ttf_set_font_kerning*(font; enabled: bool)                          {.importc: "TTF_SetFontKerning"      .}
proc ttf_get_font_kerning*(font): bool                                   {.importc: "TTF_GetFontKerning"      .}
proc ttf_get_font_generation*(font): uint32                              {.importc: "TTF_GetFontGeneration"   .}
proc ttf_get_font_size*(font): cfloat                                    {.importc: "TTF_GetFontSize"         .}
proc ttf_get_font_dpi*(font; hdpi, vdpi: ptr cint): bool                 {.importc: "TTF_GetFontDPI"          .}
proc ttf_set_font_wrap_alignment*(font; align: HorizontalAlignment)      {.importc: "TTF_SetFontWrapAlignment".}
proc ttf_get_font_wrap_alignment*(font): HorizontalAlignment             {.importc: "TTF_GetFontWrapAlignment".}
proc ttf_get_font_height*(font): cint                                    {.importc: "TTF_GetFontHeight"       .}
proc ttf_get_font_ascent*(font): cint                                    {.importc: "TTF_GetFontAscent"       .}
proc ttf_get_font_descent*(font): cint                                   {.importc: "TTF_GetFontDescent"      .}
proc ttf_get_font_line_skip*(font): cint                                 {.importc: "TTF_GetFontLineSkip"     .}
proc ttf_get_font_family_name*(font): cstring                            {.importc: "TTF_GetFontFamilyName"   .}
proc ttf_get_font_style_name*(font): cstring                             {.importc: "TTF_GetFontStyleName"    .}
proc ttf_set_font_direction*(font; dir: Direction): bool                 {.importc: "TTF_SetFontDirection"    .}
proc ttf_set_font_script*(font; script: cstring): bool                   {.importc: "TTF_SetFontScript"       .}
proc ttf_set_font_language*(font; lang_bcp47: cstring): bool             {.importc: "TTF_SetFontLanguage"     .}
proc ttf_get_font_direction*(font): Direction                            {.importc: "TTF_GetFontDirection"    .}

proc ttf_get_glyph_script*(ch: uint32; script: cstring; script_sz: csize_t): bool                           {.importc: "TTF_GetGlyphScript"       .}
proc ttf_get_glyph_image*(font; ch: uint32): Surface                                                        {.importc: "TTF_GetGlyphImage"        .}
proc ttf_get_glyph_image_for_index*(font; glyph_index: uint32): Surface                                     {.importc: "TTF_GetGlyphImageForIndex".}
proc ttf_get_glyph_metrics*(font; ch: uint32; min_x, max_x, min_y, max_y, adv: ptr cint): bool              {.importc: "TTF_GetGlyphMetrics"      .}
proc ttf_get_glyph_kerning*(font; prev_ch, ch: uint32; kerning: ptr cint): bool                             {.importc: "TTF_GetGlyphKerning"      .}
proc ttf_get_string_size*(font; text: cstring; len: csize_t; w, h: ptr cint): bool                          {.importc: "TTF_GetStringSize"        .}
proc ttf_get_string_size_wrapped*(font; text: cstring; len: csize_t; wrap_len: cint; w, h: ptr cint): bool  {.importc: "TTF_GetStringSizeWrapped" .}
proc ttf_measure_string*(font; text: cstring; len: csize_t; measure_w: cint; extent, count: ptr cint): bool {.importc: "TTF_MeasureString"        .}

proc ttf_render_text_shaded*(font; text: cstring; len: csize_t; fg, bg: Colour): Surface                         {.importc: "TTF_RenderText_Shaded"         .}
proc ttf_render_text_shaded_wrapped*(font; text: cstring; len: csize_t; fg, bg: Colour; wrap_len: cint): Surface {.importc: "TTF_RenderText_Shaded_Wrapped" .}
proc ttf_render_glyph_shaded*(font; ch: uint32; fg, bg: Colour): Surface                                         {.importc: "TTF_RenderGlyph_Shaded"        .}
proc ttf_render_text_blended*(font; text: cstring; len: csize_t; fg: Colour): Surface                            {.importc: "TTF_RenderText_Blended"        .}
proc ttf_render_text_blended_wrapped*(font; text: cstring; len: csize_t; fg: Colour; wrap_len: cint): Surface    {.importc: "TTF_RenderText_Blended_Wrapped".}
proc ttf_render_glyph_blended*(font; ch: uint32; fg: Colour): Surface                                            {.importc: "TTF_RenderGlyph_Blended"       .}
proc ttf_render_text_lcd*(font; text: cstring; len: csize_t; fg, bg: Colour): Surface                            {.importc: "TTF_RenderText_LCD"            .}
proc ttf_render_text_lcd_wrapped*(font; text: cstring; len: csize_t; fg, bg: Colour; wrap_len: cint): Surface    {.importc: "TTF_RenderText_LCD_Wrapped"    .}
proc ttf_render_glyph_lcd*(font; ch: uint32; fg, bg: Colour): Surface                                            {.importc: "TTF_RenderGlyph_LCD"           .}

proc ttf_create_surface_text_engine*(): TextEngine                                             {.importc: "TTF_CreateSurfaceTextEngine"  .}
proc ttf_draw_surface_text*(text; x, y: cint; surface): bool                                   {.importc: "TTF_DrawSurfaceText"          .}
proc ttf_destroy_surface_text_engine*(engine)                                                  {.importc: "TTF_DestroySurfaceTextEngine" .}
proc ttf_create_renderer_text_engine*(renderer: ptr Renderer): TextEngine                      {.importc: "TTF_CreateRendererTextEngine" .}
proc ttf_draw_renderer_text*(text; x, y: cfloat): bool                                         {.importc: "TTF_DrawRendererText"         .}
proc ttf_destroy_renderer_text_engine*(engine)                                                 {.importc: "TTF_DestroyRendererTextEngine".}
proc ttf_create_text*(engine; font; text: cstring; len: csize_t): Text                         {.importc: "TTF_CreateText"               .}
proc ttf_create_text_wrapped*(engine; font; text: cstring; len: csize_t; wrap_len: cint): Text {.importc: "TTF_CreateText_Wrapped"       .}
proc ttf_get_text_properties*(text): PropertyId                                                {.importc: "TTF_GetTextProperties"        .}
proc ttf_set_text_engine*(text; engine): bool                                                  {.importc: "TTF_SetTextEngine"            .}
proc ttf_get_text_engine*(text): TextEngine                                                    {.importc: "TTF_GetTextEngine"            .}
proc ttf_set_text_font*(text; font): bool                                                      {.importc: "TTF_SetTextFont"              .}
proc ttf_get_text_font*(text): Font                                                            {.importc: "TTF_GetTextFont"              .}
proc ttf_set_text_string*(text; str: cstring; len: csize_t): bool                              {.importc: "TTF_SetTextString"            .}
proc ttf_insert_text_string*(text; offset: cint; str: cstring; len: csize_t): bool             {.importc: "TTF_InsertTextString"         .}
proc ttf_append_text_string*(text; str: cstring; len: csize_t): bool                           {.importc: "TTF_AppendTextString"         .}
proc ttf_delete_text_string*(text; offset: cint; len: cint): bool                              {.importc: "TTF_DeleteTextString"         .}
proc ttf_set_text_wrapping*(text; wrap: bool; wrap_len: cint): bool                            {.importc: "TTF_SetTextWrapping"          .}
proc ttf_get_text_wrapping*(text; wrap: ptr bool; wrap_len: ptr cint): bool                    {.importc: "TTF_GetTextWrapping"          .}
proc ttf_get_text_size*(text; w, h: ptr cint): bool                                            {.importc: "TTF_GetTextSize"              .}
proc ttf_update_text*(text): bool                                                              {.importc: "TTF_UpdateText"               .}
proc ttf_destroy_text*(text)                                                                   {.importc: "TTF_DestroyText"              .}

proc ttf_get_text_substring*(text; offset: cint; substr: ptr Substring): bool                         {.importc: "TTF_GetTextSubString"         .}
proc ttf_get_text_substring_for_line*(text; line: cint; substr: ptr Substring): bool                  {.importc: "TTF_GetTextSubStringForLine"  .}
proc ttf_get_text_substrings_for_range*(text; offset1, offset2: cint; count: ptr cint): ptr Substring {.importc: "TTF_GetTextSubStringsForRange".}
proc ttf_get_text_substring_for_point*(text; x, y: cint; substr: ptr Substring): bool                 {.importc: "TTF_GetTextSubStringForPoint" .}
{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}

proc version*(): Version = ttf_version()
proc freetype_version*(): Version =
    var major, minor, patch: cint
    ttf_get_freetype_version major.addr, minor.addr, patch.addr
    version major, minor, patch
proc harfbuzz_version*(): Version =
    var major, minor, patch: cint
    ttf_get_harfbuzz_version major.addr, minor.addr, patch.addr
    version major, minor, patch

proc `=destroy`*(font) =
    ttf_close_font font

proc init*(): bool {.discardable.} =
    result = ttf_init()
    sdl_assert result, &"Failed to initialize SDL_TTF: '{get_error()}'"

proc was_init*(): bool = ttf_was_init() > 0

proc open_font*(path: string; pt_sz = DefaultFontSize): Font =
    ttf_open_font cstring path, cfloat pt_sz

proc close*(font) = ttf_close_font font

proc properties*(font): PropertyId    = ttf_get_font_properties font
proc is_fixed_width*(font): bool      = ttf_font_is_fixed_width font
proc is_scalable*(font)   : bool      = ttf_font_is_scalable font
proc has_glyph*(font; ch: Rune): bool = ttf_font_has_glyph font, uint32 ch

proc style*(font): FontStyle                    =         ttf_get_font_style          font
proc outline*(font): int32                      = int32   ttf_get_font_outline        font
proc hinting*(font): Hinting                    =         ttf_get_font_hinting        font
proc sdf*(font): bool                           =         ttf_get_font_sdf            font
proc kerning*(font): bool                       =         ttf_get_font_kerning        font
proc generation*(font): int32                   = int32   ttf_get_font_generation     font
proc size*(font): float32                       = float32 ttf_get_font_size           font
proc wrap_alignment*(font): HorizontalAlignment =         ttf_get_font_wrap_alignment font
proc height*(font): int32                       = int32   ttf_get_font_height         font
proc ascent*(font): int32                       = int32   ttf_get_font_ascent         font
proc descent*(font): int32                      = int32   ttf_get_font_descent        font
proc line_skip*(font): int32                    = int32   ttf_get_font_line_skip      font
proc family_name*(font): cstring                =         ttf_get_font_family_name    font
proc style_name*(font): cstring                 =         ttf_get_font_style_name     font
proc direction*(font): Direction                =         ttf_get_font_direction      font
proc dpi*(font): tuple[v, h: int32] =
    var h, v: cint
    assert ttf_get_font_dpi(font, h.addr, v.addr)
    (int32 h, int32 v)

proc script*(ch: Rune; sz: SomeInteger): cstring = ttf_get_glyph_script uint32 ch, result, csize_t sz
proc image*(font; ch: Rune): Surface             = ttf_get_glyph_image           font, uint32 ch
proc image*(font; idx: SomeInteger): Surface     = ttf_get_glyph_image_for_index font, uint32 idx
proc size*(font; text: string): tuple[w, h: int32] =
    var w, h: cint
    let success = ttf_get_string_size(font, cstring text, csize_t text.len, w.addr, h.addr)
    sdl_assert success, &"Failed to get size for string '{text}'"
    (int32 w, int32 h)
proc size*(font; text: string; wrap_len: SomeInteger): tuple[w, h: int32] =
    var w, h: cint
    let success = ttf_get_string_size_wrapped(font, cstring text, csize_t text.len, cint wrap_len, w.addr, h.addr)
    sdl_assert success, &"Failed to get size for string '{text}'"
    (int32 w, int32 h)
proc measure*(font; text: string; max_w: SomeInteger): tuple[w, count: int32] =
    var w, count: cint
    let success = ttf_measure_string(font, cstring text, csize_t text.len, cint max_w, w.addr, count.addr)
    sdl_assert success, &"Failed to measure string '{text}'"
    (int32 w, int32 count)
proc kerning*(font; prev_ch, ch: Rune): int32 =
    var kerning: cint = 0
    let success = ttf_get_glyph_kerning(font, uint32 prev_ch, uint32 ch, kerning.addr)
    sdl_assert success, &"Failed to get kerning for character '{ch} (previous char '{prev_ch}')'"
    int32 kerning
proc metrics*(font; ch: Rune): tuple[min_x, max_x, min_y, max_y, adv: int32] =
    var min_x, max_x, min_y, max_y, adv: cint
    let success = ttf_get_glyph_metrics(font, uint32 ch, min_x.addr, max_x.addr, min_y.addr, max_y.addr, adv.addr)
    sdl_assert success, &"Failed to get metrics for character '{ch}'"
    (int32 min_x, int32 max_x, int32 min_y, int32 max_y, int32 adv)

proc `size=`*(font; pt_sz: SomeNumber) =
    let success = ttf_set_font_size(font, cfloat pt_sz)
    sdl_assert success, &"Failed to set font size: '{get_error()}'"
proc `size=`*(font; v: tuple[pt_sz: float32; hdpi, vdpi: int]) =
    let success = ttf_set_font_size_dpi(font, cfloat v.pt_sz, cint v.hdpi, cint v.vdpi)
    sdl_assert success, &"Failed to set font size: '{get_error()}'"
proc `style=`*(font; style: FontStyle) = ttf_set_font_style font, style

proc `outline=`*(font; outline: SomeInteger) =
    let success = ttf_set_font_outline(font, cint outline)
    sdl_assert success, &"Failed to set font outline to '{outline}': '{get_error()}'"
proc `sdf=`*(font; enabled: bool) =
    let success = ttf_set_font_sdf(font, enabled)
    let state   = if enabled: "enable" else: "disable"
    sdl_assert success, &"""Failed to {state} font SDF: '{get_error()}'"""
proc `direction=`*(font; dir: Direction) =
    let success = ttf_set_font_direction(font, dir)
    sdl_assert success, &"Failed to set font direction to '{dir}': '{get_error()}'"
proc `script=`*(font; name: string) =
    let success = ttf_set_font_script(font, cstring name)
    sdl_assert success, &"Failed to set font script to '{name}': '{get_error()}'"
proc `language=`*(font; lang_bcp47: string) =
    let success = ttf_set_font_language(font, cstring lang_bcp47)
    sdl_assert success, &"Failed to set font language to '{lang_bcp47}': '{get_error()}'"
proc `hinting=`*(font; hinting: Hinting)                  = ttf_set_font_hinting font, hinting
proc `kerning=`*(font; enabled: bool)                     = ttf_set_font_kerning font, enabled
proc `wrap_alignment=`*(font; align: HorizontalAlignment) = ttf_set_font_wrap_alignment font, align

proc props*(font): PropertyId               = font.properties
proc sz*(font): float32                     = font.size
proc dir*(font): Direction                  = font.direction
proc wrap_align*(font): HorizontalAlignment = font.wrap_alignment

proc `sz=`*(font; pt_sz: SomeNumber)                  = font.size           = pt_sz
proc `wrap_align=`*(font; align: HorizontalAlignment) = font.wrap_alignment = align
proc `dir=`*(font; dir: Direction)                    = font.direction      = dir
proc `lang=`*(font; lang_bcp47: string)               = font.language       = lang_bcp47

using
    text    : string
    ch      : Rune
    bg, fg  : Colour
    wrap_len: SomeInteger
proc render_assert(res: Surface; text: string) =
    sdl_assert res != nil, &"Failed to render font text '{text}'"

proc render*(font; text; fg, bg): Surface =
    result = ttf_render_text_shaded(font, cstring text, csize_t text.len, fg, bg)
    render_assert result, text
proc render*(font; text; fg, bg; wrap_len): Surface =
    result = ttf_render_text_shaded_wrapped(font, cstring text, csize_t text.len, fg, bg, cint wrap_len)
    render_assert result, text
proc render*(font; ch; fg, bg): Surface =
    result = ttf_render_glyph_shaded(font, uint32 ch, fg, bg)
    render_assert result, $ch

proc render*(font; text; fg): Surface =
    result = ttf_render_text_blended(font, cstring text, csize_t text.len, fg)
    render_assert result, text
proc render*(font; text; fg; wrap_len): Surface =
    result = ttf_render_text_blended_wrapped(font, cstring text, csize_t text.len, fg, cint wrap_len)
    render_assert result, text
proc render*(font; ch; fg): Surface =
    result = ttf_render_glyph_blended(font, uint32 ch, fg)
    render_assert result, $ch

proc render_lcd*(font; text; fg, bg): Surface =
    result = ttf_render_text_lcd(font, cstring text, csize_t text.len, fg, bg)
    render_assert result, text
proc render_lcd*(font; text; fg, bg; wrap_len): Surface =
    result = ttf_render_text_lcd_wrapped(font, cstring text, csize_t text.len, fg, bg, cint wrap_len)
    render_assert result, text
proc render_lcd*(font; ch; fg, bg): Surface =
    result = ttf_render_glyph_lcd(font, uint32 ch, fg, bg)
    render_assert result, $ch

#~~~ Text Engine ~~~#
using
    engine: TextEngine
    text  : Text

proc create_text_engine*(): TextEngine =
    result = ttf_create_surface_text_engine()
    sdl_assert result, "Failed to create text engine with surface"
proc create_text_engine*(ren: ptr Renderer): TextEngine =
    result = ttf_create_renderer_text_engine ren
    sdl_assert result, "Failed to create text engine with renderer"

proc destroy*(engine) = ttf_destroy_renderer_text_engine engine

proc create_text*(engine; font; str: string): Text =
    let result = ttf_create_text(engine, font, cstring str, csize_t str.len)
    sdl_assert result, &"Failed to create text with engine '{str}'"
proc create_text*(engine; font; str: string; wrap_len: SomeInteger): Text =
    result = ttf_create_text_wrapped(engine, font, cstring str, csize_t str.len, cint wrap_len)
    sdl_assert result, &"Failed to create wrapped text with engine '{str}' ({wrap_len})"

proc draw*(text; x, y: SomeInteger; surface): bool {.discardable.} =
    result = ttf_draw_surface_text(text, cint x, cint y, surface)
    sdl_assert result, &"Failed to draw text to surface '{text}' ({x}, {y})"
proc draw*(text; x, y: SomeNumber): bool {.discardable.} =
    result = ttf_draw_renderer_text(text, cfloat x, cfloat y)
    sdl_assert result, &"Failed to draw text '{text}' ({x}, {y})"

proc properties*(text): PropertyId = ttf_get_text_properties text
proc engine*(text): TextEngine =
    result = ttf_get_text_engine text
    sdl_assert result, &"Failed to get text engine for text"
proc font*(text): Font =
    result = ttf_get_text_font text
    sdl_assert result, &"Failed to get font for text"
proc size*(text): tuple[w, h: int32] =
    var w, h: cint
    let success = ttf_get_text_size(text, w.addr, h.addr)
    sdl_assert success, &"Failed to get size of text for '{text}'"
    (int32 w, int32 h)
proc wrapping*(text): tuple[enabled: bool; len: int32] =
    var enabled : bool
    var wrap_len: cint
    let success = ttf_get_text_wrapping(text, enabled.addr, wrap_len.addr)
    sdl_assert success, &"Failed to get text wrapping for '{text}'"
    (enabled, int32 wrap_len)

proc `engine=`*(text; engine): bool {.discardable.} =
    result = ttf_set_text_engine(text, engine)
    sdl_assert result, &"Failed to set engine for text '{text}'"
proc `font=`*(text; font): bool {.discardable.} =
    result = ttf_set_text_font(text, font)
    sdl_assert result, &"Failed to set font for text '{text}'"
proc `text=`*(text; str: string): bool {.discardable.} =
    result = ttf_set_text_string(text, cstring str, csize_t str.len)
    sdl_assert result, &"Failed to set string for text '{text}' ('{str}')"
proc `wrapping=`*(text; wrap: (bool, SomeInteger)): bool {.discardable.} =
    result = ttf_set_text_wrapping(text, wrap[0], cint wrap[1])
    sdl_assert result, &"Failed to set wrapping for text '{text}' ('{wrap}')"

proc insert*(text; offset: SomeInteger; str: string): bool {.discardable.} =
    result = ttf_insert_text_string(text, cint offset, cstring str, csize_t str.len)
    sdl_assert result, &"Failed to insert text string '{text}' ('{str}')"
proc append*(text; str: string): bool {.discardable.} =
    result = ttf_append_text_string(text, cstring str, csize_t str.len)
    sdl_assert result, &"Failed to append to text '{text}' ('{str}')"
proc delete*(text; offset, len: SomeInteger): bool {.discardable.} =
    result = ttf_delete_text_string(text, cint offset, cint len)
    sdl_assert result, &"Failed to delete from text '{text}' ({len} chars at {offset})"
proc update*(text): bool {.discardable.} =
    result = ttf_update_text text
    sdl_assert result, &"Failed to update text '{text}'"
proc destroy*(text) = ttf_destroy_text text

proc props*(text): PropertyId      = text.properties
proc sz*(text): tuple[w, h: int32] = text.size

{.pop.} # inline

import common, bitgen
from std/unicode import Rune, `$`
from io          import Stream
from pixels      import Colour
from surface     import Surface
from renderer    import Renderer

# TODO: default colours

const
    DefaultFontSize = 16'i32

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
    Font*       = object
    TextLayout* = object
    TextEngine* = object

    Text* = object
        text*     : cstring
        colour*   : FColour
        ln_count* : cint
        ref_count*: cint
        _         : ptr TextData

    Substring* = object
        offset*     : cint
        len*        : cint
        ln_idx*     : cint
        cluster_idx*: cint
        rect*       : Rect

    FillOperation* = object
        cmd* : DrawCommand
        rect*: Rect

    CopyOperation* = object
        cmd*        : DrawCommand
        text_offset*: cint
        glyph_index*: uint32
        src*, dst*  : Rect
        _           : pointer

    DrawOperation* {.union.} = object
        cmd* : DrawCommand
        fill*: FillOperation
        copy*: CopyOperation

    TextData* = object
        font*               : ptr Font
        needs_layout_update*: cbool
        layout*             : ptr TextLayout
        w*, h*, num_ops*    : cint
        ops*                : ptr DrawOperation
        cluster_count*      : cint
        props*              : PropertyId
        needs_engine_update*: cbool
        engine*             : ptr TextEngine
        engine_text*        : pointer

    TextEngine* = object
        version*     : uint32
        user_data*   : pointer
        create_text* : proc(user_data: pointer; text: ptr Text): cbool
        destroy_text*: proc(user_data: pointer; text: ptr Text)

#[ -------------------------------------------------------------------- ]#

using
    font   : ptr Font
    engine : ptr TextEngine
    text   : ptr Text
    surface: ptr Surface

{.push dynlib: SdlTtfLib.}
proc ttf_init*(): cbool                                          {.importc: "TTF_Init"                  .}
proc ttf_open_font*(file: cstring; pt_sz: cint): ptr Font        {.importc: "TTF_OpenFont"              .}
proc ttf_open_font_with_properties*(props: PropertyId): ptr Font {.importc: "TTF_OpenFontWithProperties".}
proc ttf_get_font_properties*(font): PropertyId                  {.importc: "TTF_GetFontProperties"     .}
proc ttf_close_font*(font)                                       {.importc: "TTF_CloseFont"             .}
proc ttf_quit*()                                                 {.importc: "TTF_Quit"                  .}
proc ttf_was_init*(): cint                                       {.importc: "TTF_WasInit"               .}

proc ttf_font_is_fixed_width*(font): cbool                                {.importc: "TTF_FontIsFixedWidth"             .}
proc ttf_font_is_scalable*(font): cbool                                   {.importc: "TTF_FontIsScalable"               .}
proc ttf_font_has_glyph*(font; ch: uint32): cbool                         {.importc: "TTF_FontHasGlyph"                 .}
proc ttf_set_font_size*(font; pt_sz: cfloat): cbool                       {.importc: "TTF_SetFontSize"   , discardable  .}
proc ttf_set_font_size_dpi*(font; pt_sz: cfloat; hdpi, vdpi: cint): cbool {.importc: "TTF_SetFontSizeDPI", discardable  .}
proc ttf_set_font_style*(font; style: FontStyle)                          {.importc: "TTF_SetFontStyle"                 .}
proc ttf_get_font_style*(font): FontStyle                                 {.importc: "TTF_GetFontStyle"                 .}
proc ttf_set_font_outline*(font; outline: cint): cbool                    {.importc: "TTF_SetFontOutline", discardable  .}
proc ttf_get_font_outline*(font): cint                                    {.importc: "TTF_GetFontOutline"               .}
proc ttf_set_font_hinting*(font; hinting: Hinting)                        {.importc: "TTF_SetFontHinting"               .}
proc ttf_get_font_hinting*(font): Hinting                                 {.importc: "TTF_GetFontHinting"               .}
proc ttf_get_font_sdf*(font): cbool                                       {.importc: "TTF_GetFontSDF"                   .}
proc ttf_set_font_sdf*(font; enabled: cbool): cbool                       {.importc: "TTF_SetFontSDF"                   .}
proc ttf_set_font_kerning*(font; enabled: cbool)                          {.importc: "TTF_SetFontKerning"               .}
proc ttf_get_font_kerning*(font): cbool                                   {.importc: "TTF_GetFontKerning"               .}
proc ttf_get_font_generation*(font): uint32                               {.importc: "TTF_GetFontGeneration"            .}
proc ttf_get_font_size*(font): cfloat                                     {.importc: "TTF_GetFontSize"                  .}
proc ttf_get_font_dpi*(font; hdpi, vdpi: ptr cint): cbool                 {.importc: "TTF_GetFontDPI"                   .}
proc ttf_set_font_wrap_alignment*(font; align: HorizontalAlignment)       {.importc: "TTF_SetFontWrapAlignment"         .}
proc ttf_get_font_wrap_alignment*(font): HorizontalAlignment              {.importc: "TTF_GetFontWrapAlignment"         .}
proc ttf_get_font_height*(font): cint                                     {.importc: "TTF_GetFontHeight"                .}
proc ttf_get_font_ascent*(font): cint                                     {.importc: "TTF_GetFontAscent"                .}
proc ttf_get_font_descent*(font): cint                                    {.importc: "TTF_GetFontDescent"               .}
proc ttf_get_font_line_skip*(font): cint                                  {.importc: "TTF_GetFontLineSkip"              .}
proc ttf_get_font_family_name*(font): cstring                             {.importc: "TTF_GetFontFamilyName"            .}
proc ttf_get_font_style_name*(font): cstring                              {.importc: "TTF_GetFontStyleName"             .}
proc ttf_set_font_direction*(font; dir: Direction): cbool                 {.importc: "TTF_SetFontDirection", discardable.}
proc ttf_set_font_script*(font; script: cstring): cbool                   {.importc: "TTF_SetFontScript"   , discardable.}
proc ttf_set_font_language*(font; lang_bcp47: cstring): cbool             {.importc: "TTF_SetFontLanguage" , discardable.}
proc ttf_get_font_direction*(font): Direction                             {.importc: "TTF_GetFontDirection"             .}

proc ttf_get_glyph_script*(ch: uint32; script: cstring; script_sz: csize_t): cbool                           {.importc: "TTF_GetGlyphScript"       .}
proc ttf_get_glyph_image*(font; ch: uint32): ptr Surface                                                     {.importc: "TTF_GetGlyphImage"        .}
proc ttf_get_glyph_image_for_index*(font; glyph_index: uint32): ptr Surface                                  {.importc: "TTF_GetGlyphImageForIndex".}
proc ttf_get_glyph_metrics*(font; ch: uint32; min_x, max_x, min_y, max_y, adv: ptr cint): cbool              {.importc: "TTF_GetGlyphMetrics"      .}
proc ttf_get_glyph_kerning*(font; prev_ch, ch: uint32; kerning: ptr cint): cbool                             {.importc: "TTF_GetGlyphKerning"      .}
proc ttf_get_string_size*(font; text: cstring; len: csize_t; w, h: ptr cint): cbool                          {.importc: "TTF_GetStringSize"        .}
proc ttf_get_string_size_wrapped*(font; text: cstring; len: csize_t; wrap_len: cint; w, h: ptr cint): cbool  {.importc: "TTF_GetStringSizeWrapped" .}
proc ttf_measure_string*(font; text: cstring; len: csize_t; measure_w: cint; extent, count: ptr cint): cbool {.importc: "TTF_MeasureString"        .}

proc ttf_render_text_shaded*(font; text: cstring; len: csize_t; fg, bg: Colour): ptr Surface                         {.importc: "TTF_RenderText_Shaded"         .}
proc ttf_render_text_shaded_wrapped*(font; text: cstring; len: csize_t; fg, bg: Colour; wrap_len: cint): ptr Surface {.importc: "TTF_RenderText_Shaded_Wrapped" .}
proc ttf_render_glyph_shaded*(font; ch: uint32; fg, bg: Colour): ptr Surface                                         {.importc: "TTF_RenderGlyph_Shaded"        .}
proc ttf_render_text_blended*(font; text: cstring; len: csize_t; fg: Colour): ptr Surface                            {.importc: "TTF_RenderText_Blended"        .}
proc ttf_render_text_blended_wrapped*(font; text: cstring; len: csize_t; fg: Colour; wrap_len: cint): ptr Surface    {.importc: "TTF_RenderText_Blended_Wrapped".}
proc ttf_render_glyph_blended*(font; ch: uint32; fg: Colour): ptr Surface                                            {.importc: "TTF_RenderGlyph_Blended"       .}
proc ttf_render_text_lcd*(font; text: cstring; len: csize_t; fg, bg: Colour): ptr Surface                            {.importc: "TTF_RenderText_LCD"            .}
proc ttf_render_text_lcd_wrapped*(font; text: cstring; len: csize_t; fg, bg: Colour; wrap_len: cint): ptr Surface    {.importc: "TTF_RenderText_LCD_Wrapped"    .}
proc ttf_render_glyph_lcd*(font; ch: uint32; fg, bg: Colour): ptr Surface                                            {.importc: "TTF_RenderGlyph_LCD"           .}

proc ttf_create_surface_text_engine*(): ptr TextEngine                                             {.importc: "TTF_CreateSurfaceTextEngine"  .}
proc ttf_draw_surface_text*(text; x, y: cint; surface): cbool                                      {.importc: "TTF_DrawSurfaceText"          .}
proc ttf_destroy_surface_text_engine*(engine)                                                      {.importc: "TTF_DestroySurfaceTextEngine" .}
proc ttf_create_renderer_text_engine*(renderer: Renderer): ptr TextEngine                          {.importc: "TTF_CreateRendererTextEngine" .}
proc ttf_draw_renderer_text*(text; x, y: cfloat): cbool                                            {.importc: "TTF_DrawRendererText"         .}
proc ttf_destroy_renderer_text_engine*(engine)                                                     {.importc: "TTF_DestroyRendererTextEngine".}
proc ttf_create_text*(engine; font; text: cstring; len: csize_t): ptr Text                         {.importc: "TTF_CreateText"               .}
proc ttf_create_text_wrapped*(engine; font; text: cstring; len: csize_t; wrap_len: cint): ptr Text {.importc: "TTF_CreateText_Wrapped"       .}
proc ttf_get_text_properties*(text): PropertyId                                                    {.importc: "TTF_GetTextProperties"        .}
proc ttf_set_text_engine*(text; engine): cbool                                                     {.importc: "TTF_SetTextEngine"            .}
proc ttf_get_text_engine*(text): ptr TextEngine                                                    {.importc: "TTF_GetTextEngine"            .}
proc ttf_set_text_font*(text; font): cbool                                                         {.importc: "TTF_SetTextFont"              .}
proc ttf_get_text_font*(text): ptr Font                                                            {.importc: "TTF_GetTextFont"              .}
proc ttf_set_text_string*(text; str: cstring; len: csize_t): cbool                                 {.importc: "TTF_SetTextString"            .}
proc ttf_insert_text_string*(text; offset: cint; str: cstring; len: csize_t): cbool                {.importc: "TTF_InsertTextString"         .}
proc ttf_append_text_string*(text; str: cstring; len: csize_t): cbool                              {.importc: "TTF_AppendTextString"         .}
proc ttf_delete_text_string*(text; offset: cint; len: cint): cbool                                 {.importc: "TTF_DeleteTextString"         .}
proc ttf_set_text_wrapping*(text; wrap: cbool; wrap_len: cint): cbool                              {.importc: "TTF_SetTextWrapping"          .}
proc ttf_get_text_wrapping*(text; wrap: ptr cbool; wrap_len: ptr cint): cbool                      {.importc: "TTF_GetTextWrapping"          .}
proc ttf_get_text_size*(text; w, h: ptr cint): cbool                                               {.importc: "TTF_GetTextSize"              .}
proc ttf_update_text*(text): cbool                                                                 {.importc: "TTF_UpdateText"               .}
proc ttf_destroy_text*(text)                                                                       {.importc: "TTF_DestroyText"              .}

proc ttf_get_text_substring*(text; offset: cint; substr: ptr Substring): cbool                            {.importc: "TTF_GetTextSubString"         .}
proc ttf_get_text_substring_for_line*(text; line: cint; substr: ptr Substring): cbool                     {.importc: "TTF_GetTextSubStringForLine"  .}
proc ttf_get_text_substrings_for_range*(text; offset1, offset2: cint; count: ptr cint): ptr ptr Substring {.importc: "TTF_GetTextSubStringsForRange".}
proc ttf_get_text_substring_for_point*(text; x, y: cint; substr: ptr Substring): cbool                    {.importc: "TTF_GetTextSubStringForPoint" .}
{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}

proc `=destroy`*(font) =
    ttf_close_font font

proc init*(): bool =
    ttf_init()

proc open_font*(path: string; pt_sz = DefaultFontSize): ptr Font =
    ttf_open_font cstring path, cint pt_sz

proc close*(font) = ttf_close_font font

proc properties*(font): PropertyId = ttf_get_font_properties font
proc is_fixed_width*(font): bool = ttf_font_is_fixed_width font
proc is_scalable*(font)   : bool = ttf_font_is_scalable font
proc has_glyph*(font; ch: Rune): bool = ttf_font_has_glyph font, uint32 ch

proc style*(font): FontStyle                    =         ttf_get_font_style          font
proc outline*(font): int                        = int     ttf_get_font_outline        font
proc hinting*(font): Hinting                    =         ttf_get_font_hinting        font
proc sdf*(font): bool                           =         ttf_get_font_sdf            font
proc kerning*(font): bool                       =         ttf_get_font_kerning        font
proc generation*(font): int                     = int     ttf_get_font_generation     font
proc size*(font): float32                       = float32 ttf_get_font_size           font
proc wrap_alignment*(font): HorizontalAlignment =         ttf_get_font_wrap_alignment font
proc height*(font): int                         = int     ttf_get_font_height         font
proc ascent*(font): int                         = int     ttf_get_font_ascent         font
proc descent*(font): int                        = int     ttf_get_font_descent        font
proc line_skip*(font): int                      = int     ttf_get_font_line_skip      font
proc family_name*(font): cstring                =         ttf_get_font_family_name    font
proc style_name*(font): cstring                 =         ttf_get_font_style_name     font
proc direction*(font): Direction                =         ttf_get_font_direction      font
proc dpi*(font): tuple[v, h: int] =
    var h, v: cint
    ttf_get_font_style font, h.addr, v.addr
    (int h, int v)

proc `size=`*(font; pt_sz: float32)                            = ttf_set_font_size     font, cfloat pt_sz
proc `size=`*(font; v: tuple[pt_sz: float32; hdpi, vdpi: int]) = ttf_set_font_size_dpi font, cfloat v.pt_sz, cint v.hdpi, cint v.vdpi
proc `style=`*(font; style: FontStyle)                         = ttf_set_font_style    font, style

proc `outline=`*(font; outline: int)                      = ttf_set_font_outline        font, cint outline
proc `hinting=`*(font; hinting: Hinting)                  = ttf_set_font_hinting        font, hinting
proc `sdf=`*(font; enabled: bool)                         = ttf_set_font_sdf            font, enabled
proc `kerning=`*(font; enabled: bool)                     = ttf_set_font_kerning        font, enabled
proc `wrap_alignment=`*(font; align: HorizontalAlignment) = ttf_set_font_wrap_alignment font, align
proc `direction=`*(font; dir: Direction)                  = ttf_set_font_direction      font, dir
proc `script=`*(font; name: string)                       = ttf_set_font_script         font, cstring name
proc `language=`*(font; lang_bcp47: string)               = ttf_set_font_language       font, cstring lang_bcp47

# Abbreviations
proc props*(font): PropertyId               = font.properties
proc sz*(font): float32                     = font.size
proc dir*(font): Direction                  = font.direction
proc wrap_align*(font): HorizontalAlignment = font.wrap_alignment

proc `wrap_align=`*(font; align: HorizontalAlignment) = font.wrap_alignment = align
proc `dir=`*(font; dir: Direction)                    = font.direction      = dir
proc `lang=`*(font; lang_bcp47: string)               = font.language       = lang_bcp47

proc script*(ch: Rune; sz: int): cstring    = ttf_get_glyph_script uint32 ch, result, csize_t sz
proc image*(font; ch: Rune): ptr Surface    = ttf_get_glyph_image           font, uint32 ch
proc image*(font; idx: int): ptr Surface    = ttf_get_glyph_image_for_index font, idx
proc kerning*(font; prev_ch, ch: Rune): int =
    var kerning: cint = 0
    ttf_get_glyph_kerning font, uint32 prev_ch, uint32 ch, kerning.addr
    result = kerning
proc metrics*(font; ch: Rune): tuple[min_x, max_x, min_y, max_y, adv: int32] =
    ttf_get_glyph_metrics font, uint32 ch, result.min_x.addr, result.max_x.addr, result.min_y.addr, result.max_y.addr, result.adv.addr

# proc ttf_get_string_size*(font; text: cstring; len: csize_t; w, h: ptr cint): cbool                          {.importc: "TTF_GetStringSize"        .}
# proc ttf_get_string_size_wrapped*(font; text: cstring; len: csize_t; wrap_len: cint; w, h: ptr cint): cbool  {.importc: "TTF_GetStringSizeWrapped" .}
# proc ttf_measure_string*(font; text: cstring; len: csize_t; measure_w: cint; extent, count: ptr cint): cbool {.importc: "TTF_MeasureString"        .}

### ### ###

proc set_size*(font; pt_sz: int32; hdpi, vdpi: uint32): bool {.discardable.} =
    ttf_set_font_size_dpi font, pt_sz, hdpi, vdpi

proc get_kerning_size*(font; prev_ch, ch: Rune): int32 =
    ttf_get_font_kerning_size_glyphs32 font, uint32 prev_ch, uint32 ch

proc style*(font): FontStyle = ttf_get_font_style font
proc outline*(font): int32   = ttf_get_font_outline font
proc hinting*(font): Hinting = ttf_get_font_hinting font
proc align*(font): Align     = ttf_get_font_wrapped_align font
proc kerning*(font): bool    = ttf_get_font_kerning font
proc sdf*(font): bool        = ttf_get_font_sdf font

proc `size=`*(font; pt_sz: int32)          = assert ttf_set_font_size(font, pt_sz)
proc `style=`*(font; style: FontStyle)     = ttf_set_font_style font, style
proc `outline=`*(font; outline: int32)     = ttf_set_font_outline font, outline
proc `hinting=`*(font; hinting: Hinting)   = ttf_set_font_hinting font, hinting
proc `align=`*(font; align: Align)         = ttf_set_font_wrapped_align font, align
proc `kerning=`*(font; kerning: bool)      = ttf_set_font_kerning font, kerning
proc `sdf=`*(font; on_off: bool)           = assert ttf_set_font_sdf(font, on_off)
proc `dir=`*(font; dir: Direction)         = assert ttf_set_font_direction(font, dir)
proc `script_name=`*(font; script: string) = assert ttf_set_font_script_name(font, cstring script)
proc `language=`*(font; lang: string)      = assert ttf_set_font_language(font, cstring lang)

proc height*(font): int32                     = ttf_font_height font
proc ascent*(font): int32                     = ttf_font_ascent font
proc descent*(font): int32                    = ttf_font_descent font
proc line_skip*(font): int32                  = ttf_font_line_skip font
proc faces*(font): int                        = ttf_font_faces font
proc faces_is_fixed_width*(font): bool        = ttf_font_faces_is_fixed_width font
proc face_family_name*(font): string          = $ttf_font_face_family_name(font)
proc face_style_name*(font): string           = $ttf_font_face_style_name(font)
proc is_scalable*(font): bool                 = ttf_is_font_scalable font
proc glyph_is_provided*(font; ch: Rune): bool = ttf_glyph_is_provided32 font, uint32 ch

proc `sz=`*(font; pt_sz: int32) = font.sz = pt_sz
proc h*(font): int32 = font.height

proc glyph_metrics*(font; ch: Rune): tuple[minx, maxx, miny, maxy, advance: int32] =
    assert not ttf_glyph_metrics32(font, uint32 ch, result.minx.addr, result.maxx.addr,
                                                    result.miny.addr, result.maxy.addr,
                                   result.advance.addr)

proc size*(font; text: string): tuple[w, h: int32] =
    assert not ttf_size_utf8(font, cstring text, result.w.addr, result.h.addr)

proc measure*(font; text: string; w: int32): tuple[count, extent: int32] =
    assert not ttf_measure_utf8(font, cstring text, w, result.extent.addr, result.count.addr)

using
    text  : string
    fg, bg: Colour
    ch    : Rune

proc render*(font; ch; fg, bg): (Surface, bool) =
    let surf = ttf_render_glyph32_shaded(font, uint32 ch, fg, bg)
    result[0] = cast[ptr Surface](surf)[]
    result[1] = surf != nil

proc render*(font; ch; fg): (Surface, bool) =
    let surf = ttf_render_glyph32_solid(font, uint32 ch, fg)
    result[0] = cast[ptr Surface](surf)[]
    result[1] = surf != nil

proc render_blended*(font; ch; fg): (Surface, bool) =
    let surf = ttf_render_glyph32_blended(font, uint32 ch, fg)
    result[0] = cast[ptr Surface](surf)[]
    result[1] = surf != nil

proc render_lcd*(font; ch; fg, bg): (Surface, bool) =
    let surf = ttf_render_glyph32_lcd(font, uint32 ch, fg, bg)
    result[0] = cast[ptr Surface](surf)[]
    result[1] = surf != nil

proc render*(font; text; fg): (Surface, bool) =
    let surf = ttf_render_utf8_solid(font, text, fg)
    result[0] = cast[ptr Surface](surf)[]
    result[1] = surf != nil

proc render*(font; text; fg; wrap_len: int32): (Surface, bool) =
    let surf = ttf_render_utf8_solid_wrapped(font, text, fg, uint32 wrap_len)
    result[0] = cast[ptr Surface](surf)[]
    result[1] = surf != nil

proc render*(font; text; fg, bg): (Surface, bool) =
    let surf = ttf_render_utf8_shaded(font, text, fg, bg)
    result[0] = cast[ptr Surface](surf)[]
    result[1] = surf != nil

proc render*(font; text; fg, bg; wrap_len: int32): (Surface, bool) =
    let surf = ttf_render_utf8_shaded_wrapped(font, text, fg, bg, uint32 wrap_len)
    result[0] = cast[ptr Surface](surf)[]
    result[1] = surf != nil

proc render_blended*(font; text; fg): (Surface, bool) =
    let surf = ttf_render_utf8_blended(font, text, fg)
    result[0] = cast[ptr Surface](surf)[]
    result[1] = surf != nil

proc render_blended*(font; text; fg; wrap_len: int32): (Surface, bool) =
    let surf = ttf_render_utf8_blended_wrapped(font, text, fg, uint32 wrap_len)
    result[0] = cast[ptr Surface](surf)[]
    result[1] = surf != nil

proc render_lcd*(font; text; fg, bg): (Surface, bool) =
    let surf = ttf_render_utf8_lcd(font, text, fg, bg)
    result[0] = cast[ptr Surface](surf)[]
    result[1] = surf != nil

proc render_lcd*(font; text; fg, bg; wrap_len: int32): (Surface, bool) =
    let surf = ttf_render_utf8_lcd_wrapped(font, text, fg, bg, uint32 wrap_len)
    result[0] = cast[ptr Surface](surf)[]
    result[1] = surf != nil

{.pop.} # inline

# SDL_COMPILE_TIME_ASSERT(TTF_TextEngine_SIZE,
#     (sizeof(void *) == 4 && sizeof(TTF_TextEngine) == 16) ||
#     (sizeof(void *) == 8 && sizeof(TTF_TextEngine) == 32));

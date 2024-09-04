import common, bitgen
from std/unicode import Rune, `$`
from io          import Stream
from pixels      import Colour
from surface     import Surface

# TODO: default colours

const DefaultFontSize = 16'i32

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

    Align* {.size: sizeof(cint).} = enum
        alignLeft
        alignCenter
        alignRight

    Direction* {.size: sizeof(cint).} = enum
        dirLtr
        dirRtl
        dirTtb
        dirBtt

type Font* = distinct pointer

#[ -------------------------------------------------------------------- ]#

using
    file  : cstring
    stream: Stream
    font  : Font

{.push dynlib: SdlTtfLib.}
proc ttf_byte_swapped_unicode*(swapped: bool)                                                               {.importc: "TTF_ByteSwappedUNICODE".}
proc ttf_init*(): SdlBool                                                                                   {.importc: "TTF_Init"              .}
proc ttf_quit*()                                                                                            {.importc: "TTF_Quit"              .}
proc ttf_was_init*(): cint                                                                                  {.importc: "TTF_WasInit"           .}
proc ttf_set_font_size*(font; pt_sz: cint): SdlBool                                                         {.importc: "TTF_SetFontSize"       .}
proc ttf_open_font*(file; pt_sz: cint): pointer                                                             {.importc: "TTF_OpenFont"          .}
proc ttf_open_font_index*(file; pt_sz: cint; index: clong): pointer                                         {.importc: "TTF_OpenFontIndex"     .}
proc ttf_open_font_io*(stream; close_io: bool; pt_sz: cint): pointer                                        {.importc: "TTF_OpenFontIO"        .}
proc ttf_open_font_index_io*(stream; close_io: bool; pt_sz: cint; index: clong): pointer                    {.importc: "TTF_OpenFontIndexIO"   .}
proc ttf_open_font_dpi*(file; pt_sz: cint; hdpi, vdpi: cuint): pointer                                      {.importc: "TTF_OpenFontDPI"       .}
proc ttf_open_font_index_dpi*(file; pt_sz: cint; index: clong; hdpi, vdpi: cuint): pointer                  {.importc: "TTF_OpenFontIndexDPI"  .}
proc ttf_open_font_dpi_io*(stream; close_io: bool; pt_sz: cint; hdpi, vdpi: cuint): pointer                 {.importc: "TTF_OpenFontDPIIO"     .}
proc ttf_open_font_index_dpi_io*(stream; close_io: bool; pt_sz: cint; i: clong; hdpi, vdpi: cuint): pointer {.importc: "TTF_OpenFontIndexDPIIO".}
proc ttf_close_font*(font)                                                                                  {.importc: "TTF_CloseFont"         .}

proc ttf_set_font_size_dpi*(font; pt_sz: cint; hdpi, vdpi: cuint): SdlBool {.importc: "TTF_SetFontSizeDPI"            .}
proc ttf_get_font_style*(font): FontStyle                                  {.importc: "TTF_GetFontStyle"              .}
proc ttf_set_font_style*(font; style: FontStyle)                           {.importc: "TTF_SetFontStyle"              .}
proc ttf_get_font_outline*(font): cint                                     {.importc: "TTF_GetFontOutline"            .}
proc ttf_set_font_outline*(font; outline: cint)                            {.importc: "TTF_SetFontOutline"            .}
proc ttf_get_font_hinting*(font): Hinting                                  {.importc: "TTF_GetFontHinting"            .}
proc ttf_set_font_hinting*(font; hinting: Hinting)                         {.importc: "TTF_SetFontHinting"            .}
proc ttf_get_font_wrapped_align*(font): Align                              {.importc: "TTF_GetFontWrappedAlign"       .}
proc ttf_set_font_wrapped_align*(font; align: Align)                       {.importc: "TTF_SetFontWrappedAlign"       .}
proc ttf_get_font_kerning*(font): SdlBool                                  {.importc: "TTF_GetFontKerning"            .}
proc ttf_set_font_kerning*(font; allowed: SdlBool)                         {.importc: "TTF_SetFontKerning"            .}
proc ttf_get_font_kerning_size_glyphs*(font; prev_ch, ch: uint16): cint    {.importc: "TTF_GetFontKerningSizeGlyphs"  .}
proc ttf_get_font_kerning_size_glyphs32*(font; prev_ch, ch: uint32): cint  {.importc: "TTF_GetFontKerningSizeGlyphs32".}
proc ttf_get_font_sdf*(font): SdlBool                                      {.importc: "TTF_GetFontSDF"                .}
proc ttf_set_font_sdf*(font; on_off: SdlBool): SdlBool                     {.importc: "TTF_SetFontSDF"                .}
proc ttf_set_font_direction*(font; dir: Direction): SdlBool                {.importc: "TTF_SetFontDirection"          .}
proc ttf_set_font_script_name*(font; script: cstring): SdlBool             {.importc: "TTF_SetFontScriptName"         .}
proc ttf_set_font_language*(font; lang: cstring): SdlBool                  {.importc: "TTF_SetFontLanguage"           .}

proc ttf_font_height*(font): cint                                                                    {.importc: "TTF_FontHeight"          .}
proc ttf_font_ascent*(font): cint                                                                    {.importc: "TTF_FontAscent"          .}
proc ttf_font_descent*(font): cint                                                                   {.importc: "TTF_FontDescent"         .}
proc ttf_font_line_skip*(font): cint                                                                 {.importc: "TTF_FontLineSkip"        .}
proc ttf_font_faces*(font): clong                                                                    {.importc: "TTF_FontFaces"           .}
proc ttf_font_faces_is_fixed_width*(font): SdlBool                                                   {.importc: "TTF_FontFaceIsFixedWidth".}
proc ttf_font_face_family_name*(font): cstring                                                       {.importc: "TTF_FontFaceFamilyName"  .}
proc ttf_font_face_style_name*(font): cstring                                                        {.importc: "TTF_FontFaceStyleName"   .}
proc ttf_is_font_scalable*(font): SdlBool                                                            {.importc: "TTF_IsFontScalable"      .}
proc ttf_glyph_is_provided*(font; ch: uint16): SdlBool                                               {.importc: "TTF_GlyphIsProvided"     .}
proc ttf_glyph_is_provided32*(font; ch: uint32): SdlBool                                             {.importc: "TTF_GlyphIsProvided32"   .}
proc ttf_glyph_metrics*(font; ch: uint16; minx, maxx, miny, maxy, advance: ptr cint): SdlBool        {.importc: "TTF_GlyphMetrics"        .}
proc ttf_glyph_metrics32*(font; ch: uint32; minx, maxx, miny, maxy, advance: ptr cint): SdlBool      {.importc: "TTF_GlyphMetrics32"      .}
proc ttf_size_text*(font; text: cstring; w, h: ptr cint): SdlBool                                    {.importc: "TTF_SizeText"            .}
proc ttf_size_utf8*(font; text: cstring; w, h: ptr cint): SdlBool                                    {.importc: "TTF_SizeUTF8"            .}
proc ttf_size_unicode*(font; text: ptr uint16; w, h: ptr cint): SdlBool                              {.importc: "TTF_SizeUNICODE"         .}
proc ttf_measure_text*(font; text: cstring; measure_w: cint; extent, count: ptr cint): SdlBool       {.importc: "TTF_MeasureText"         .}
proc ttf_measure_utf8*(font; text: cstring; measure_w: cint; extent, count: ptr cint): SdlBool       {.importc: "TTF_MeasureUTF8"         .}
proc ttf_measure_unicode*(font; text: ptr uint16; measure_w: cint; extent, count: ptr cint): SdlBool {.importc: "TTF_MeasureUNICODE"      .}

proc ttf_render_glyph_solid*(font; ch: uint16; fg: Colour): pointer                                        {.importc: "TTF_RenderGlyph_Solid"            .}
proc ttf_render_glyph32_solid*(font; ch: uint32; fg: Colour): pointer                                      {.importc: "TTF_RenderGlyph32_Solid"          .}
proc ttf_render_glyph_shaded*(font; ch: uint16; fg, bg: Colour): pointer                                   {.importc: "TTF_RenderGlyph_Shaded"           .}
proc ttf_render_glyph32_shaded*(font; ch: uint32; fg, bg: Colour): pointer                                 {.importc: "TTF_RenderGlyph32_Shaded"         .}
proc ttf_render_glyph_blended*(font; ch: uint16; fg: Colour): pointer                                      {.importc: "TTF_RenderGlyph_Blended"          .}
proc ttf_render_glyph32_blended*(font; ch: uint32; fg: Colour): pointer                                    {.importc: "TTF_RenderGlyph32_Blended"        .}
proc ttf_render_glyph_lcd*(font; ch: uint16; fg, bg: Colour): pointer                                      {.importc: "TTF_RenderGlyph_LCD"              .}
proc ttf_render_glyph32_lcd*(font; ch: uint32; fg, bg: Colour): pointer                                    {.importc: "TTF_RenderGlyph32_LCD"            .}
proc ttf_render_text_solid*(font; text: cstring; fg: Colour): pointer                                      {.importc: "TTF_RenderText_Solid"             .}
proc ttf_render_utf8_solid*(font; text: cstring; fg: Colour): pointer                                      {.importc: "TTF_RenderUTF8_Solid"             .}
proc ttf_render_unicode_solid*(font; text: ptr uint16; fg: Colour): pointer                                {.importc: "TTF_RenderUNICODE_Solid"          .}
proc ttf_render_text_solid_wrapped*(font; text: cstring; fg: Colour; wrap_len: uint32): pointer            {.importc: "TTF_RenderText_Solid_Wrapped"     .}
proc ttf_render_utf8_solid_wrapped*(font; text: cstring; fg: Colour; wrap_len: uint32): pointer            {.importc: "TTF_RenderUTF8_Solid_Wrapped"     .}
proc ttf_render_unicode_solid_wrapped*(font; text: ptr uint16; fg: Colour; wrap_len: uint32): pointer      {.importc: "TTF_RenderUNICODE_Solid_Wrapped"  .}
proc ttf_render_text_shaded*(font; text: cstring; fg, bg: Colour): pointer                                 {.importc: "TTF_RenderText_Shaded"            .}
proc ttf_render_utf8_shaded*(font; text: cstring; fg, bg: Colour): pointer                                 {.importc: "TTF_RenderUTF8_Shaded"            .}
proc ttf_render_unicode_shaded*(font; text: ptr uint16; fg, bg: Colour): pointer                           {.importc: "TTF_RenderUNICODE_Shaded"         .}
proc ttf_render_text_shaded_wrapped*(font; text: cstring; fg, bg: Colour; wrap_len: uint32): pointer       {.importc: "TTF_RenderText_Shaded_Wrapped"    .}
proc ttf_render_utf8_shaded_wrapped*(font; text: cstring; fg, bg: Colour; wrap_len: uint32): pointer       {.importc: "TTF_RenderUTF8_Shaded_Wrapped"    .}
proc ttf_render_unicode_shaded_wrapped*(font; text: ptr uint16; fg, bg: Colour; wrap_len: uint32): pointer {.importc: "TTF_RenderUNICODE_Shaded_Wrapped" .}
proc ttf_render_text_blended*(font; text: cstring; fg: Colour): pointer                                    {.importc: "TTF_RenderText_Blended"           .}
proc ttf_render_utf8_blended*(font; text: cstring; fg: Colour): pointer                                    {.importc: "TTF_RenderUTF8_Blended"           .}
proc ttf_render_unicode_blended*(font; text: ptr uint16; fg: Colour): pointer                              {.importc: "TTF_RenderUNICODE_Blended"        .}
proc ttf_render_text_blended_wrapped*(font; text: cstring; fg: Colour; wrap_len: uint32): pointer          {.importc: "TTF_RenderText_Blended_Wrapped"   .}
proc ttf_render_utf8_blended_wrapped*(font; text: cstring; fg: Colour; wrap_len: uint32): pointer          {.importc: "TTF_RenderUTF8_Blended_Wrapped"   .}
proc ttf_render_unicode_blended_wrapped*(font; text: ptr uint16; fg: Colour; wrap_len: uint32): pointer    {.importc: "TTF_RenderUNICODE_Blended_Wrapped".}
proc ttf_render_text_lcd*(font; text: cstring; fg, bg: Colour): pointer                                    {.importc: "TTF_RenderText_LCD"               .}
proc ttf_render_utf8_lcd*(font; text: cstring; fg, bg: Colour): pointer                                    {.importc: "TTF_RenderUTF8_LCD"               .}
proc ttf_render_unicode_lcd*(font; text: ptr uint16; fg, bg: Colour): pointer                              {.importc: "TTF_RenderUNICODE_LCD"            .}
proc ttf_render_text_lcd_wrapped*(font; text: cstring; fg, bg: Colour; wrap_len: uint32): pointer          {.importc: "TTF_RenderText_LCD_Wrapped"       .}
proc ttf_render_utf8_lcd_wrapped*(font; text: cstring; fg, bg: Colour; wrap_len: uint32): pointer          {.importc: "TTF_RenderUTF8_LCD_Wrapped"       .}
proc ttf_render_unicode_lcd_wrapped*(font; text: ptr uint16; fg, bg: Colour; wrap_len: uint32): pointer    {.importc: "TTF_RenderUNICODE_LCD_Wrapped"    .}
{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}

proc `=destroy`*(font) =
    ttf_close_font font

proc init*(): bool =
    ttf_init()

proc open_font*(src: string; pt_sz = DefaultFontSize; idx = 0; hdpi, vdpi = 0'u32): (Font, bool) =
    var font: pointer
    if vdpi != 0 or hdpi != 0:
        font = ttf_open_font_index_dpi(src, pt_sz, clong idx, cuint hdpi, cuint vdpi)
    else:
        font = ttf_open_font_index(src, pt_sz, idx)

    result[0] = Font font
    result[1] = font != nil

proc open_font*(stream; close_io = false; pt_sz = DefaultFontSize; idx = 0; hdpi, vdpi = 0'u32): (Font, bool) =
    var font: pointer
    if vdpi != 0 or hdpi != 0:
        font = ttf_open_font_index_dpi_io(stream, close_io, cint pt_sz, clong idx, cuint hdpi, cuint vdpi)
    else:
        font = ttf_open_font_index_io(stream, close_io, cint pt_sz, clong idx)

    result[0] = Font font
    result[1] = font != nil

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

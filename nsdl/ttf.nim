{.push raises: [].}

from std/unicode import Rune, `$`
from io      import Stream
from pixels  import Colour
from surface import Surface
import common

# TODO: default colours

const DefaultFontSize = 16

type
    UnicodeBOM* {.size: sizeof(cint).} = enum
        Native  = 0xFEFF
        Swapped = 0xFFFE

    FontStyle* {.size: sizeof(cint).} = enum
        Normal        = 0x00
        Bold          = 0x01
        Italic        = 0x02
        Underline     = 0x04
        Strikethrough = 0x08
func `or`*(a, b: FontStyle): FontStyle = a or b

type
    Hinting* {.size: sizeof(cint).} = enum
        Normal
        Light
        Mono
        None
        LightSubpixel

    Align* {.size: sizeof(cint).} = enum
        Left
        Center
        Right

    Direction* {.size: sizeof(cint).} = enum
        LTR
        RTL
        TTB
        BTT

type Font* = distinct pointer

#[ -------------------------------------------------------------------- ]#

using
    file  : cstring
    stream: Stream
    font  : Font

{.push dynlib: TTFPath.}
proc linked_version*(): ptr Version                                                                       {.importc: "TTF_Linked_Version"               .}
proc get_freetype_version*(major, minor, patch: ptr cint)                                                 {.importc: "TTF_GetFreeTypeVersion"           .}
proc get_harfbuzz_version*(major, minor, patch: ptr cint)                                                 {.importc: "TTF_GetHarfBuzzVersion"           .}
proc byte_swapped_unicode*(swapped: bool)                                                                 {.importc: "TTF_ByteSwappedUNICODE"           .}
proc init*(): cint                                                                                        {.importc: "TTF_Init"                         .}
proc quit*()                                                                                              {.importc: "TTF_Quit"                         .}
proc was_init*(): cint                                                                                    {.importc: "TTF_WasInit"                      .}
proc set_font_size*(font; pt_size: cint): cint                                                            {.importc: "TTF_SetFontSize"                  .}
proc open_font*(file; pt_size: cint): pointer                                                             {.importc: "TTF_OpenFont"                     .}
proc open_font_index*(file; pt_size: cint; index: clong): pointer                                         {.importc: "TTF_OpenFontIndex"                .}
proc open_font_io*(stream; close_io: bool; pt_size: cint): pointer                                        {.importc: "TTF_OpenFontIO"                   .}
proc open_font_index_io*(stream; close_io: bool; pt_size: cint; index: clong): pointer                    {.importc: "TTF_OpenFontIndexIO"              .}
proc open_font_dpi*(file; pt_size: cint; hdpi, vdpi: cuint): pointer                                      {.importc: "TTF_OpenFontDPI"                  .}
proc open_font_index_dpi*(file; pt_size: cint; index: clong; hdpi, vdpi: cuint): pointer                  {.importc: "TTF_OpenFontIndexDPI"             .}
proc open_font_dpi_io*(stream; close_io: bool; pt_size: cint; hdpi, vdpi: cuint): pointer                 {.importc: "TTF_OpenFontDPIIO"                .}
proc open_font_index_dpi_io*(stream; close_io: bool; pt_size: cint; i: clong; hdpi, vdpi: cuint): pointer {.importc: "TTF_OpenFontIndexDPIIO"           .}
proc close_font*(font)                                                                                    {.importc: "TTF_CloseFont"                    .}
proc set_font_size_dpi*(font; pt_size: cint; hdpi, vdpi: cuint): cint                                     {.importc: "TTF_SetFontSizeDPI"               .}
proc get_font_style*(font): cint                                                                          {.importc: "TTF_GetFontStyle"                 .}
proc set_font_style*(font; style: cint)                                                                   {.importc: "TTF_SetFontStyle"                 .}
proc get_font_outline*(font): cint                                                                        {.importc: "TTF_GetFontOutline"               .}
proc set_font_outline*(font; outline: cint)                                                               {.importc: "TTF_SetFontOutline"               .}
proc get_font_hinting*(font): cint                                                                        {.importc: "TTF_GetFontHinting"               .}
proc set_font_hinting*(font; hinting: cint)                                                               {.importc: "TTF_SetFontHinting"               .}
proc get_font_wrapped_align*(font): cint                                                                  {.importc: "TTF_GetFontWrappedAlign"          .}
proc set_font_wrapped_align*(font; align: cint)                                                           {.importc: "TTF_SetFontWrappedAlign"          .}
proc get_font_kerning*(font): cint                                                                        {.importc: "TTF_GetFontKerning"               .}
proc set_font_kerning*(font; allowed: cint)                                                               {.importc: "TTF_SetFontKerning"               .}
proc get_font_kerning_size_glyphs*(font; prev_ch, ch: uint16): cint                                       {.importc: "TTF_GetFontKerningSizeGlyphs"     .}
proc get_font_kerning_size_glyphs32*(font; prev_ch, ch: uint32): cint                                     {.importc: "TTF_GetFontKerningSizeGlyphs32"   .}
proc get_font_sdf*(font): bool                                                                            {.importc: "TTF_GetFontSDF"                   .}
proc set_font_sdf*(font; on_off: bool): cint                                                              {.importc: "TTF_SetFontSDF"                   .}
proc set_font_direction*(font; direction: Direction): cint                                                {.importc: "TTF_SetFontDirection"             .}
proc set_font_script_name*(font; script: cstring): cint                                                   {.importc: "TTF_SetFontScriptName"            .}
proc set_font_language*(font; language: cstring): cint                                                    {.importc: "TTF_SetFontLanguage"              .}
proc font_height*(font): cint                                                                             {.importc: "TTF_FontHeight"                   .}
proc font_ascent*(font): cint                                                                             {.importc: "TTF_FontAscent"                   .}
proc font_descent*(font): cint                                                                            {.importc: "TTF_FontDescent"                  .}
proc font_line_skip*(font): cint                                                                          {.importc: "TTF_FontLineSkip"                 .}
proc font_faces*(font): clong                                                                             {.importc: "TTF_FontFaces"                    .}
proc font_faces_is_fixed_width*(font): cint                                                               {.importc: "TTF_FontFaceIsFixedWidth"         .}
proc font_face_family_name*(font): cstring                                                                {.importc: "TTF_FontFaceFamilyName"           .}
proc font_face_style_name*(font): cstring                                                                 {.importc: "TTF_FontFaceStyleName"            .}
proc is_font_scalable*(font): bool                                                                        {.importc: "TTF_IsFontScalable"               .}
proc glyph_is_provided*(font; ch: uint16): cint                                                           {.importc: "TTF_GlyphIsProvided"              .}
proc glyph_is_provided32*(font; ch: uint32): cint                                                         {.importc: "TTF_GlyphIsProvided32"            .}
proc glyph_metrics*(font; ch: uint16; minx, maxx, miny, maxy, advance: ptr cint): cint                    {.importc: "TTF_GlyphMetrics"                 .}
proc glyph_metrics32*(font; ch: uint32; minx, maxx, miny, maxy, advance: ptr cint): cint                  {.importc: "TTF_GlyphMetrics32"               .}
proc size_text*(font; text: cstring; w, h: ptr cint): cint                                                {.importc: "TTF_SizeText"                     .}
proc size_utf8*(font; text: cstring; w, h: ptr cint): cint                                                {.importc: "TTF_SizeUTF8"                     .}
proc size_unicode*(font; text: ptr uint16; w, h: ptr cint): cint                                          {.importc: "TTF_SizeUNICODE"                  .}
proc measure_text*(font; text: cstring; measure_width: cint; extent, count: ptr cint): cint               {.importc: "TTF_MeasureText"                  .}
proc measure_utf8*(font; text: cstring; measure_width: cint; extent, count: ptr cint): cint               {.importc: "TTF_MeasureUTF8"                  .}
proc measure_unicode*(font; text: ptr uint16; measure_width: cint; exten, count: ptr cint): cint          {.importc: "TTF_MeasureUNICODE"               .}
proc render_glyph_solid*(font; ch: uint16; fg: Colour): pointer                                           {.importc: "TTF_RenderGlyph_Solid"            .}
proc render_glyph32_solid*(font; ch: uint32; fg: Colour): pointer                                         {.importc: "TTF_RenderGlyph32_Solid"          .}
proc render_glyph_shaded*(font; ch: uint16; fg, bg: Colour): pointer                                      {.importc: "TTF_RenderGlyph_Shaded"           .}
proc render_glyph32_shaded*(font; ch: uint32; fg, bg: Colour): pointer                                    {.importc: "TTF_RenderGlyph32_Shaded"         .}
proc render_glyph_blended*(font; ch: uint16; fg: Colour): pointer                                         {.importc: "TTF_RenderGlyph_Blended"          .}
proc render_glyph32_blended*(font; ch: uint32; fg: Colour): pointer                                       {.importc: "TTF_RenderGlyph32_Blended"        .}
proc render_glyph_lcd*(font; ch: uint16; fg, bg: Colour): pointer                                         {.importc: "TTF_RenderGlyph_LCD"              .}
proc render_glyph32_lcd*(font; ch: uint32; fg, bg: Colour): pointer                                       {.importc: "TTF_RenderGlyph32_LCD"            .}
proc render_text_solid*(font; text: cstring; fg: Colour): pointer                                         {.importc: "TTF_RenderText_Solid"             .}
proc render_utf8_solid*(font; text: cstring; fg: Colour): pointer                                         {.importc: "TTF_RenderUTF8_Solid"             .}
proc render_unicode_solid*(font; text: ptr uint16; fg: Colour): pointer                                   {.importc: "TTF_RenderUNICODE_Solid"          .}
proc render_text_solid_wrapped*(font; text: cstring; fg: Colour; wrap_length: uint32): pointer            {.importc: "TTF_RenderText_Solid_Wrapped"     .}
proc render_utf8_solid_wrapped*(font; text: cstring; fg: Colour; wrap_length: uint32): pointer            {.importc: "TTF_RenderUTF8_Solid_Wrapped"     .}
proc render_unicode_solid_wrapped*(font; text: ptr uint16; fg: Colour; wrap_length: uint32): pointer      {.importc: "TTF_RenderUNICODE_Solid_Wrapped"  .}
proc render_text_shaded*(font; text: cstring; fg, bg: Colour): pointer                                    {.importc: "TTF_RenderText_Shaded"            .}
proc render_utf8_shaded*(font; text: cstring; fg, bg: Colour): pointer                                    {.importc: "TTF_RenderUTF8_Shaded"            .}
proc render_unicode_shaded*(font; text: ptr uint16; fg, bg: Colour): pointer                              {.importc: "TTF_RenderUNICODE_Shaded"         .}
proc render_text_shaded_wrapped*(font; text: cstring; fg, bg: Colour; wrap_length: uint32): pointer       {.importc: "TTF_RenderText_Shaded_Wrapped"    .}
proc render_utf8_shaded_wrapped*(font; text: cstring; fg, bg: Colour; wrap_length: uint32): pointer       {.importc: "TTF_RenderUTF8_Shaded_Wrapped"    .}
proc render_unicode_shaded_wrapped*(font; text: ptr uint16; fg, bg: Colour; wrap_length: uint32): pointer {.importc: "TTF_RenderUNICODE_Shaded_Wrapped" .}
proc render_text_blended*(font; text: cstring; fg: Colour): pointer                                       {.importc: "TTF_RenderText_Blended"           .}
proc render_utf8_blended*(font; text: cstring; fg: Colour): pointer                                       {.importc: "TTF_RenderUTF8_Blended"           .}
proc render_unicode_blended*(font; text: ptr uint16; fg: Colour): pointer                                 {.importc: "TTF_RenderUNICODE_Blended"        .}
proc render_text_blended_wrapped*(font; text: cstring; fg: Colour; wrap_length: uint32): pointer          {.importc: "TTF_RenderText_Blended_Wrapped"   .}
proc render_utf8_blended_wrapped*(font; text: cstring; fg: Colour; wrap_length: uint32): pointer          {.importc: "TTF_RenderUTF8_Blended_Wrapped"   .}
proc render_unicode_blended_wrapped*(font; text: ptr uint16; fg: Colour; wrap_length: uint32): pointer    {.importc: "TTF_RenderUNICODE_Blended_Wrapped".}
proc render_text_lcd*(font; text: cstring; fg, bg: Colour): pointer                                       {.importc: "TTF_RenderText_LCD"               .}
proc render_utf8_lcd*(font; text: cstring; fg, bg: Colour): pointer                                       {.importc: "TTF_RenderUTF8_LCD"               .}
proc render_unicode_lcd*(font; text: ptr uint16; fg, bg: Colour): pointer                                 {.importc: "TTF_RenderUNICODE_LCD"            .}
proc render_text_lcd_wrapped*(font; text: cstring; fg, bg: Colour; wrap_length: uint32): pointer          {.importc: "TTF_RenderText_LCD_Wrapped"       .}
proc render_utf8_lcd_wrapped*(font; text: cstring; fg, bg: Colour; wrap_length: uint32): pointer          {.importc: "TTF_RenderUTF8_LCD_Wrapped"       .}
proc render_unicode_lcd_wrapped*(font; text: ptr uint16; fg, bg: Colour; wrap_length: uint32): pointer    {.importc: "TTF_RenderUNICODE_LCD_Wrapped"    .}
{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}

proc get_version*(): Version = linked_version()[]
proc get_freetype_version*(): Version =
    var v: array[3, cint]
    get_freetype_version(v[0].addr, v[1].addr, v[2].addr)
    Version(major: byte v[0], minor: byte v[1], patch: byte v[2])
proc get_harfbuzz_version*(): Version =
    var v: array[3, cint]
    get_harfbuzz_version(v[0].addr, v[1].addr, v[2].addr)
    Version(major: byte v[0], minor: byte v[1], patch: byte v[2])

proc open_font*(src: string; pt_size = DefaultFontSize; index = 0; hdpi = 0; vdpi = 0): Font {.raises: SDLError.} =
    var font: pointer
    if vdpi != 0 or hdpi != 0:
        font = open_font_index_dpi(src, cint pt_size, clong index, cuint hdpi, cuint vdpi)
    else:
        font = open_font_index(src, cint pt_size, clong index)

    check_ptr[Font] "Failed to load font from file " & src:
        font
proc open_font*(stream; close_io = false; pt_size = DefaultFontSize; index = 0; hdpi = 0; vdpi = 0): Font {.raises: SDLError.} =
    var font: pointer
    if vdpi != 0 or hdpi != 0:
        font = open_font_index_dpi_io(stream, close_io, cint pt_size, clong index, cuint hdpi, cuint vdpi)
    else:
        font = open_font_index_io(stream, close_io, cint pt_size, clong index)

    check_ptr[Font] "Failed to load font from stream":
        font

proc close*(font) = close_font font

proc set_size*(font; pt_size: int) {.raises: SDLError.} =
    check_err "Failed to set font size":
        set_font_size(font, cint pt_size)
proc set_size*(font; pt_size, hdpi, vdpi: int) {.raises: SDLError.} =
    check_err "Failed to set font size with dpi":
        set_font_size_dpi(font, cint pt_size, cuint hdpi, cuint vdpi)
proc get_style*(font): FontStyle        = FontStyle get_font_style font
proc set_style*(font; style: FontStyle) = set_font_style(font, cint style)
proc get_outline*(font): int            = get_font_style font
proc set_outline*(font; outline: int) =
    assert outline >= 0
    set_font_outline(font, cint outline)
proc get_hinting*(font): Hinting                     = Hinting get_font_hinting font
proc set_hinting*(font; hinting: Hinting)            = set_font_hinting(font, cint hinting)
proc get_align*(font): Align                         = Align get_font_wrapped_align font
proc set_align*(font; align: Align)                  = set_font_wrapped_align(font, cint align)
proc get_kerning*(font): bool                        = bool get_font_kerning font
proc set_kerning*(font; kerning: bool)               = set_font_kerning(font, cint kerning)
proc set_kerning_size*(font; prev_ch, ch: Rune): int = get_font_kerning_size_glyphs32(font, uint32 prev_ch, uint32 ch)
proc get_sdf*(font): bool                            = get_font_sdf font
proc set_sdf*(font; on_off: bool) {.raises: SDLError.} =
    check_err "Failed to set font sdf":
        set_font_sdf(font, on_off)
proc set_direction*(font; direction: Direction) {.raises: SDLError.} =
    check_err "Failed to set font direction":
        set_font_direction(font, direction)
proc set_script_name*(font; script: string) {.raises: SDLError.} =
    check_err "Failed to set font script name":
        set_font_script_name(font, script)
proc set_language*(font; language: string) {.raises: SDLError.} =
    check_err "Failed to set font language":
        set_font_language(font, language)

proc height*(font): int                = font_height font
proc ascent*(font): int                = font_ascent font
proc descent*(font): int               = font_descent font
proc line_skip*(font): int             = font_line_skip font
proc faces*(font): int                 = font_faces font
proc faces_is_fixed_width*(font): bool = bool font_faces_is_fixed_width font
proc face_family_name*(font): string   = $font_face_family_name font
proc face_style_name*(font): string    = $font_face_style_name font
proc is_scalable*(font): bool          = is_font_scalable font

proc glyph_is_provided*(font; ch: Rune): bool = bool glyph_is_provided32(font, uint32 ch)
proc glyph_metrics*(font; ch: Rune): tuple[minx, maxx, miny, maxy, advance: int] {.raises: SDLError.} =
    var m: (cint, cint, cint, cint, cint)
    check_err "Failed to get glyph metrics for: " & $ch:
        glyph_metrics32(font, uint32 ch, m[0].addr, m[1].addr, m[2].addr, m[3].addr, m[4].addr)

    result.minx    = m[0]
    result.maxx    = m[1]
    result.miny    = m[2]
    result.maxy    = m[3]
    result.advance = m[4]
proc size*(font; text: string): tuple[w, h: int] {.raises: SDLError.} =
    var w, h: cint
    check_err "Failed to get utf8 size for text: " & text:
        size_utf8(font, text, w.addr, h.addr)

    result.w = w
    result.h = h
proc measure*(font; text: string; width: int): tuple[count, extent: int] {.raises: SDLError.} =
    var c, e: cint
    check_err "Failed to measure utf8 for text: " & text:
        measure_utf8(font, text, cint width, e.addr, c.addr)

    result.count  = c
    result.extent = e

proc render*(font; ch: Rune; fg, bg: Colour): Surface {.raises: SDLError.} =
    check_ptr[Surface] "Failed to render shaded glyph":
        render_glyph32_shaded(font, uint32 ch, fg, bg)
proc render*(font; ch: Rune; fg: Colour): Surface {.raises: SDLError.} =
    check_ptr[Surface] "Failed to render solid glyph":
        render_glyph32_solid(font, uint32 ch, fg)
proc render_blended*(font; ch: Rune; fg: Colour): Surface {.raises: SDLError.} =
    check_ptr[Surface] "Failed to render blended glyph":
        render_glyph32_blended(font, uint32 ch, fg)
proc render_lcd*(font; ch: Rune; fg, bg: Colour): Surface {.raises: SDLError.} =
    check_ptr[Surface] "Failed to render LCD glyph":
        render_glyph32_lcd(font, uint32 ch, fg, bg)

proc render*(font; text: string; fg: Colour): Surface {.raises: SDLError.} =
    check_ptr[Surface] "Failed to render solid text":
        render_utf8_solid(font, text, fg)
proc render*(font; text: string; fg: Colour; wrap_length: int): Surface {.raises: SDLError.} =
    check_ptr[Surface] "Failed to render solid wrapped text":
        render_utf8_solid_wrapped(font, text, fg, uint32 wrap_length)

proc render*(font; text: string; fg, bg: Colour): Surface {.raises: SDLError.} =
    check_ptr[Surface] "Failed to render shaded text":
        render_utf8_shaded(font, text, fg, bg)
proc render*(font; text: string; fg, bg: Colour; wrap_length: int): Surface {.raises: SDLError.} =
    check_ptr[Surface] "Failed to render shaded wrapped text":
        render_utf8_shaded_wrapped(font, text, fg, bg, uint32 wrap_length)

proc render_blended*(font; text: string; fg: Colour): Surface {.raises: SDLError.} =
    check_ptr[Surface] "Failed to render blended text":
        render_utf8_blended(font, text, fg)
proc render_blended*(font; text: string; fg: Colour; wrap_length: int): Surface {.raises: SDLError.} =
    check_ptr[Surface] "Failed to render blended wrapped text":
        render_utf8_blended_wrapped(font, text, fg, uint32 wrap_length)

proc render_lcd*(font; text: string; fg, bg: Colour): Surface {.raises: SDLError.} =
    check_ptr[Surface] "Failed to render lcd text":
        render_utf8_lcd(font, text, fg, bg)
proc render_lcd*(font; text: string; fg, bg: Colour; wrap_length: int): Surface {.raises: SDLError.} =
    check_ptr[Surface] "Failed to render lcd wrapped text":
        render_utf8_lcd_wrapped(font, text, fg, bg, uint32 wrap_length)

{.pop.}

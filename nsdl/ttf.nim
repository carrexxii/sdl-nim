from std/unicode import Rune
from io      import Stream
from pixels  import Colour
from surface import Surface
import common

# TODO: move to common
template check_error(msg, body) =
    when not defined NoSDLErrorChecks:
        let msgi {.inject.} = msg
        if body != 0:
            echo red fmt"Error: failed to {msgi}: {get_error()}"
    else:
        body

proc check_pointer[T](p: pointer; msg: string): Option[T] =
    let msgi {.inject.} = msg
    if p == nil:
        echo red fmt"Error: failed to get {msgi}: {get_error()}"
        result = none T
    else:
        result = some cast[T](p)

#[ -------------------------------------------------------------------- ]#

type UnicodeBOM* {.size: sizeof(cint).} = enum
    Native  = 0xFEFF
    Swapped = 0xFFFE

type FontStyle* {.size: sizeof(cint).} = enum
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

using
    file  : cstring
    stream: Stream
    font  : Font

proc linked_version*(): ptr Version                       {.importc: "TTF_Linked_Version"    , dynlib: TTFPath.}
proc get_freetype_version*(major, minor, patch: ptr cint) {.importc: "TTF_GetFreeTypeVersion", dynlib: TTFPath.}
proc get_harfbuzz_version*(major, minor, patch: ptr cint) {.importc: "TTF_GetHarfBuzzVersion", dynlib: TTFPath.}

proc get_version*(): Version {.inline.} = linked_version()[]
proc get_freetype_version*(): Version {.inline.} =
    var v: array[3, cint]
    get_freetype_version(v[0].addr, v[1].addr, v[2].addr)
    Version(major: byte v[0], minor: byte v[1], patch: byte v[2])
proc get_harfbuzz_version*(): Version {.inline.} =
    var v: array[3, cint]
    get_harfbuzz_version(v[0].addr, v[1].addr, v[2].addr)
    Version(major: byte v[0], minor: byte v[1], patch: byte v[2])

proc byte_swapped_unicode*(swapped: bool) {.importc: "TTF_ByteSwappedUNICODE", dynlib: TTFPath.}

#[ -------------------------------------------------------------------- ]#

proc init*(): cint     {.importc: "TTF_Init"   , dynlib: TTFPath.}
proc quit*()           {.importc: "TTF_Quit"   , dynlib: TTFPath.}
proc was_init*(): cint {.importc: "TTF_WasInit", dynlib: TTFPath.}

proc open_font*(file; pt_size: cint): pointer                                                                 {.importc: "TTF_OpenFont"          , dynlib: TTFPath.}
proc open_font_index*(file; pt_size: cint; index: clong): pointer                                             {.importc: "TTF_OpenFontIndex"     , dynlib: TTFPath.}
proc open_font_io*(stream; close_io: bool; pt_size: cint): pointer                                            {.importc: "TTF_OpenFontIO"        , dynlib: TTFPath.}
proc open_font_index_io*(stream; close_io: bool; pt_size: cint; index: clong): pointer                        {.importc: "TTF_OpenFontIndexIO"   , dynlib: TTFPath.}
proc open_font_dpi*(file; pt_size: cint; hdpi, vdpi: cuint): pointer                                          {.importc: "TTF_OpenFontDPI"       , dynlib: TTFPath.}
proc open_font_index_dpi*(file; pt_size: cint; index: clong; hdpi, vdpi: cuint): pointer                      {.importc: "TTF_OpenFontIndexDPI"  , dynlib: TTFPath.}
proc open_font_dpi_io*(stream; close_io: bool; pt_size: cint; hdpi, vdpi: cuint): pointer                     {.importc: "TTF_OpenFontDPIIO"     , dynlib: TTFPath.}
proc open_font_index_dpi_io*(stream; close_io: bool; pt_size: cint; index: clong; hdpi, vdpi: cuint): pointer {.importc: "TTF_OpenFontIndexDPIIO", dynlib: TTFPath.}

proc open_font*(src: string; pt_size = 14; index = 0; hdpi = 0; vdpi = 0): Font =
    var font: pointer
    if vdpi != 0 or hdpi != 0:
        font = open_font_index_dpi(src, cint pt_size, clong index, cuint hdpi, cuint vdpi)
    else:
        font = open_font_index(src, cint pt_size, clong index)

    if font == nil:
        echo red fmt"Error: failed to load font from file ({src}): {get_error()}"
    else:
        result = cast[Font](font)
proc open_font*(stream; close_io = false; pt_size = 14; index = 0; hdpi = 0; vdpi = 0): Font =
    var font: pointer
    if vdpi != 0 or hdpi != 0:
        font = open_font_index_dpi_io(stream, close_io, cint pt_size, clong index, cuint hdpi, cuint vdpi)
    else:
        font = open_font_index_io(stream, close_io, cint pt_size, clong index)

    if font == nil:
        echo red fmt"Error: failed to load font from stream: {get_error()}"
    else:
        result = cast[Font](font)

proc close_font*(font) {.importc: "TTF_CloseFont", dynlib: TTFPath.}
proc close*(font) {.inline.} = close_font font

#~Settings/Info~#######################################################

proc set_font_size*(font; pt_size: cint): cint                        {.importc: "TTF_SetFontSize"               , dynlib: TTFPath.}
proc set_font_size_dpi*(font; pt_size: cint; hdpi, vdpi: cuint): cint {.importc: "TTF_SetFontSizeDPI"            , dynlib: TTFPath.}
proc get_font_style*(font): cint                                      {.importc: "TTF_GetFontStyle"              , dynlib: TTFPath.}
proc set_font_style*(font; style: cint)                               {.importc: "TTF_SetFontStyle"              , dynlib: TTFPath.}
proc get_font_outline*(font): cint                                    {.importc: "TTF_GetFontOutline"            , dynlib: TTFPath.}
proc set_font_outline*(font; outline: cint)                           {.importc: "TTF_SetFontOutline"            , dynlib: TTFPath.}
proc get_font_hinting*(font): cint                                    {.importc: "TTF_GetFontHinting"            , dynlib: TTFPath.}
proc set_font_hinting*(font; hinting: cint)                           {.importc: "TTF_SetFontHinting"            , dynlib: TTFPath.}
proc get_font_wrapped_align*(font): cint                              {.importc: "TTF_GetFontWrappedAlign"       , dynlib: TTFPath.}
proc set_font_wrapped_align*(font; align: cint)                       {.importc: "TTF_SetFontWrappedAlign"       , dynlib: TTFPath.}
proc get_font_kerning*(font): cint                                    {.importc: "TTF_GetFontKerning"            , dynlib: TTFPath.}
proc set_font_kerning*(font; allowed: cint)                           {.importc: "TTF_SetFontKerning"            , dynlib: TTFPath.}
proc get_font_kerning_size_glyphs*(font; prev_ch, ch: uint16): cint   {.importc: "TTF_GetFontKerningSizeGlyphs"  , dynlib: TTFPath.}
proc get_font_kerning_size_glyphs32*(font; prev_ch, ch: uint32): cint {.importc: "TTF_GetFontKerningSizeGlyphs32", dynlib: TTFPath.}
proc get_font_sdf*(font): bool                                        {.importc: "TTF_GetFontSDF"                , dynlib: TTFPath.}
proc set_font_sdf*(font; on_off: bool): cint                          {.importc: "TTF_SetFontSDF"                , dynlib: TTFPath.}
proc set_font_direction*(font; direction: Direction): cint            {.importc: "TTF_SetFontDirection"          , dynlib: TTFPath.}
proc set_font_script_name*(font; script: cstring): cint               {.importc: "TTF_SetFontScriptName"         , dynlib: TTFPath.}
proc set_font_language*(font; language: cstring): cint                {.importc: "TTF_SetFontLanguage"           , dynlib: TTFPath.}

proc set_size*(font; pt_size: int)             {.inline.} = check_error "set font size": set_font_size(font, cint pt_size)
proc set_size*(font; pt_size, hdpi, vdpi: int) {.inline.} = check_error "set font size with dpi": set_font_size_dpi(font, cint pt_size, cuint hdpi, cuint vdpi)
proc get_style*(font): FontStyle               {.inline.} = FontStyle get_font_style font
proc set_style*(font; style: FontStyle)        {.inline.} = set_font_style(font, cint style)
proc get_outline*(font): int                   {.inline.} = get_font_style font
proc set_outline*(font; outline: int) {.inline.} =
    assert outline >= 0
    set_font_outline(font, cint outline)
proc get_hinting*(font): Hinting                     {.inline.} = Hinting get_font_hinting font
proc set_hinting*(font; hinting: Hinting)            {.inline.} = set_font_hinting(font, cint hinting)
proc get_align*(font): Align                         {.inline.} = Align get_font_wrapped_align font
proc set_align*(font; align: Align)                  {.inline.} = set_font_wrapped_align(font, cint align)
proc get_kerning*(font): bool                        {.inline.} = bool get_font_kerning font
proc set_kerning*(font; kerning: bool)               {.inline.} = set_font_kerning(font, cint kerning)
proc set_kerning_size*(font; prev_ch, ch: Rune): int {.inline.} = get_font_kerning_size_glyphs32(font, uint32 prev_ch, uint32 ch)
proc get_sdf*(font): bool                            {.inline.} = get_font_sdf font
proc set_sdf*(font; on_off: bool)                    {.inline.} = check_error "setting sdf"        : set_font_sdf(font, on_off)
proc set_direction*(font; direction: Direction)      {.inline.} = check_error "setting direction"  : set_font_direction(font, direction)
proc set_script_name*(font; script: string)          {.inline.} = check_error "setting script name": set_font_script_name(font, script)
proc set_language*(font; language: string)           {.inline.} = check_error "setting language"   : set_font_language(font, language)


proc font_height*(font): cint               {.importc: "TTF_FontHeight"          , dynlib: TTFPath.}
proc font_ascent*(font): cint               {.importc: "TTF_FontAscent"          , dynlib: TTFPath.}
proc font_descent*(font): cint              {.importc: "TTF_FontDescent"         , dynlib: TTFPath.}
proc font_line_skip*(font): cint            {.importc: "TTF_FontLineSkip"        , dynlib: TTFPath.}
proc font_faces*(font): clong               {.importc: "TTF_FontFaces"           , dynlib: TTFPath.}
proc font_faces_is_fixed_width*(font): cint {.importc: "TTF_FontFaceIsFixedWidth", dynlib: TTFPath.}
proc font_face_family_name*(font): cstring  {.importc: "TTF_FontFaceFamilyName"  , dynlib: TTFPath.}
proc font_face_style_name*(font): cstring   {.importc: "TTF_FontFaceStyleName"   , dynlib: TTFPath.}
proc is_font_scalable*(font): bool          {.importc: "TTF_IsFontScalable"      , dynlib: TTFPath.}

proc height*(font): int                {.inline.} = font_height font
proc ascent*(font): int                {.inline.} = font_ascent font
proc descent*(font): int               {.inline.} = font_descent font
proc line_skip*(font): int             {.inline.} = font_line_skip font
proc faces*(font): int                 {.inline.} = font_faces font
proc faces_is_fixed_width*(font): bool {.inline.} = bool font_faces_is_fixed_width font
proc face_family_name*(font): string   {.inline.} = $font_face_family_name font
proc face_style_name*(font): string    {.inline.} = $font_face_style_name font
proc is_scalable*(font): bool          {.inline.} = is_font_scalable font

proc glyph_is_provided*(font; ch: uint16): cint                                                  {.importc: "TTF_GlyphIsProvided"  , dynlib: TTFPath.}
proc glyph_is_provided32*(font; ch: uint32): cint                                                {.importc: "TTF_GlyphIsProvided32", dynlib: TTFPath.}
proc glyph_metrics*(font; ch: uint16; minx, maxx, miny, maxy, advance: ptr cint): cint           {.importc: "TTF_GlyphMetrics"     , dynlib: TTFPath.}
proc glyph_metrics32*(font; ch: uint32; minx, maxx, miny, maxy, advance: ptr cint): cint         {.importc: "TTF_GlyphMetrics32"   , dynlib: TTFPath.}
proc size_text*(font; text: cstring; w, h: ptr cint): cint                                       {.importc: "TTF_SizeText"         , dynlib: TTFPath.}
proc size_utf8*(font; text: cstring; w, h: ptr cint): cint                                       {.importc: "TTF_SizeUTF8"         , dynlib: TTFPath.}
proc size_unicode*(font; text: ptr uint16; w, h: ptr cint): cint                                 {.importc: "TTF_SizeUNICODE"      , dynlib: TTFPath.}
proc measure_text*(font; text: cstring; measure_width: cint; extent, count: ptr cint): cint      {.importc: "TTF_MeasureText"      , dynlib: TTFPath.}
proc measure_utf8*(font; text: cstring; measure_width: cint; extent, count: ptr cint): cint      {.importc: "TTF_MeasureUTF8"      , dynlib: TTFPath.}
proc measure_unicode*(font; text: ptr uint16; measure_width: cint; exten, count: ptr cint): cint {.importc: "TTF_MeasureUNICODE"   , dynlib: TTFPath.}

proc glyph_is_provided*(font; ch: Rune): bool {.inline.} = bool glyph_is_provided32(font, uint32 ch)
proc glyph_metrics*(font; ch: Rune): tuple[minx, maxx, miny, maxy, advance: int] {.inline.} =
    var m: (cint, cint, cint, cint, cint)
    check_error fmt"get glyph metrics for '{ch}'":
        glyph_metrics32(font, uint32 ch, m[0].addr, m[1].addr, m[2].addr, m[3].addr, m[4].addr)

    result.minx    = m[0]
    result.maxx    = m[1]
    result.miny    = m[2]
    result.maxy    = m[3]
    result.advance = m[4]
proc size*(font; text: string): tuple[w, h: int] {.inline.} =
    var w, h: cint
    check_error "get utf8 size":
        size_utf8(font, text, w.addr, h.addr)

    result.w = w
    result.h = h
proc measure*(font; text: string; width: int): tuple[count, extent: int] {.inline.} =
    var c, e: cint
    check_error "measure utf8 text":
        measure_utf8(font, text, cint width, e.addr, c.addr)

    result.count  = c
    result.extent = e

#~Rendering~###########################################################

# TODO: default colours

proc render_glyph_solid*(font; ch: uint16; fg: Colour): pointer        {.importc: "TTF_RenderGlyph_Solid"    , dynlib: TTFPath.}
proc render_glyph32_solid*(font; ch: uint32; fg: Colour): pointer      {.importc: "TTF_RenderGlyph32_Solid"  , dynlib: TTFPath.}
proc render_glyph_shaded*(font; ch: uint16; fg, bg: Colour): pointer   {.importc: "TTF_RenderGlyph_Shaded"   , dynlib: TTFPath.}
proc render_glyph32_shaded*(font; ch: uint32; fg, bg: Colour): pointer {.importc: "TTF_RenderGlyph32_Shaded" , dynlib: TTFPath.}
proc render_glyph_blended*(font; ch: uint16; fg: Colour): pointer      {.importc: "TTF_RenderGlyph_Blended"  , dynlib: TTFPath.}
proc render_glyph32_blended*(font; ch: uint32; fg: Colour): pointer    {.importc: "TTF_RenderGlyph32_Blended", dynlib: TTFPath.}
proc render_glyph_lcd*(font; ch: uint16; fg, bg: Colour): pointer      {.importc: "TTF_RenderGlyph_LCD"      , dynlib: TTFPath.}
proc render_glyph32_lcd*(font; ch: uint32; fg, bg: Colour): pointer    {.importc: "TTF_RenderGlyph32_LCD"    , dynlib: TTFPath.}

proc render*(font; ch: Rune; fg, bg: Colour): Option[Surface] {.inline.} =
    check_pointer[Surface](render_glyph32_shaded(font, uint32 ch, fg, bg), "render shaded glyph")
proc render*(font; ch: Rune; fg: Colour): Option[Surface] {.inline.} =
    check_pointer[Surface](render_glyph32_solid(font, uint32 ch, fg), "render solid glyph")
proc render_blended*(font; ch: Rune; fg: Colour): Option[Surface] {.inline.} =
    check_pointer[Surface](render_glyph32_blended(font, uint32 ch, fg), "render blended glyph")
proc render_lcd*(font; ch: Rune; fg, bg: Colour): Option[Surface] {.inline.} =
    check_pointer[Surface](render_glyph32_lcd(font, uint32 ch, fg, bg), "render lcd glyph")

proc render_text_solid*(font; text: cstring; fg: Colour): pointer                                         {.importc: "TTF_RenderText_Solid"             , dynlib: TTFPath.}
proc render_utf8_solid*(font; text: cstring; fg: Colour): pointer                                         {.importc: "TTF_RenderUTF8_Solid"             , dynlib: TTFPath.}
proc render_unicode_solid*(font; text: ptr uint16; fg: Colour): pointer                                   {.importc: "TTF_RenderUNICODE_Solid"          , dynlib: TTFPath.}
proc render_text_solid_wrapped*(font; text: cstring; fg: Colour; wrap_length: uint32): pointer            {.importc: "TTF_RenderText_Solid_Wrapped"     , dynlib: TTFPath.}
proc render_utf8_solid_wrapped*(font; text: cstring; fg: Colour; wrap_length: uint32): pointer            {.importc: "TTF_RenderUTF8_Solid_Wrapped"     , dynlib: TTFPath.}
proc render_unicode_solid_wrapped*(font; text: ptr uint16; fg: Colour; wrap_length: uint32): pointer      {.importc: "TTF_RenderUNICODE_Solid_Wrapped"  , dynlib: TTFPath.}
proc render_text_shaded*(font; text: cstring; fg, bg: Colour): pointer                                    {.importc: "TTF_RenderText_Shaded"            , dynlib: TTFPath.}
proc render_utf8_shaded*(font; text: cstring; fg, bg: Colour): pointer                                    {.importc: "TTF_RenderUTF8_Shaded"            , dynlib: TTFPath.}
proc render_unicode_shaded*(font; text: ptr uint16; fg, bg: Colour): pointer                              {.importc: "TTF_RenderUNICODE_Shaded"         , dynlib: TTFPath.}
proc render_text_shaded_wrapped*(font; text: cstring; fg, bg: Colour; wrap_length: uint32): pointer       {.importc: "TTF_RenderText_Shaded_Wrapped"    , dynlib: TTFPath.}
proc render_utf8_shaded_wrapped*(font; text: cstring; fg, bg: Colour; wrap_length: uint32): pointer       {.importc: "TTF_RenderUTF8_Shaded_Wrapped"    , dynlib: TTFPath.}
proc render_unicode_shaded_wrapped*(font; text: ptr uint16; fg, bg: Colour; wrap_length: uint32): pointer {.importc: "TTF_RenderUNICODE_Shaded_Wrapped" , dynlib: TTFPath.}
proc render_text_blended*(font; text: cstring; fg: Colour): pointer                                       {.importc: "TTF_RenderText_Blended"           , dynlib: TTFPath.}
proc render_utf8_blended*(font; text: cstring; fg: Colour): pointer                                       {.importc: "TTF_RenderUTF8_Blended"           , dynlib: TTFPath.}
proc render_unicode_blended*(font; text: ptr uint16; fg: Colour): pointer                                 {.importc: "TTF_RenderUNICODE_Blended"        , dynlib: TTFPath.}
proc render_text_blended_wrapped*(font; text: cstring; fg: Colour; wrap_length: uint32): pointer          {.importc: "TTF_RenderText_Blended_Wrapped"   , dynlib: TTFPath.}
proc render_utf8_blended_wrapped*(font; text: cstring; fg: Colour; wrap_length: uint32): pointer          {.importc: "TTF_RenderUTF8_Blended_Wrapped"   , dynlib: TTFPath.}
proc render_unicode_blended_wrapped*(font; text: ptr uint16; fg: Colour; wrap_length: uint32): pointer    {.importc: "TTF_RenderUNICODE_Blended_Wrapped", dynlib: TTFPath.}
proc render_text_lcd*(font; text: cstring; fg, bg: Colour): pointer                                       {.importc: "TTF_RenderText_LCD"               , dynlib: TTFPath.}
proc render_utf8_lcd*(font; text: cstring; fg, bg: Colour): pointer                                       {.importc: "TTF_RenderUTF8_LCD"               , dynlib: TTFPath.}
proc render_unicode_lcd*(font; text: ptr uint16; fg, bg: Colour): pointer                                 {.importc: "TTF_RenderUNICODE_LCD"            , dynlib: TTFPath.}
proc render_text_lcd_wrapped*(font; text: cstring; fg, bg: Colour; wrap_length: uint32): pointer          {.importc: "TTF_RenderText_LCD_Wrapped"       , dynlib: TTFPath.}
proc render_utf8_lcd_wrapped*(font; text: cstring; fg, bg: Colour; wrap_length: uint32): pointer          {.importc: "TTF_RenderUTF8_LCD_Wrapped"       , dynlib: TTFPath.}
proc render_unicode_lcd_wrapped*(font; text: ptr uint16; fg, bg: Colour; wrap_length: uint32): pointer    {.importc: "TTF_RenderUNICODE_LCD_Wrapped"    , dynlib: TTFPath.}

proc render*(font; text: string; fg: Colour): Option[Surface] {.inline.} =
    check_pointer[Surface](render_utf8_solid(font, text, fg), "render solid text")
proc render*(font; text: string; fg: Colour; wrap_length: int): Option[Surface] {.inline.} =
    check_pointer[Surface](render_utf8_solid_wrapped(font, text, fg, uint32 wrap_length), "render solid wrapped text")
proc render*(font; text: string; fg, bg: Colour): Option[Surface] {.inline.} =
    check_pointer[Surface](render_utf8_shaded(font, text, fg, bg), "render shaded text")
proc render*(font; text: string; fg, bg: Colour; wrap_length: int): Option[Surface] {.inline.} =
    check_pointer[Surface](render_utf8_shaded_wrapped(font, text, fg, bg, uint32 wrap_length), "render shaded wrapped text")
proc render_blended*(font; text: string; fg: Colour): Option[Surface] {.inline.} =
    check_pointer[Surface](render_utf8_blended(font, text, fg), "render blended text")
proc render_blended*(font; text: string; fg: Colour; wrap_length: int): Option[Surface] {.inline.} =
    check_pointer[Surface](render_utf8_blended_wrapped(font, text, fg, uint32 wrap_length), "render blended wrapped text")
proc render_lcd*(font; text: string; fg, bg: Colour): Option[Surface] {.inline.} =
    check_pointer[Surface](render_utf8_lcd(font, text, fg, bg), "render lcd text")
proc render_lcd*(font; text: string; fg, bg: Colour; wrap_length: int): Option[Surface] {.inline.} =
    check_pointer[Surface](render_utf8_lcd_wrapped(font, text, fg, bg, uint32 wrap_length), "render lcd wrapped text")

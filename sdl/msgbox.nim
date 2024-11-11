import bitgen

type
    MessageBoxFlag* {.size: sizeof(uint32).} = enum
        msgBoxError       = 0x0010
        msgBoxWarning     = 0x0020
        msgBoxInformation = 0x0040
        msgBoxButtonsLtr  = 0x0080
        msgBoxButtonsRtl  = 0x0100

    MessageBoxButtonFlag* {.size: sizeof(uint32).} = enum
        msgBoxButtonReturnKeyDefault = 1
        msgBoxButtonEscapeKeyDefault = 2

    MessageBoxColourKind* {.size: sizeof(cint).} = enum
        msgBoxColourBackground
        msgBoxColourText
        msgBoxColourButtonBorder
        msgBoxColourButtonbackground
        msgBoxColourButtonSelected

type
    MessageBoxButtonData* = object
        flags*: MessageBoxButtonFlag
        id*   : cint
        text* : cstring

    MessageBoxColour* = object
        r*: uint8
        g*: uint8
        b*: uint8

    MessageBoxColourScheme* = object
        colours*: array[1 + high MessageBoxColourKind, MessageBoxColour]

    MessageBoxData* = object
        flags*        : MessageBoxFlag
        win*          : Window
        title*        : cstring
        msg*          : cstring
        btn_count*    : cint
        btns*         : ptr UncheckedArray[MessageBoxButtonData]
        colour_scheme*: ptr MessageBoxColourScheme

{.push dynlib: SdlLib.}
proc show_message_box*(data: ptr MessageBoxData; btn_id: ptr cint): bool                     {.importc: "SDL_ShowMessageBox"      .}
proc show_simple_message_box*(flags: MessageBoxFlag; title, msg: cstring; win: Window): bool {.importc: "SDL_ShowSimpleMessageBox".}
{.pop.}

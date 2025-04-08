import std/options, bitgen, common
from video import Window

type MessageBoxFlag* = distinct uint32
MessageBoxFlag.gen_bit_ops(
    _, _, _, _,
    Error, Warning, Information, ButtonsLeftToRight,
    ButtonsRightToLeft,
)

type MessageBoxButtonFlag* = distinct uint32
MessageBoxButtonFlag.gen_bit_ops MsgButtonReturnKeyDefault, MsgButtonEscapeKeyDefault

type MessageBoxColourKind* = enum
    Background
    Text
    ButtonBorder
    ButtonBackground
    ButtonSelected

type
    MessageBoxButton* = object
        flags* : MessageBoxButtonFlag
        btn_id*: cint
        text*  : cstring

    MessageBoxColour* = object
        r*: uint8
        g*: uint8
        b*: uint8

    MessageBoxColourScheme* = object
        colours*: array[MessageBoxColourKind.high.ord + 1, MessageBoxColour]

    MessageBox* = object
        flags*: MessageBoxFlag
        win*  : Window
        title*: cstring
        msg*  : cstring

        btn_cnt*: cint
        btns*   : ptr UncheckedArray[MessageBoxButton]
        scheme* : ptr MessageBoxColourScheme

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_ShowMessageBox*(msg_box_data: ptr MessageBox; btn_id: ptr cint): bool
proc SDL_ShowSimpleMessageBox*(flags: MessageBoxFlag; title, msg: cstring; win: Window): bool
{.pop.}

{.push inline.}

proc show_message_box*(win: Window; flags: MessageBoxFlag; title, msg: string;
                       btns  : openArray[MessageBoxButton];
                       scheme: Option[MessageBoxColourScheme] = none MessageBoxColourScheme;
                       ): int32 =
    let data = MessageBox(
        flags  : flags,
        win    : win,
        title  : cstring title,
        msg    : cstring msg,
        btn_cnt: cint btns.len,
        btns   : cast[ptr UncheckedArray[MessageBoxButton]](btns[0].addr),
        scheme : if scheme.is_some: (get scheme).addr else: nil,
    )
    let success = SDL_ShowMessageBox(data.addr, result.addr)
    sdl_assert success, &"Failed to show message box with title \"{title}\" and message \"{msg}\""

proc show_simple_message_box*(win: Window; flags: MessageBoxFlag; title, msg: string): bool {.discardable.} =
    result = SDL_ShowSimpleMessageBox(flags, cstring title, cstring msg, win)
    sdl_assert result, &"Failed to show simple message box with title \"{title}\" and message \"{msg}\""

{.pop.}

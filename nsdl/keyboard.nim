from video import Window
from rect  import Rect
import common

type ScanCode* = enum
    Unknown = 0

    A = 4
    B = 5
    C = 6
    D = 7
    E = 8
    F = 9
    G = 10
    H = 11
    I = 12
    J = 13
    K = 14
    L = 15
    M = 16
    N = 17
    O = 18
    P = 19
    Q = 20
    R = 21
    S = 22
    T = 23
    U = 24
    V = 25
    W = 26
    X = 27
    Y = 28
    Z = 29

    N1 = 30
    N2 = 31
    N3 = 32
    N4 = 33
    N5 = 34
    N6 = 35
    N7 = 36
    N8 = 37
    N9 = 38
    N0 = 39

    Return    = 40
    Escape    = 41
    Backspace = 42
    Tab       = 43
    Space     = 44

    Minus        = 45
    Equals       = 46
    LeftBracket  = 47
    RightBracket = 48
    Backslash    = 49
    NonUSHash    = 50
    SemiColon    = 51
    Apostrophe   = 52
    Grave        = 53
    Comma        = 54
    Period       = 55
    Slash        = 56

    CapsLock = 57

    F1  = 58
    F2  = 59
    F3  = 60
    F4  = 61
    F5  = 62
    F6  = 63
    F7  = 64
    F8  = 65
    F9  = 66
    F10 = 67
    F11 = 68
    F12 = 69

    PrintScreen = 70
    ScrollLock  = 71
    Pause       = 72
    Insert      = 73
    Home        = 74
    PageUp      = 75
    Delete      = 76
    End         = 77
    PageDown    = 78
    Right       = 79
    Left        = 80
    Down        = 81
    Up          = 82

    NumLockClear = 83
    KPDivide     = 84
    KPMultiply   = 85
    KPMinus      = 86
    KPPlus       = 87
    KPEnter      = 88
    KP1          = 89
    KP2          = 90
    KP3          = 91
    KP4          = 92
    KP5          = 93
    KP6          = 94
    KP7          = 95
    KP8          = 96
    KP9          = 97
    KP0          = 98
    KPPeriod     = 99

    NonUSBackSlash = 100
    Application    = 101
    Power          = 102
    KPEquals       = 103
    F13            = 104
    F14            = 105
    F15            = 106
    F16            = 107
    F17            = 108
    F18            = 109
    F19            = 110
    F20            = 111
    F21            = 112
    F22            = 113
    F23            = 114
    F24            = 115

    Execute    = 116
    Help       = 117
    Menu       = 118
    Select     = 119
    Stop       = 120
    Again      = 121
    Undo       = 122
    Cut        = 123
    Copy       = 124
    Paste      = 125
    Find       = 126
    Mute       = 127
    VolumeUp   = 128
    VolumeDown = 129

    KPComma = 133

    International1 = 135
    International2 = 136
    International3 = 137
    International4 = 138
    International5 = 139
    International6 = 140
    International7 = 141
    International8 = 142
    International9 = 143
    Lang1 = 144
    Lang2 = 145
    Lang3 = 146
    Lang4 = 147
    Lang5 = 148
    Lang6 = 149
    Lang7 = 150
    Lang8 = 151
    Lang9 = 152

    AltErase   = 153
    SysReq     = 154
    Cancel     = 155
    Clear      = 156
    Prior      = 157
    Return2    = 158
    Seperator  = 159
    Out        = 160
    Oper       = 161
    ClearAgain = 162
    CRSel      = 163
    EXSel      = 164

    KP00               = 176
    KP000              = 177
    ThousandsSeperator = 178
    DecimalSeperator   = 179
    CurrencyUnit       = 180
    CurrencySubunit    = 181
    KPLeftParen        = 182
    KPRightParen       = 183
    KPLeftBrace        = 184
    KPRightBrace       = 185
    KPTab              = 186
    KPBackspace        = 187
    KPA                = 188
    KPB                = 189
    KPC                = 190
    KPD                = 191
    KPE                = 192
    KPF                = 193
    KPXOR              = 194
    KPPower            = 195
    KPPercent          = 196
    KPLess             = 197
    KPGreater          = 198
    KPAmpersand        = 199
    KPDblAmpersand     = 200
    KPVerticalBar      = 201
    KPDblVerticalBar   = 202
    KPColon            = 203
    KPHash             = 204
    KPSpace            = 205
    KPAt               = 206
    KPExclam           = 207
    KPMemStore         = 208
    KPMemRecall        = 209
    KPMemClear         = 210
    KPMemAdd           = 211
    KPMemSubtract      = 212
    KPMemMultiply      = 213
    KPMemDivide        = 214
    KPPlusMinus        = 215
    KPClear            = 216
    KPClearEntry       = 217
    KPBinary           = 218
    KPOctal            = 219
    KPDecimal          = 220
    KPHexadecimal      = 221

    LCtrl  = 224
    LShift = 225
    LAlt   = 226
    LGUI   = 227
    RCtrl  = 228
    RShift = 229
    RAlt   = 230
    RGUI   = 231

    Mode = 257

    AudioNext   = 258
    AudioPrev   = 259
    AudioStop   = 260
    AudioPlay   = 261
    AudioMute   = 262
    MediaSelect = 263
    WWW         = 264
    Mail        = 265
    Calculator  = 266
    Computer    = 267
    ACSearch    = 268
    ACHome      = 269
    ACBack      = 270
    ACForward   = 271
    ACStop      = 272
    ACRefresh   = 273
    ACBookmarks = 274

    BrightnessDown = 275
    BrightnessUp   = 276
    DisplaySwitch  = 277
    KbdIllumToggle = 278
    KbdIllumDown   = 279
    KbdIllumUp     = 280
    Eject          = 281
    Sleep          = 282

    App1 = 283
    App2 = 284

    AudioRewind      = 285
    AudioFastForward = 286

    SoftLeft  = 287
    SoftRight = 288
    Call      = 289
    EndCall   = 290

#[ -------------------------------------------------------------------- ]#

const ScanCodeMask = 1'u32 shl 30
converter to_uint32(x: ScanCode): uint32 = uint32 x
template scancode_to_keycode(code: ScanCode): untyped =
    code or ScanCodeMask

type KeyCode* = distinct uint32
const
    KeyUnknown*            = KeyCode 0
    KeyReturn*             = KeyCode  '\r'
    KeyEscape*             = KeyCode '\x1B'
    KeyBackspace*          = KeyCode  '\b'
    KeyTab*                = KeyCode '\t'
    KeySpace*              = KeyCode ' '
    KeyExclaim*            = KeyCode  '!'
    KeyQuoteDbl*           = KeyCode '"'
    KeyHash*               = KeyCode '#'
    KeyPercent*            = KeyCode '%'
    KeyDollar*             = KeyCode '$'
    KeyAmpersand*          = KeyCode '&'
    KeyQuote*              = KeyCode '\''
    KeyLeftParen*          = KeyCode  '('
    KeyRightParen*         = KeyCode ')'
    KeyAsterisk*           = KeyCode '*'
    KeyPlus*               = KeyCode '+'
    KeyComma*              = KeyCode ','
    KeyMinus*              = KeyCode '-'
    KeyPeriod*             = KeyCode '.'
    KeySlash*              = KeyCode '/'
    Key0*                  = KeyCode '0'
    Key1*                  = KeyCode '1'
    Key2*                  = KeyCode '2'
    Key3*                  = KeyCode '3'
    Key4*                  = KeyCode '4'
    Key5*                  = KeyCode '5'
    Key6*                  = KeyCode '6'
    Key7*                  = KeyCode '7'
    Key8*                  = KeyCode '8'
    Key9*                  = KeyCode '9'
    KeyColon*              = KeyCode ':'
    KeySemiColon*          = KeyCode ';'
    KeyLess*               = KeyCode '<'
    KeyEquals*             = KeyCode '='
    KeyGreater*            = KeyCode '>'
    KeyQuestion*           = KeyCode '?'
    KeyAt*                 = KeyCode '@'
    KeyLeftBracket*        = KeyCode '['
    KeyBackSlash*          = KeyCode '\\'
    KeyRightBracket*       = KeyCode ']'
    KeyCaret*              = KeyCode '^'
    KeyUnderscore*         = KeyCode '_'
    KeyBackQuote*          = KeyCode '`'
    KeyA*                  = KeyCode 'a'
    KeyB*                  = KeyCode 'b'
    KeyC*                  = KeyCode 'c'
    KeyD*                  = KeyCode 'd'
    KeyE*                  = KeyCode 'e'
    KeyF*                  = KeyCode 'f'
    KeyG*                  = KeyCode 'g'
    KeyH*                  = KeyCode 'h'
    KeyI*                  = KeyCode 'i'
    KeyJ*                  = KeyCode 'j'
    KeyK*                  = KeyCode 'k'
    KeyL*                  = KeyCode 'l'
    KeyM*                  = KeyCode 'm'
    KeyN*                  = KeyCode 'n'
    KeyO*                  = KeyCode 'o'
    KeyP*                  = KeyCode 'p'
    KeyQ*                  = KeyCode 'q'
    KeyR*                  = KeyCode 'r'
    KeyS*                  = KeyCode 's'
    KeyT*                  = KeyCode 't'
    KeyU*                  = KeyCode 'u'
    KeyV*                  = KeyCode 'v'
    KeyW*                  = KeyCode 'w'
    KeyX*                  = KeyCode 'x'
    KeyY*                  = KeyCode 'y'
    KeyZ*                  = KeyCode 'z'
    KeyCapsLock*           = KeyCode scancode_to_keycode(ScanCode.CapsLock)
    KeyF1*                 = KeyCode scancode_to_keycode(ScanCode.F1)
    KeyF2*                 = KeyCode scancode_to_keycode(ScanCode.F2)
    KeyF3*                 = KeyCode scancode_to_keycode(ScanCode.F3)
    KeyF4*                 = KeyCode scancode_to_keycode(ScanCode.F4)
    KeyF5*                 = KeyCode scancode_to_keycode(ScanCode.F5)
    KeyF6*                 = KeyCode scancode_to_keycode(ScanCode.F6)
    KeyF7*                 = KeyCode scancode_to_keycode(ScanCode.F7)
    KeyF8*                 = KeyCode scancode_to_keycode(ScanCode.F8)
    KeyF9*                 = KeyCode scancode_to_keycode(ScanCode.F9)
    KeyF10*                = KeyCode scancode_to_keycode(ScanCode.F10)
    KeyF11*                = KeyCode scancode_to_keycode(ScanCode.F11)
    KeyF12*                = KeyCode scancode_to_keycode(ScanCode.F12)
    KeyPrintScreen*        = KeyCode scancode_to_keycode(ScanCode.PrintScreen)
    KeyScrollLock*         = KeyCode scancode_to_keycode(ScanCode.ScrollLock)
    KeyPause*              = KeyCode scancode_to_keycode(ScanCode.Pause)
    KeyInsert*             = KeyCode scancode_to_keycode(ScanCode.Insert)
    KeyHome*               = KeyCode scancode_to_keycode(ScanCode.Home)
    KeyPageUp*             = KeyCode scancode_to_keycode(ScanCode.PageUp)
    KeyDelete*             = KeyCode '\x7F'
    KeyEnd*                = KeyCode scancode_to_keycode(ScanCode.End)
    KeyPageDown*           = KeyCode scancode_to_keycode(ScanCode.PageDown)
    KeyRight*              = KeyCode scancode_to_keycode(ScanCode.Right)
    KeyLeft*               = KeyCode scancode_to_keycode(ScanCode.Left)
    KeyDown*               = KeyCode scancode_to_keycode(ScanCode.Down)
    KeyUp*                 = KeyCode scancode_to_keycode(ScanCode.Up)
    KeyNumLockClear*       = KeyCode scancode_to_keycode(ScanCode.NumLockClear)
    KeyKPDivide*           = KeyCode scancode_to_keycode(ScanCode.KPDivide)
    KeyKPMultiply*         = KeyCode scancode_to_keycode(ScanCode.KPMultiply)
    KeyKPMinus*            = KeyCode scancode_to_keycode(ScanCode.KPMinus)
    KeyKPPlus*             = KeyCode scancode_to_keycode(ScanCode.KPPlus)
    KeyKPEnter*            = KeyCode scancode_to_keycode(ScanCode.KPEnter)
    KeyKP1*                = KeyCode scancode_to_keycode(ScanCode.KP1)
    KeyKP2*                = KeyCode scancode_to_keycode(ScanCode.KP2)
    KeyKP3*                = KeyCode scancode_to_keycode(ScanCode.KP3)
    KeyKP4*                = KeyCode scancode_to_keycode(ScanCode.KP4)
    KeyKP5*                = KeyCode scancode_to_keycode(ScanCode.KP5)
    KeyKP6*                = KeyCode scancode_to_keycode(ScanCode.KP6)
    KeyKP7*                = KeyCode scancode_to_keycode(ScanCode.KP7)
    KeyKP8*                = KeyCode scancode_to_keycode(ScanCode.KP8)
    KeyKP9*                = KeyCode scancode_to_keycode(ScanCode.KP9)
    KeyKP0*                = KeyCode scancode_to_keycode(ScanCode.KP0)
    KeyKPPeriod*           = KeyCode scancode_to_keycode(ScanCode.KPPeriod)
    KeyApplication*        = KeyCode scancode_to_keycode(ScanCode.Application)
    KeyPower*              = KeyCode scancode_to_keycode(ScanCode.Power)
    KeyKPEquals*           = KeyCode scancode_to_keycode(ScanCode.KPEquals)
    KeyF13*                = KeyCode scancode_to_keycode(ScanCode.F13)
    KeyF14*                = KeyCode scancode_to_keycode(ScanCode.F14)
    KeyF15*                = KeyCode scancode_to_keycode(ScanCode.F15)
    KeyF16*                = KeyCode scancode_to_keycode(ScanCode.F16)
    KeyF17*                = KeyCode scancode_to_keycode(ScanCode.F17)
    KeyF18*                = KeyCode scancode_to_keycode(ScanCode.F18)
    KeyF19*                = KeyCode scancode_to_keycode(ScanCode.F19)
    KeyF20*                = KeyCode scancode_to_keycode(ScanCode.F20)
    KeyF21*                = KeyCode scancode_to_keycode(ScanCode.F21)
    KeyF22*                = KeyCode scancode_to_keycode(ScanCode.F22)
    KeyF23*                = KeyCode scancode_to_keycode(ScanCode.F23)
    KeyF24*                = KeyCode scancode_to_keycode(ScanCode.F24)
    KeyExecute*            = KeyCode scancode_to_keycode(ScanCode.Execute)
    KeyHelp*               = KeyCode scancode_to_keycode(ScanCode.Help)
    KeyMenu*               = KeyCode scancode_to_keycode(ScanCode.Menu)
    KeySelect*             = KeyCode scancode_to_keycode(ScanCode.Select)
    KeyStop*               = KeyCode scancode_to_keycode(ScanCode.Stop)
    KeyAgain*              = KeyCode scancode_to_keycode(ScanCode.Again)
    KeyUndo*               = KeyCode scancode_to_keycode(ScanCode.Undo)
    KeyCut*                = KeyCode scancode_to_keycode(ScanCode.Cut)
    KeyCopy*               = KeyCode scancode_to_keycode(ScanCode.Copy)
    KeyPaste*              = KeyCode scancode_to_keycode(ScanCode.Paste)
    KeyFind*               = KeyCode scancode_to_keycode(ScanCode.Find)
    KeyMute*               = KeyCode scancode_to_keycode(ScanCode.Mute)
    KeyVolumeUp*           = KeyCode scancode_to_keycode(ScanCode.VolumeUp)
    KeyVolumeDown*         = KeyCode scancode_to_keycode(ScanCode.VolumeDown)
    KeyKPComma*            = KeyCode scancode_to_keycode(ScanCode.KPComma)
    KeyAltErase*           = KeyCode scancode_to_keycode(ScanCode.AltErase)
    KeySysReq*             = KeyCode scancode_to_keycode(ScanCode.SysReq)
    KeyCancel*             = KeyCode scancode_to_keycode(ScanCode.Cancel)
    KeyClear*              = KeyCode scancode_to_keycode(ScanCode.Clear)
    KeyPrior*              = KeyCode scancode_to_keycode(ScanCode.Prior)
    KeyReturn2*            = KeyCode scancode_to_keycode(ScanCode.Return2)
    KeySeperator*          = KeyCode scancode_to_keycode(ScanCode.Seperator)
    KeyOut*                = KeyCode scancode_to_keycode(ScanCode.Out)
    KeyOper*               = KeyCode scancode_to_keycode(ScanCode.Oper)
    KeyClearAgain*         = KeyCode scancode_to_keycode(ScanCode.ClearAgain)
    KeyCRSel*              = KeyCode scancode_to_keycode(ScanCode.CRSel)
    KeyEXSel*              = KeyCode scancode_to_keycode(ScanCode.EXSel)
    KeyKP00*               = KeyCode scancode_to_keycode(ScanCode.KP00)
    KeyKP000*              = KeyCode scancode_to_keycode(ScanCode.KP000)
    KeyThousandsSeperator* = KeyCode scancode_to_keycode(ScanCode.ThousandsSeperator)
    KeyDecimalSeperator*   = KeyCode scancode_to_keycode(ScanCode.DecimalSeperator)
    KeyCurrencyUnit*       = KeyCode scancode_to_keycode(ScanCode.CurrencyUnit)
    KeyCurrencySubUnit*    = KeyCode scancode_to_keycode(ScanCode.CurrencySubUnit)
    KeyKPLeftParen*        = KeyCode scancode_to_keycode(ScanCode.KPLeftParen)
    KeyKPRightParen*       = KeyCode scancode_to_keycode(ScanCode.KPRightParen)
    KeyKPLeftBrace*        = KeyCode scancode_to_keycode(ScanCode.KPLeftBrace)
    KeyKPRightBrace*       = KeyCode scancode_to_keycode(ScanCode.KPRightBrace)
    KeyKPTab*              = KeyCode scancode_to_keycode(ScanCode.KPTab)
    KeyKPBackspace*        = KeyCode scancode_to_keycode(ScanCode.KPBackspace)
    KeyKPA*                = KeyCode scancode_to_keycode(ScanCode.KPA)
    KeyKPB*                = KeyCode scancode_to_keycode(ScanCode.KPB)
    KeyKPC*                = KeyCode scancode_to_keycode(ScanCode.KPC)
    KeyKPD*                = KeyCode scancode_to_keycode(ScanCode.KPD)
    KeyKPE*                = KeyCode scancode_to_keycode(ScanCode.KPE)
    KeyKPF*                = KeyCode scancode_to_keycode(ScanCode.KPF)
    KeyKPXOR*              = KeyCode scancode_to_keycode(ScanCode.KPXOR)
    KeyKPPower*            = KeyCode scancode_to_keycode(ScanCode.KPPower)
    KeyKPPercent*          = KeyCode scancode_to_keycode(ScanCode.KPPercent)
    KeyKPLess*             = KeyCode scancode_to_keycode(ScanCode.KPLess)
    KeyKPGreater*          = KeyCode scancode_to_keycode(ScanCode.KPGreater)
    KeyKPAmpersand*        = KeyCode scancode_to_keycode(ScanCode.KPAmpersand)
    KeyKPDblAmpersand*     = KeyCode scancode_to_keycode(ScanCode.KPDblAmpersand)
    KeyKPVerticalBar*      = KeyCode scancode_to_keycode(ScanCode.KPVerticalBar)
    KeyKPDblVerticalBar*   = KeyCode scancode_to_keycode(ScanCode.KPDblVerticalBar)
    KeyKPColon*            = KeyCode scancode_to_keycode(ScanCode.KPColon)
    KeyKPHash*             = KeyCode scancode_to_keycode(ScanCode.KPHash)
    KeyKPSpace*            = KeyCode scancode_to_keycode(ScanCode.KPSpace)
    KeyKPAt*               = KeyCode scancode_to_keycode(ScanCode.KPAt)
    KeyKPExclam*           = KeyCode scancode_to_keycode(ScanCode.KP_Exclam)
    KeyKPMemStore*         = KeyCode scancode_to_keycode(ScanCode.KPMemStore)
    KeyKPMemRecall*        = KeyCode scancode_to_keycode(ScanCode.KPMemRecall)
    KeyKPMemClear*         = KeyCode scancode_to_keycode(ScanCode.KPMemClear)
    KeyKPMemAdd*           = KeyCode scancode_to_keycode(ScanCode.KPMemAdd)
    KeyKPMemSubtract*      = KeyCode scancode_to_keycode(ScanCode.KPMemSubtract)
    KeyKPMemMultiply*      = KeyCode scancode_to_keycode(ScanCode.KPMemMultiply)
    KeyKPMemDivide*        = KeyCode scancode_to_keycode(ScanCode.KPMemDivide)
    KeyKPPlusMinus*        = KeyCode scancode_to_keycode(ScanCode.KPPlusMinus)
    KeyKPClear*            = KeyCode scancode_to_keycode(ScanCode.KPClear)
    KeyKPClearEntry*       = KeyCode scancode_to_keycode(ScanCode.KPClearEntry)
    KeyKPBinary*           = KeyCode scancode_to_keycode(ScanCode.KPBinary)
    KeyKPOctal*            = KeyCode scancode_to_keycode(ScanCode.KPOctal)
    KeyKPDecimal*          = KeyCode scancode_to_keycode(ScanCode.KPDecimal)
    KeyKPHexadecimal*      = KeyCode scancode_to_keycode(ScanCode.KPHexadecimal)
    KeyLCtrl*              = KeyCode scancode_to_keycode(ScanCode.LCtrl)
    KeyLShift*             = KeyCode scancode_to_keycode(ScanCode.LShift)
    KeyLAlt*               = KeyCode scancode_to_keycode(ScanCode.LAlt)
    KeyLGUI*               = KeyCode scancode_to_keycode(ScanCode.LGUI)
    KeyRCtrl*              = KeyCode scancode_to_keycode(ScanCode.RCtrl)
    KeyRShift*             = KeyCode scancode_to_keycode(ScanCode.RShift)
    KeyRAlt*               = KeyCode scancode_to_keycode(ScanCode.RAlt)
    KeyRGUI*               = KeyCode scancode_to_keycode(ScanCode.RGUI)
    KeyMode*               = KeyCode scancode_to_keycode(ScanCode.Mode)
    KeyAudioNext*          = KeyCode scancode_to_keycode(ScanCode.AudioNext)
    KeyAudioPrev*          = KeyCode scancode_to_keycode(ScanCode.AudioPrev)
    KeyAudioStop*          = KeyCode scancode_to_keycode(ScanCode.AudioStop)
    KeyAudioPlay*          = KeyCode scancode_to_keycode(ScanCode.AudioPlay)
    KeyAudioMute*          = KeyCode scancode_to_keycode(ScanCode.AudioMute)
    KeyMediaSelect*        = KeyCode scancode_to_keycode(ScanCode.MediaSelect)
    KeyWWW*                = KeyCode scancode_to_keycode(ScanCode.WWW)
    KeyMail*               = KeyCode scancode_to_keycode(ScanCode.Mail)
    KeyCalculator*         = KeyCode scancode_to_keycode(ScanCode.Calculator)
    KeyComputer*           = KeyCode scancode_to_keycode(ScanCode.Computer)
    KeyACSearch*           = KeyCode scancode_to_keycode(ScanCode.ACSearch)
    KeyACHome*             = KeyCode scancode_to_keycode(ScanCode.ACHome)
    KeyACBack*             = KeyCode scancode_to_keycode(ScanCode.ACBack)
    KeyACForward*          = KeyCode scancode_to_keycode(ScanCode.ACForward)
    KeyACStop*             = KeyCode scancode_to_keycode(ScanCode.ACStop)
    KeyACRefresh*          = KeyCode scancode_to_keycode(ScanCode.ACRefresh)
    KeyACBookmarks*        = KeyCode scancode_to_keycode(ScanCode.ACBookmarks)
    KeyBrightnessDown*     = KeyCode scancode_to_keycode(ScanCode.BrightnessDown)
    KeyBrightnessUp*       = KeyCode scancode_to_keycode(ScanCode.BrightnessUp)
    KeyDisplaySwitch*      = KeyCode scancode_to_keycode(ScanCode.DisplaySwitch)
    KeyKbdIllumToggle*     = KeyCode scancode_to_keycode(ScanCode.KbdIllumToggle)
    KeyKbdIllumDown*       = KeyCode scancode_to_keycode(ScanCode.KbdIllumDown)
    KeyKbdIllumUp*         = KeyCode scancode_to_keycode(ScanCode.KbdIllumUp)
    KeyEject*              = KeyCode scancode_to_keycode(ScanCode.Eject)
    KeySleep*              = KeyCode scancode_to_keycode(ScanCode.Sleep)
    KeyApp1*               = KeyCode scancode_to_keycode(ScanCode.App1)
    KeyApp2*               = KeyCode scancode_to_keycode(ScanCode.App2)
    KeyAudioRewind*        = KeyCode scancode_to_keycode(ScanCode.AudioRewind)
    KeyAudioFastForward*   = KeyCode scancode_to_keycode(ScanCode.AudioFastForward)
    KeySoftLeft*           = KeyCode scancode_to_keycode(ScanCode.SoftLeft)
    KeySoftRight*          = KeyCode scancode_to_keycode(ScanCode.SoftRight)
    KeyCall*               = KeyCode scancode_to_keycode(ScanCode.Call)
    KeyEndCall*            = KeyCode scancode_to_keycode(ScanCode.EndCall)

#[ -------------------------------------------------------------------- ]#

type Keymod* {.size: sizeof(uint16).} = enum
    None   = 0x0000
    LShift = 0x0001
    RShift = 0x0002
    Shift  = 0x0001 or 0x0002
    LCtrl  = 0x0040
    RCtrl  = 0x0080
    Ctrl   = 0x0040 or 0x0080
    LAlt   = 0x0100
    RAlt   = 0x0200
    Alt    = 0x0100 or 0x0200
    LGUI   = 0x0400
    RGUI   = 0x0800
    GUI    = 0x0400 or 0x0800
    Num    = 0x1000
    Caps   = 0x2000
    Mode   = 0x4000
    Scroll = 0x8000

#[ -------------------------------------------------------------------- ]#

type
    KeyboardID* = distinct uint32

    Keysym* = object
        scancode*: Scancode
        sym*     : Keycode
        modifier*: Keymod
        _        : uint16

{.push dynlib: SDLPath.}
proc has_keyboard*(): bool                                         {.importc: "SDL_HasKeyboard"             .}
proc get_keyboards*(count: ptr cint): ptr KeyboardID               {.importc: "SDL_GetKeyboards"            .}
proc get_keyboard_instance_name*(instance_id: KeyboardID): cstring {.importc: "SDL_GetKeyboardInstanceName" .}
proc get_keyboard_focus*(): Window                                 {.importc: "SDL_GetKeyboardFocus"        .}
proc get_keyboard_state*(key_count: ptr cint): ptr uint8           {.importc: "SDL_GetKeyboardState"        .}
proc reset_keyboard*()                                             {.importc: "SDL_ResetKeyboard"           .}
proc get_mod_state*(): Keymod                                      {.importc: "SDL_GetModState"             .}
proc set_mod_state*(mod_state: Keymod)                             {.importc: "SDL_SetModState"             .}
proc get_key_from_scancode*(scancode: Scancode): Keycode           {.importc: "SDL_GetKeyFromScancode"      .}
proc get_scancode_from_key*(key: Keycode): Scancode                {.importc: "SDL_GetScancodeFromKey"      .}
proc get_scancode_name*(scancode: Scancode): cstring               {.importc: "SDL_GetScancodeName"         .}
proc get_scancode_from_name*(name: cstring): Scancode              {.importc: "SDL_GetScancodeFromName"     .}
proc get_key_name*(key: Keycode): cstring                          {.importc: "SDL_GetKeyName"              .}
proc get_key_from_name*(name: cstring): Keycode                    {.importc: "SDL_GetKeyFromName"          .}
proc start_text_input*()                                           {.importc: "SDL_StartTextInput"          .}
proc text_input_active*(): bool                                    {.importc: "SDL_TextInputActive"         .}
proc stop_text_input*()                                            {.importc: "SDL_StopTextInput"           .}
proc clear_composition*()                                          {.importc: "SDL_ClearComposition"        .}
proc set_text_input_rect*(rect: ptr Rect): cint                    {.importc: "SDL_SetTextInputRect"        .}
proc has_screen_keyboard_support*(): bool                          {.importc: "SDL_HasScreenKeyboardSupport".}
proc screen_keyboard_shown*(window: Window): bool                  {.importc: "SDL_ScreenKeyboardShown"     .}
{.pop.}

{.push inline.}

proc get_keyboards*(): seq[KeyboardID] {.raises: SDLError.} =
    var count: cint
    var keyboards = check_ptr[ptr UncheckedArray[KeyboardID]] "Failed to get keyboards":
        get_keyboards count.addr

    for keyboard in to_open_array(keyboards, 0, count - 1):
        result.add keyboard

proc get_name*(instance_id: KeyboardID): string {.raises: SDLError.} =
    check_ptr[string] "Failed to get keyboard instance's name":
        get_keyboard_instance_name instance_id

proc get_keyboard_state*(): tuple[count: int; keys: ptr UncheckedArray[bool]] {.raises: SDLError.} =
    var count: cint
    result.keys = check_ptr[ptr UncheckedArray[bool]] "Failed to key keyboard state":
        get_keyboard_state count.addr
    result.count = count

proc get_key*(code: Scancode): Keycode     = get_key_from_scancode code
proc get_key*(name: string): Keycode       = get_key_from_name name
proc get_scancode*(key: Keycode): Scancode = get_scancode_from_key key
proc get_scancode*(name: string): Scancode = get_scancode_from_name name
proc `$`*(code: Scancode): string = $get_scancode_name code
proc `$`*(key: Keycode): string   = $get_key_name key

proc set_text_input_rect*(rect: Rect) {.raises: SDLError.} =
    check_err "Failed to set text input rect":
        set_text_input_rect rect.addr

{.pop.}

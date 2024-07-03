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
    KUnknown*            = KeyCode 0
    KReturn*             = KeyCode  '\r'
    KEscape*             = KeyCode '\x1B'
    KBackspace*          = KeyCode  '\b'
    KTab*                = KeyCode '\t'
    KSpace*              = KeyCode ' '
    KExclaim*            = KeyCode  '!'
    KQuoteDbl*           = KeyCode '"'
    KHash*               = KeyCode '#'
    KPercent*            = KeyCode '%'
    KDollar*             = KeyCode '$'
    KAmpersand*          = KeyCode '&'
    KQuote*              = KeyCode '\''
    KLeftParen*          = KeyCode  '('
    KRightParen*         = KeyCode ')'
    KAsterisk*           = KeyCode '*'
    KPlus*               = KeyCode '+'
    KComma*              = KeyCode ','
    KMinus*              = KeyCode '-'
    KPeriod*             = KeyCode '.'
    KSlash*              = KeyCode '/'
    K0*                  = KeyCode '0'
    K1*                  = KeyCode '1'
    K2*                  = KeyCode '2'
    K3*                  = KeyCode '3'
    K4*                  = KeyCode '4'
    K5*                  = KeyCode '5'
    K6*                  = KeyCode '6'
    K7*                  = KeyCode '7'
    K8*                  = KeyCode '8'
    K9*                  = KeyCode '9'
    KColon*              = KeyCode ':'
    KSemiColon*          = KeyCode ';'
    KLess*               = KeyCode '<'
    KEquals*             = KeyCode '='
    KGreater*            = KeyCode '>'
    KQuestion*           = KeyCode '?'
    KAt*                 = KeyCode '@'
    KLeftBracket*        = KeyCode '['
    KBackSlash*          = KeyCode '\\'
    KRightBracket*       = KeyCode ']'
    KCaret*              = KeyCode '^'
    KUnderscore*         = KeyCode '_'
    KBackQuote*          = KeyCode '`'
    KA*                  = KeyCode 'a'
    KB*                  = KeyCode 'b'
    KC*                  = KeyCode 'c'
    KD*                  = KeyCode 'd'
    KE*                  = KeyCode 'e'
    KF*                  = KeyCode 'f'
    KG*                  = KeyCode 'g'
    KH*                  = KeyCode 'h'
    KI*                  = KeyCode 'i'
    KJ*                  = KeyCode 'j'
    KK*                  = KeyCode 'k'
    KL*                  = KeyCode 'l'
    KM*                  = KeyCode 'm'
    KN*                  = KeyCode 'n'
    KO*                  = KeyCode 'o'
    KP*                  = KeyCode 'p'
    KQ*                  = KeyCode 'q'
    KR*                  = KeyCode 'r'
    KS*                  = KeyCode 's'
    KT*                  = KeyCode 't'
    KU*                  = KeyCode 'u'
    KV*                  = KeyCode 'v'
    KW*                  = KeyCode 'w'
    KX*                  = KeyCode 'x'
    KY*                  = KeyCode 'y'
    KZ*                  = KeyCode 'z'
    KCapsLock*           = KeyCode scancode_to_keycode(ScanCode.CapsLock)
    KF1*                 = KeyCode scancode_to_keycode(ScanCode.F1)
    KF2*                 = KeyCode scancode_to_keycode(ScanCode.F2)
    KF3*                 = KeyCode scancode_to_keycode(ScanCode.F3)
    KF4*                 = KeyCode scancode_to_keycode(ScanCode.F4)
    KF5*                 = KeyCode scancode_to_keycode(ScanCode.F5)
    KF6*                 = KeyCode scancode_to_keycode(ScanCode.F6)
    KF7*                 = KeyCode scancode_to_keycode(ScanCode.F7)
    KF8*                 = KeyCode scancode_to_keycode(ScanCode.F8)
    KF9*                 = KeyCode scancode_to_keycode(ScanCode.F9)
    KF10*                = KeyCode scancode_to_keycode(ScanCode.F10)
    KF11*                = KeyCode scancode_to_keycode(ScanCode.F11)
    KF12*                = KeyCode scancode_to_keycode(ScanCode.F12)
    KPrintScreen*        = KeyCode scancode_to_keycode(ScanCode.PrintScreen)
    KScrollLock*         = KeyCode scancode_to_keycode(ScanCode.ScrollLock)
    KPause*              = KeyCode scancode_to_keycode(ScanCode.Pause)
    KInsert*             = KeyCode scancode_to_keycode(ScanCode.Insert)
    KHome*               = KeyCode scancode_to_keycode(ScanCode.Home)
    KPageUp*             = KeyCode scancode_to_keycode(ScanCode.PageUp)
    KDelete*             = KeyCode '\x7F'
    KEnd*                = KeyCode scancode_to_keycode(ScanCode.End)
    KPageDown*           = KeyCode scancode_to_keycode(ScanCode.PageDown)
    KRight*              = KeyCode scancode_to_keycode(ScanCode.Right)
    KLeft*               = KeyCode scancode_to_keycode(ScanCode.Left)
    KDown*               = KeyCode scancode_to_keycode(ScanCode.Down)
    KUp*                 = KeyCode scancode_to_keycode(ScanCode.Up)
    KNumLockClear*       = KeyCode scancode_to_keycode(ScanCode.NumLockClear)
    KKPDivide*           = KeyCode scancode_to_keycode(ScanCode.KPDivide)
    KKPMultiply*         = KeyCode scancode_to_keycode(ScanCode.KPMultiply)
    KKPMinus*            = KeyCode scancode_to_keycode(ScanCode.KPMinus)
    KKPPlus*             = KeyCode scancode_to_keycode(ScanCode.KPPlus)
    KKPEnter*            = KeyCode scancode_to_keycode(ScanCode.KPEnter)
    KKP1*                = KeyCode scancode_to_keycode(ScanCode.KP1)
    KKP2*                = KeyCode scancode_to_keycode(ScanCode.KP2)
    KKP3*                = KeyCode scancode_to_keycode(ScanCode.KP3)
    KKP4*                = KeyCode scancode_to_keycode(ScanCode.KP4)
    KKP5*                = KeyCode scancode_to_keycode(ScanCode.KP5)
    KKP6*                = KeyCode scancode_to_keycode(ScanCode.KP6)
    KKP7*                = KeyCode scancode_to_keycode(ScanCode.KP7)
    KKP8*                = KeyCode scancode_to_keycode(ScanCode.KP8)
    KKP9*                = KeyCode scancode_to_keycode(ScanCode.KP9)
    KKP0*                = KeyCode scancode_to_keycode(ScanCode.KP0)
    KKPPeriod*           = KeyCode scancode_to_keycode(ScanCode.KPPeriod)
    KApplication*        = KeyCode scancode_to_keycode(ScanCode.Application)
    KPower*              = KeyCode scancode_to_keycode(ScanCode.Power)
    KKPEquals*           = KeyCode scancode_to_keycode(ScanCode.KPEquals)
    KF13*                = KeyCode scancode_to_keycode(ScanCode.F13)
    KF14*                = KeyCode scancode_to_keycode(ScanCode.F14)
    KF15*                = KeyCode scancode_to_keycode(ScanCode.F15)
    KF16*                = KeyCode scancode_to_keycode(ScanCode.F16)
    KF17*                = KeyCode scancode_to_keycode(ScanCode.F17)
    KF18*                = KeyCode scancode_to_keycode(ScanCode.F18)
    KF19*                = KeyCode scancode_to_keycode(ScanCode.F19)
    KF20*                = KeyCode scancode_to_keycode(ScanCode.F20)
    KF21*                = KeyCode scancode_to_keycode(ScanCode.F21)
    KF22*                = KeyCode scancode_to_keycode(ScanCode.F22)
    KF23*                = KeyCode scancode_to_keycode(ScanCode.F23)
    KF24*                = KeyCode scancode_to_keycode(ScanCode.F24)
    KExecute*            = KeyCode scancode_to_keycode(ScanCode.Execute)
    KHelp*               = KeyCode scancode_to_keycode(ScanCode.Help)
    KMenu*               = KeyCode scancode_to_keycode(ScanCode.Menu)
    KSelect*             = KeyCode scancode_to_keycode(ScanCode.Select)
    KStop*               = KeyCode scancode_to_keycode(ScanCode.Stop)
    KAgain*              = KeyCode scancode_to_keycode(ScanCode.Again)
    KUndo*               = KeyCode scancode_to_keycode(ScanCode.Undo)
    KCut*                = KeyCode scancode_to_keycode(ScanCode.Cut)
    KCopy*               = KeyCode scancode_to_keycode(ScanCode.Copy)
    KPaste*              = KeyCode scancode_to_keycode(ScanCode.Paste)
    KFind*               = KeyCode scancode_to_keycode(ScanCode.Find)
    KMute*               = KeyCode scancode_to_keycode(ScanCode.Mute)
    KVolumeUp*           = KeyCode scancode_to_keycode(ScanCode.VolumeUp)
    KVolumeDown*         = KeyCode scancode_to_keycode(ScanCode.VolumeDown)
    KKPComma*            = KeyCode scancode_to_keycode(ScanCode.KPComma)
    KAltErase*           = KeyCode scancode_to_keycode(ScanCode.AltErase)
    KSysReq*             = KeyCode scancode_to_keycode(ScanCode.SysReq)
    KCancel*             = KeyCode scancode_to_keycode(ScanCode.Cancel)
    KClear*              = KeyCode scancode_to_keycode(ScanCode.Clear)
    KPrior*              = KeyCode scancode_to_keycode(ScanCode.Prior)
    KReturn2*            = KeyCode scancode_to_keycode(ScanCode.Return2)
    KSeperator*          = KeyCode scancode_to_keycode(ScanCode.Seperator)
    KOut*                = KeyCode scancode_to_keycode(ScanCode.Out)
    KOper*               = KeyCode scancode_to_keycode(ScanCode.Oper)
    KClearAgain*         = KeyCode scancode_to_keycode(ScanCode.ClearAgain)
    KCRSel*              = KeyCode scancode_to_keycode(ScanCode.CRSel)
    KEXSel*              = KeyCode scancode_to_keycode(ScanCode.EXSel)
    KKP00*               = KeyCode scancode_to_keycode(ScanCode.KP00)
    KKP000*              = KeyCode scancode_to_keycode(ScanCode.KP000)
    KThousandsSeperator* = KeyCode scancode_to_keycode(ScanCode.ThousandsSeperator)
    KDecimalSeperator*   = KeyCode scancode_to_keycode(ScanCode.DecimalSeperator)
    KCurrencyUnit*       = KeyCode scancode_to_keycode(ScanCode.CurrencyUnit)
    KCurrencySubUnit*    = KeyCode scancode_to_keycode(ScanCode.CurrencySubUnit)
    KKPLeftParen*        = KeyCode scancode_to_keycode(ScanCode.KPLeftParen)
    KKPRightParen*       = KeyCode scancode_to_keycode(ScanCode.KPRightParen)
    KKPLeftBrace*        = KeyCode scancode_to_keycode(ScanCode.KPLeftBrace)
    KKPRightBrace*       = KeyCode scancode_to_keycode(ScanCode.KPRightBrace)
    KKPTab*              = KeyCode scancode_to_keycode(ScanCode.KPTab)
    KKPBackspace*        = KeyCode scancode_to_keycode(ScanCode.KPBackspace)
    KKPA*                = KeyCode scancode_to_keycode(ScanCode.KPA)
    KKPB*                = KeyCode scancode_to_keycode(ScanCode.KPB)
    KKPC*                = KeyCode scancode_to_keycode(ScanCode.KPC)
    KKPD*                = KeyCode scancode_to_keycode(ScanCode.KPD)
    KKPE*                = KeyCode scancode_to_keycode(ScanCode.KPE)
    KKPF*                = KeyCode scancode_to_keycode(ScanCode.KPF)
    KKPXOR*              = KeyCode scancode_to_keycode(ScanCode.KPXOR)
    KKPPower*            = KeyCode scancode_to_keycode(ScanCode.KPPower)
    KKPPercent*          = KeyCode scancode_to_keycode(ScanCode.KPPercent)
    KKPLess*             = KeyCode scancode_to_keycode(ScanCode.KPLess)
    KKPGreater*          = KeyCode scancode_to_keycode(ScanCode.KPGreater)
    KKPAmpersand*        = KeyCode scancode_to_keycode(ScanCode.KPAmpersand)
    KKPDblAmpersand*     = KeyCode scancode_to_keycode(ScanCode.KPDblAmpersand)
    KKPVerticalBar*      = KeyCode scancode_to_keycode(ScanCode.KPVerticalBar)
    KKPDblVerticalBar*   = KeyCode scancode_to_keycode(ScanCode.KPDblVerticalBar)
    KKPColon*            = KeyCode scancode_to_keycode(ScanCode.KPColon)
    KKPHash*             = KeyCode scancode_to_keycode(ScanCode.KPHash)
    KKPSpace*            = KeyCode scancode_to_keycode(ScanCode.KPSpace)
    KKPAt*               = KeyCode scancode_to_keycode(ScanCode.KPAt)
    KKPExclam*           = KeyCode scancode_to_keycode(ScanCode.KP_Exclam)
    KKPMemStore*         = KeyCode scancode_to_keycode(ScanCode.KPMemStore)
    KKPMemRecall*        = KeyCode scancode_to_keycode(ScanCode.KPMemRecall)
    KKPMemClear*         = KeyCode scancode_to_keycode(ScanCode.KPMemClear)
    KKPMemAdd*           = KeyCode scancode_to_keycode(ScanCode.KPMemAdd)
    KKPMemSubtract*      = KeyCode scancode_to_keycode(ScanCode.KPMemSubtract)
    KKPMemMultiply*      = KeyCode scancode_to_keycode(ScanCode.KPMemMultiply)
    KKPMemDivide*        = KeyCode scancode_to_keycode(ScanCode.KPMemDivide)
    KKPPlusMinus*        = KeyCode scancode_to_keycode(ScanCode.KPPlusMinus)
    KKPClear*            = KeyCode scancode_to_keycode(ScanCode.KPClear)
    KKPClearEntry*       = KeyCode scancode_to_keycode(ScanCode.KPClearEntry)
    KKPBinary*           = KeyCode scancode_to_keycode(ScanCode.KPBinary)
    KKPOctal*            = KeyCode scancode_to_keycode(ScanCode.KPOctal)
    KKPDecimal*          = KeyCode scancode_to_keycode(ScanCode.KPDecimal)
    KKPHexadecimal*      = KeyCode scancode_to_keycode(ScanCode.KPHexadecimal)
    KLCtrl*              = KeyCode scancode_to_keycode(ScanCode.LCtrl)
    KLShift*             = KeyCode scancode_to_keycode(ScanCode.LShift)
    KLAlt*               = KeyCode scancode_to_keycode(ScanCode.LAlt)
    KLGUI*               = KeyCode scancode_to_keycode(ScanCode.LGUI)
    KRCtrl*              = KeyCode scancode_to_keycode(ScanCode.RCtrl)
    KRShift*             = KeyCode scancode_to_keycode(ScanCode.RShift)
    KRAlt*               = KeyCode scancode_to_keycode(ScanCode.RAlt)
    KRGUI*               = KeyCode scancode_to_keycode(ScanCode.RGUI)
    KMode*               = KeyCode scancode_to_keycode(ScanCode.Mode)
    KAudioNext*          = KeyCode scancode_to_keycode(ScanCode.AudioNext)
    KAudioPrev*          = KeyCode scancode_to_keycode(ScanCode.AudioPrev)
    KAudioStop*          = KeyCode scancode_to_keycode(ScanCode.AudioStop)
    KAudioPlay*          = KeyCode scancode_to_keycode(ScanCode.AudioPlay)
    KAudioMute*          = KeyCode scancode_to_keycode(ScanCode.AudioMute)
    KMediaSelect*        = KeyCode scancode_to_keycode(ScanCode.MediaSelect)
    KWWW*                = KeyCode scancode_to_keycode(ScanCode.WWW)
    KMail*               = KeyCode scancode_to_keycode(ScanCode.Mail)
    KCalculator*         = KeyCode scancode_to_keycode(ScanCode.Calculator)
    KComputer*           = KeyCode scancode_to_keycode(ScanCode.Computer)
    KACSearch*           = KeyCode scancode_to_keycode(ScanCode.ACSearch)
    KACHome*             = KeyCode scancode_to_keycode(ScanCode.ACHome)
    KACBack*             = KeyCode scancode_to_keycode(ScanCode.ACBack)
    KACForward*          = KeyCode scancode_to_keycode(ScanCode.ACForward)
    KACStop*             = KeyCode scancode_to_keycode(ScanCode.ACStop)
    KACRefresh*          = KeyCode scancode_to_keycode(ScanCode.ACRefresh)
    KACBookmarks*        = KeyCode scancode_to_keycode(ScanCode.ACBookmarks)
    KBrightnessDown*     = KeyCode scancode_to_keycode(ScanCode.BrightnessDown)
    KBrightnessUp*       = KeyCode scancode_to_keycode(ScanCode.BrightnessUp)
    KDisplaySwitch*      = KeyCode scancode_to_keycode(ScanCode.DisplaySwitch)
    KKbdIllumToggle*     = KeyCode scancode_to_keycode(ScanCode.KbdIllumToggle)
    KKbdIllumDown*       = KeyCode scancode_to_keycode(ScanCode.KbdIllumDown)
    KKbdIllumUp*         = KeyCode scancode_to_keycode(ScanCode.KbdIllumUp)
    KEject*              = KeyCode scancode_to_keycode(ScanCode.Eject)
    KSleep*              = KeyCode scancode_to_keycode(ScanCode.Sleep)
    KApp1*               = KeyCode scancode_to_keycode(ScanCode.App1)
    KApp2*               = KeyCode scancode_to_keycode(ScanCode.App2)
    KAudioRewind*        = KeyCode scancode_to_keycode(ScanCode.AudioRewind)
    KAudioFastForward*   = KeyCode scancode_to_keycode(ScanCode.AudioFastForward)
    KSoftLeft*           = KeyCode scancode_to_keycode(ScanCode.SoftLeft)
    KSoftRight*          = KeyCode scancode_to_keycode(ScanCode.SoftRight)
    KCall*               = KeyCode scancode_to_keycode(ScanCode.Call)
    KEndCall*            = KeyCode scancode_to_keycode(ScanCode.EndCall)

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

{.push dynlib: SDLLib.}
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

import common, bitgen
from video import Window
from rect  import Rect

type ScanCode* = enum
    scUnknown = 0

    scA = 4
    scB = 5
    scC = 6
    scD = 7
    scE = 8
    scF = 9
    scG = 10
    scH = 11
    scI = 12
    scJ = 13
    scK = 14
    scL = 15
    scM = 16
    scN = 17
    scO = 18
    scP = 19
    scQ = 20
    scR = 21
    scS = 22
    scT = 23
    scU = 24
    scV = 25
    scW = 26
    scX = 27
    scY = 28
    scZ = 29

    sc1 = 30
    sc2 = 31
    sc3 = 32
    sc4 = 33
    sc5 = 34
    sc6 = 35
    sc7 = 36
    sc8 = 37
    sc9 = 38
    sc0 = 39

    scReturn    = 40
    scEscape    = 41
    scBackspace = 42
    scTab       = 43
    scSpace     = 44

    scMinus        = 45
    scEquals       = 46
    scLeftBracket  = 47
    scRightBracket = 48
    scBackslash    = 49
    scNonUSHash    = 50
    scSemiColon    = 51
    scApostrophe   = 52
    scGrave        = 53
    scComma        = 54
    scPeriod       = 55
    scSlash        = 56

    scCapsLock = 57

    scF1  = 58
    scF2  = 59
    scF3  = 60
    scF4  = 61
    scF5  = 62
    scF6  = 63
    scF7  = 64
    scF8  = 65
    scF9  = 66
    scF10 = 67
    scF11 = 68
    scF12 = 69

    scPrintScreen = 70
    scScrollLock  = 71
    scPause       = 72
    scInsert      = 73
    scHome        = 74
    scPageUp      = 75
    scDelete      = 76
    scEnd         = 77
    scPageDown    = 78
    scRight       = 79
    scLeft        = 80
    scDown        = 81
    scUp          = 82

    scNumLockClear = 83
    scKPDivide     = 84
    scKPMultiply   = 85
    scKPMinus      = 86
    scKPPlus       = 87
    scKPEnter      = 88
    scKP1          = 89
    scKP2          = 90
    scKP3          = 91
    scKP4          = 92
    scKP5          = 93
    scKP6          = 94
    scKP7          = 95
    scKP8          = 96
    scKP9          = 97
    scKP0          = 98
    scKPPeriod     = 99

    scNonUSBackSlash = 100
    scApplication    = 101
    scPower          = 102
    scKPEquals       = 103
    scF13            = 104
    scF14            = 105
    scF15            = 106
    scF16            = 107
    scF17            = 108
    scF18            = 109
    scF19            = 110
    scF20            = 111
    scF21            = 112
    scF22            = 113
    scF23            = 114
    scF24            = 115

    scExecute    = 116
    scHelp       = 117
    scMenu       = 118
    scSelect     = 119
    scStop       = 120
    scAgain      = 121
    scUndo       = 122
    scCut        = 123
    scCopy       = 124
    scPaste      = 125
    scFind       = 126
    scMute       = 127
    scVolumeUp   = 128
    scVolumeDown = 129

    scKPComma = 133

    scInternational1 = 135
    scInternational2 = 136
    scInternational3 = 137
    scInternational4 = 138
    scInternational5 = 139
    scInternational6 = 140
    scInternational7 = 141
    scInternational8 = 142
    scInternational9 = 143
    scLang1 = 144
    scLang2 = 145
    scLang3 = 146
    scLang4 = 147
    scLang5 = 148
    scLang6 = 149
    scLang7 = 150
    scLang8 = 151
    scLang9 = 152

    scAltErase   = 153
    scSysReq     = 154
    scCancel     = 155
    scClear      = 156
    scPrior      = 157
    scReturn2    = 158
    scSeperator  = 159
    scOut        = 160
    scOper       = 161
    scClearAgain = 162
    scCRSel      = 163
    scEXSel      = 164

    scKP00               = 176
    scKP000              = 177
    scThousandsSeperator = 178
    scDecimalSeperator   = 179
    scCurrencyUnit       = 180
    scCurrencySubunit    = 181
    scKPLeftParen        = 182
    scKPRightParen       = 183
    scKPLeftBrace        = 184
    scKPRightBrace       = 185
    scKPTab              = 186
    scKPBackspace        = 187
    scKPA                = 188
    scKPB                = 189
    scKPC                = 190
    scKPD                = 191
    scKPE                = 192
    scKPF                = 193
    scKPXOR              = 194
    scKPPower            = 195
    scKPPercent          = 196
    scKPLess             = 197
    scKPGreater          = 198
    scKPAmpersand        = 199
    scKPDblAmpersand     = 200
    scKPVerticalBar      = 201
    scKPDblVerticalBar   = 202
    scKPColon            = 203
    scKPHash             = 204
    scKPSpace            = 205
    scKPAt               = 206
    scKPExclam           = 207
    scKPMemStore         = 208
    scKPMemRecall        = 209
    scKPMemClear         = 210
    scKPMemAdd           = 211
    scKPMemSubtract      = 212
    scKPMemMultiply      = 213
    scKPMemDivide        = 214
    scKPPlusMinus        = 215
    scKPClear            = 216
    scKPClearEntry       = 217
    scKPBinary           = 218
    scKPOctal            = 219
    scKPDecimal          = 220
    scKPHexadecimal      = 221

    scLCtrl  = 224
    scLShift = 225
    scLAlt   = 226
    scLGUI   = 227
    scRCtrl  = 228
    scRShift = 229
    scRAlt   = 230
    scRGUI   = 231

    scMode = 257

    scAudioNext   = 258
    scAudioPrev   = 259
    scAudioStop   = 260
    scAudioPlay   = 261
    scAudioMute   = 262
    scMediaSelect = 263
    scWWW         = 264
    scMail        = 265
    scCalculator  = 266
    scComputer    = 267
    scACSearch    = 268
    scACHome      = 269
    scACBack      = 270
    scACForward   = 271
    scACStop      = 272
    scACRefresh   = 273
    scACBookmarks = 274

    scBrightnessDown = 275
    scBrightnessUp   = 276
    scDisplaySwitch  = 277
    scKbdIllumToggle = 278
    scKbdIllumDown   = 279
    scKbdIllumUp     = 280
    scEject          = 281
    scSleep          = 282

    scApp1 = 283
    scApp2 = 284

    scAudioRewind      = 285
    scAudioFastForward = 286

    scSoftLeft  = 287
    scSoftRight = 288
    scCall      = 289
    scEndCall   = 290

type KeyCode* = distinct uint32
func `==`*(a, b: KeyCode): bool {.borrow.}
func scancode_to_keycode*(sc: ScanCode): KeyCode {.compileTime.} =
    KeyCode ((uint32 sc.ord) or (1'u32 shl 30))
const
    kcUnknown*            = KeyCode 0
    kcReturn*             = KeyCode '\r'
    kcEscape*             = KeyCode 0x0000001bu # '\x1B'
    kcBackspace*          = KeyCode '\b'
    kcTab*                = KeyCode '\t'
    kcSpace*              = KeyCode ' '
    kcExclaim*            = KeyCode '!'
    kcQuoteDbl*           = KeyCode '"'
    kcHash*               = KeyCode '#'
    kcPercent*            = KeyCode '%'
    kcDollar*             = KeyCode '$'
    kcAmpersand*          = KeyCode '&'
    kcQuote*              = KeyCode '\''
    kcLeftParen*          = KeyCode '('
    kcRightParen*         = KeyCode ')'
    kcAsterisk*           = KeyCode '*'
    kcPlus*               = KeyCode '+'
    kcComma*              = KeyCode ','
    kcMinus*              = KeyCode '-'
    kcPeriod*             = KeyCode '.'
    kcSlash*              = KeyCode '/'
    kc0*                  = KeyCode '0'
    kc1*                  = KeyCode '1'
    kc2*                  = KeyCode '2'
    kc3*                  = KeyCode '3'
    kc4*                  = KeyCode '4'
    kc5*                  = KeyCode '5'
    kc6*                  = KeyCode '6'
    kc7*                  = KeyCode '7'
    kc8*                  = KeyCode '8'
    kc9*                  = KeyCode '9'
    kcColon*              = KeyCode ':'
    kcSemiColon*          = KeyCode ';'
    kcLess*               = KeyCode '<'
    kcEquals*             = KeyCode '='
    kcGreater*            = KeyCode '>'
    kcQuestion*           = KeyCode '?'
    kcAt*                 = KeyCode '@'
    kcLeftBracket*        = KeyCode '['
    kcBackSlash*          = KeyCode '\\'
    kcRightBracket*       = KeyCode ']'
    kcCaret*              = KeyCode '^'
    kcUnderscore*         = KeyCode '_'
    kcBackQuote*          = KeyCode '`'
    kcA*                  = KeyCode 'a'
    kcB*                  = KeyCode 'b'
    kcC*                  = KeyCode 'c'
    kcD*                  = KeyCode 'd'
    kcE*                  = KeyCode 'e'
    kcF*                  = KeyCode 'f'
    kcG*                  = KeyCode 'g'
    kcH*                  = KeyCode 'h'
    kcI*                  = KeyCode 'i'
    kcJ*                  = KeyCode 'j'
    kcK*                  = KeyCode 'k'
    kcL*                  = KeyCode 'l'
    kcM*                  = KeyCode 'm'
    kcN*                  = KeyCode 'n'
    kcO*                  = KeyCode 'o'
    kcP*                  = KeyCode 'p'
    kcQ*                  = KeyCode 'q'
    kcR*                  = KeyCode 'r'
    kcS*                  = KeyCode 's'
    kcT*                  = KeyCode 't'
    kcU*                  = KeyCode 'u'
    kcV*                  = KeyCode 'v'
    kcW*                  = KeyCode 'w'
    kcX*                  = KeyCode 'x'
    kcY*                  = KeyCode 'y'
    kcZ*                  = KeyCode 'z'
    kcCapsLock*           = scancode_to_keycode(scCapsLock)
    kcF1*                 = scancode_to_keycode(scF1)
    kcF2*                 = scancode_to_keycode(scF2)
    kcF3*                 = scancode_to_keycode(scF3)
    kcF4*                 = scancode_to_keycode(scF4)
    kcF5*                 = scancode_to_keycode(scF5)
    kcF6*                 = scancode_to_keycode(scF6)
    kcF7*                 = scancode_to_keycode(scF7)
    kcF8*                 = scancode_to_keycode(scF8)
    kcF9*                 = scancode_to_keycode(scF9)
    kcF10*                = scancode_to_keycode(scF10)
    kcF11*                = scancode_to_keycode(scF11)
    kcF12*                = scancode_to_keycode(scF12)
    kcPrintScreen*        = scancode_to_keycode(scPrintScreen)
    kcScrollLock*         = scancode_to_keycode(scScrollLock)
    kcPause*              = scancode_to_keycode(scPause)
    kcInsert*             = scancode_to_keycode(scInsert)
    kcHome*               = scancode_to_keycode(scHome)
    kcPageUp*             = scancode_to_keycode(scPageUp)
    kcDelete*             = KeyCode '\x7F'
    kcEnd*                = scancode_to_keycode(scEnd)
    kcPageDown*           = scancode_to_keycode(scPageDown)
    kcRight*              = scancode_to_keycode(scRight)
    kcLeft*               = scancode_to_keycode(scLeft)
    kcDown*               = scancode_to_keycode(scDown)
    kcUp*                 = scancode_to_keycode(scUp)
    kcNumLockClear*       = scancode_to_keycode(scNumLockClear)
    kcKPDivide*           = scancode_to_keycode(scKPDivide)
    kcKPMultiply*         = scancode_to_keycode(scKPMultiply)
    kcKPMinus*            = scancode_to_keycode(scKPMinus)
    kcKPPlus*             = scancode_to_keycode(scKPPlus)
    kcKPEnter*            = scancode_to_keycode(scKPEnter)
    kcKP1*                = scancode_to_keycode(scKP1)
    kcKP2*                = scancode_to_keycode(scKP2)
    kcKP3*                = scancode_to_keycode(scKP3)
    kcKP4*                = scancode_to_keycode(scKP4)
    kcKP5*                = scancode_to_keycode(scKP5)
    kcKP6*                = scancode_to_keycode(scKP6)
    kcKP7*                = scancode_to_keycode(scKP7)
    kcKP8*                = scancode_to_keycode(scKP8)
    kcKP9*                = scancode_to_keycode(scKP9)
    kcKP0*                = scancode_to_keycode(scKP0)
    kcKPPeriod*           = scancode_to_keycode(scKPPeriod)
    kcApplication*        = scancode_to_keycode(scApplication)
    kcPower*              = scancode_to_keycode(scPower)
    kcKPEquals*           = scancode_to_keycode(scKPEquals)
    kcF13*                = scancode_to_keycode(scF13)
    kcF14*                = scancode_to_keycode(scF14)
    kcF15*                = scancode_to_keycode(scF15)
    kcF16*                = scancode_to_keycode(scF16)
    kcF17*                = scancode_to_keycode(scF17)
    kcF18*                = scancode_to_keycode(scF18)
    kcF19*                = scancode_to_keycode(scF19)
    kcF20*                = scancode_to_keycode(scF20)
    kcF21*                = scancode_to_keycode(scF21)
    kcF22*                = scancode_to_keycode(scF22)
    kcF23*                = scancode_to_keycode(scF23)
    kcF24*                = scancode_to_keycode(scF24)
    kcExecute*            = scancode_to_keycode(scExecute)
    kcHelp*               = scancode_to_keycode(scHelp)
    kcMenu*               = scancode_to_keycode(scMenu)
    kcSelect*             = scancode_to_keycode(scSelect)
    kcStop*               = scancode_to_keycode(scStop)
    kcAgain*              = scancode_to_keycode(scAgain)
    kcUndo*               = scancode_to_keycode(scUndo)
    kcCut*                = scancode_to_keycode(scCut)
    kcCopy*               = scancode_to_keycode(scCopy)
    kcPaste*              = scancode_to_keycode(scPaste)
    kcFind*               = scancode_to_keycode(scFind)
    kcMute*               = scancode_to_keycode(scMute)
    kcVolumeUp*           = scancode_to_keycode(scVolumeUp)
    kcVolumeDown*         = scancode_to_keycode(scVolumeDown)
    kcKPComma*            = scancode_to_keycode(scKPComma)
    kcAltErase*           = scancode_to_keycode(scAltErase)
    kcSysReq*             = scancode_to_keycode(scSysReq)
    kcCancel*             = scancode_to_keycode(scCancel)
    kcClear*              = scancode_to_keycode(scClear)
    kcPrior*              = scancode_to_keycode(scPrior)
    kcReturn2*            = scancode_to_keycode(scReturn2)
    kcSeperator*          = scancode_to_keycode(scSeperator)
    kcOut*                = scancode_to_keycode(scOut)
    kcOper*               = scancode_to_keycode(scOper)
    kcClearAgain*         = scancode_to_keycode(scClearAgain)
    kcCRSel*              = scancode_to_keycode(scCRSel)
    kcEXSel*              = scancode_to_keycode(scEXSel)
    kcKP00*               = scancode_to_keycode(scKP00)
    kcKP000*              = scancode_to_keycode(scKP000)
    kcThousandsSeperator* = scancode_to_keycode(scThousandsSeperator)
    kcDecimalSeperator*   = scancode_to_keycode(scDecimalSeperator)
    kcCurrencyUnit*       = scancode_to_keycode(scCurrencyUnit)
    kcCurrencySubUnit*    = scancode_to_keycode(scCurrencySubUnit)
    kcKPLeftParen*        = scancode_to_keycode(scKPLeftParen)
    kcKPRightParen*       = scancode_to_keycode(scKPRightParen)
    kcKPLeftBrace*        = scancode_to_keycode(scKPLeftBrace)
    kcKPRightBrace*       = scancode_to_keycode(scKPRightBrace)
    kcKPTab*              = scancode_to_keycode(scKPTab)
    kcKPBackspace*        = scancode_to_keycode(scKPBackspace)
    kcKPA*                = scancode_to_keycode(scKPA)
    kcKPB*                = scancode_to_keycode(scKPB)
    kcKPC*                = scancode_to_keycode(scKPC)
    kcKPD*                = scancode_to_keycode(scKPD)
    kcKPE*                = scancode_to_keycode(scKPE)
    kcKPF*                = scancode_to_keycode(scKPF)
    kcKPXOR*              = scancode_to_keycode(scKPXOR)
    kcKPPower*            = scancode_to_keycode(scKPPower)
    kcKPPercent*          = scancode_to_keycode(scKPPercent)
    kcKPLess*             = scancode_to_keycode(scKPLess)
    kcKPGreater*          = scancode_to_keycode(scKPGreater)
    kcKPAmpersand*        = scancode_to_keycode(scKPAmpersand)
    kcKPDblAmpersand*     = scancode_to_keycode(scKPDblAmpersand)
    kcKPVerticalBar*      = scancode_to_keycode(scKPVerticalBar)
    kcKPDblVerticalBar*   = scancode_to_keycode(scKPDblVerticalBar)
    kcKPColon*            = scancode_to_keycode(scKPColon)
    kcKPHash*             = scancode_to_keycode(scKPHash)
    kcKPSpace*            = scancode_to_keycode(scKPSpace)
    kcKPAt*               = scancode_to_keycode(scKPAt)
    kcKPExclam*           = scancode_to_keycode(scKP_Exclam)
    kcKPMemStore*         = scancode_to_keycode(scKPMemStore)
    kcKPMemRecall*        = scancode_to_keycode(scKPMemRecall)
    kcKPMemClear*         = scancode_to_keycode(scKPMemClear)
    kcKPMemAdd*           = scancode_to_keycode(scKPMemAdd)
    kcKPMemSubtract*      = scancode_to_keycode(scKPMemSubtract)
    kcKPMemMultiply*      = scancode_to_keycode(scKPMemMultiply)
    kcKPMemDivide*        = scancode_to_keycode(scKPMemDivide)
    kcKPPlusMinus*        = scancode_to_keycode(scKPPlusMinus)
    kcKPClear*            = scancode_to_keycode(scKPClear)
    kcKPClearEntry*       = scancode_to_keycode(scKPClearEntry)
    kcKPBinary*           = scancode_to_keycode(scKPBinary)
    kcKPOctal*            = scancode_to_keycode(scKPOctal)
    kcKPDecimal*          = scancode_to_keycode(scKPDecimal)
    kcKPHexadecimal*      = scancode_to_keycode(scKPHexadecimal)
    kcLCtrl*              = scancode_to_keycode(scLCtrl)
    kcLShift*             = scancode_to_keycode(scLShift)
    kcLAlt*               = scancode_to_keycode(scLAlt)
    kcLGUI*               = scancode_to_keycode(scLGUI)
    kcRCtrl*              = scancode_to_keycode(scRCtrl)
    kcRShift*             = scancode_to_keycode(scRShift)
    kcRAlt*               = scancode_to_keycode(scRAlt)
    kcRGUI*               = scancode_to_keycode(scRGUI)
    kcMode*               = scancode_to_keycode(scMode)
    kcAudioNext*          = scancode_to_keycode(scAudioNext)
    kcAudioPrev*          = scancode_to_keycode(scAudioPrev)
    kcAudioStop*          = scancode_to_keycode(scAudioStop)
    kcAudioPlay*          = scancode_to_keycode(scAudioPlay)
    kcAudioMute*          = scancode_to_keycode(scAudioMute)
    kcMediaSelect*        = scancode_to_keycode(scMediaSelect)
    kcWWW*                = scancode_to_keycode(scWWW)
    kcMail*               = scancode_to_keycode(scMail)
    kcCalculator*         = scancode_to_keycode(scCalculator)
    kcComputer*           = scancode_to_keycode(scComputer)
    kcACSearch*           = scancode_to_keycode(scACSearch)
    kcACHome*             = scancode_to_keycode(scACHome)
    kcACBack*             = scancode_to_keycode(scACBack)
    kcACForward*          = scancode_to_keycode(scACForward)
    kcACStop*             = scancode_to_keycode(scACStop)
    kcACRefresh*          = scancode_to_keycode(scACRefresh)
    kcACBookmarks*        = scancode_to_keycode(scACBookmarks)
    kcBrightnessDown*     = scancode_to_keycode(scBrightnessDown)
    kcBrightnessUp*       = scancode_to_keycode(scBrightnessUp)
    kcDisplaySwitch*      = scancode_to_keycode(scDisplaySwitch)
    kcKbdIllumToggle*     = scancode_to_keycode(scKbdIllumToggle)
    kcKbdIllumDown*       = scancode_to_keycode(scKbdIllumDown)
    kcKbdIllumUp*         = scancode_to_keycode(scKbdIllumUp)
    kcEject*              = scancode_to_keycode(scEject)
    kcSleep*              = scancode_to_keycode(scSleep)
    kcApp1*               = scancode_to_keycode(scApp1)
    kcApp2*               = scancode_to_keycode(scApp2)
    kcAudioRewind*        = scancode_to_keycode(scAudioRewind)
    kcAudioFastForward*   = scancode_to_keycode(scAudioFastForward)
    kcSoftLeft*           = scancode_to_keycode(scSoftLeft)
    kcSoftRight*          = scancode_to_keycode(scSoftRight)
    kcCall*               = scancode_to_keycode(scCall)
    kcEndCall*            = scancode_to_keycode(scEndCall)

type KeyMod* = distinct uint16
KeyMod.gen_bit_ops(
    modLShift, modRShift, _, _,
    _, _, modLCtrl, modRCtrl,
    modLAlt, modRAlt, modLGUI, modRGUI,
    modNum, modCaps, modMode, modScroll,
)
const modShift* = modLShift or modRShift
const modCtrl*  = modLCtrl  or modRCtrl
const modAlt*   = modLAlt   or modRAlt
const modGUI*   = modLGUI   or modRGUI

type
    KeyboardId* = distinct uint32

    Keysym* = object
        scancode*: Scancode
        sym*     : Keycode
        keymod*  : Keymod
        _        : uint16

#[ -------------------------------------------------------------------- ]#

{.push dynlib: SdlLib.}
proc sdl_has_keyboard*(): bool                                                    {.importc: "SDL_HasKeyboard"             .}
proc sdl_get_keyboards*(count: ptr cint): ptr UncheckedArray[KeyboardId]          {.importc: "SDL_GetKeyboards"            .}
proc sdl_get_keyboard_instance_name*(instance_id: KeyboardID): cstring            {.importc: "SDL_GetKeyboardInstanceName" .}
proc sdl_get_keyboard_focus*(): Window                                            {.importc: "SDL_GetKeyboardFocus"        .}
proc sdl_get_keyboard_state*(key_count: ptr cint): ptr UncheckedArray[bool]       {.importc: "SDL_GetKeyboardState"        .}
proc sdl_reset_keyboard*()                                                        {.importc: "SDL_ResetKeyboard"           .}
proc sdl_get_mod_state*(): Keymod                                                 {.importc: "SDL_GetModState"             .}
proc sdl_set_mod_state*(mod_state: Keymod)                                        {.importc: "SDL_SetModState"             .}
proc sdl_get_key_from_scancode*(scancode: Scancode): Keycode                      {.importc: "SDL_GetKeyFromScancode"      .}
proc sdl_get_scancode_from_key*(key: Keycode): Scancode                           {.importc: "SDL_GetScancodeFromKey"      .}
proc sdl_get_scancode_name*(scancode: Scancode): cstring                          {.importc: "SDL_GetScancodeName"         .}
proc sdl_get_scancode_from_name*(name: cstring): Scancode                         {.importc: "SDL_GetScancodeFromName"     .}
proc sdl_get_key_name*(key: Keycode): cstring                                     {.importc: "SDL_GetKeyName"              .}
proc sdl_get_key_from_name*(name: cstring): Keycode                               {.importc: "SDL_GetKeyFromName"          .}
proc sdl_start_text_input*()                                                      {.importc: "SDL_StartTextInput"          .}
proc sdl_text_input_active*(): bool                                               {.importc: "SDL_TextInputActive"         .}
proc sdl_stop_text_input*()                                                       {.importc: "SDL_StopTextInput"           .}
proc sdl_clear_composition*()                                                     {.importc: "SDL_ClearComposition"        .}
proc sdl_set_text_input_area*(win: Window; rect: ptr Rect; cursor: cint): SdlBool {.importc: "SDL_SetTextInputArea"        .}
proc sdl_has_screen_keyboard_support*(): bool                                     {.importc: "SDL_HasScreenKeyboardSupport".}
proc sdl_screen_keyboard_shown*(win: Window): SdlBool                             {.importc: "SDL_ScreenKeyboardShown"     .}
{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}

proc keyboards*(): seq[KeyboardId] =
    var count: cint
    let kbs = sdl_get_keyboards(count.addr)
    for kb in to_open_array(kbs, 0, count - 1):
        result.add kb

proc keyboard_state*(): tuple[count: int32; keys: ptr UncheckedArray[bool]] =
    result.keys = sdl_get_keyboard_state(result.count.addr)

proc name*(id: KeyboardId): string = $sdl_get_keyboard_instance_name(id)
proc key*(code: Scancode): Keycode = sdl_get_key_from_scancode code
proc key*(name: string):   Keycode = sdl_get_key_from_name cstring name
proc scancode*(key: Keycode): Scancode = sdl_get_scancode_from_key key
proc scancode*(name: string): Scancode = sdl_get_scancode_from_name cstring name
proc `$`*(code: Scancode): string = $sdl_get_scancode_name(code)
proc `$`*(key: Keycode):   string = $sdl_get_key_name(key)

proc set_text_input_area*(win: Window; rect: Rect; cursor: int32): bool {.discardable.} =
    sdl_set_text_input_area win, rect.addr, cursor

{.pop.} # inline

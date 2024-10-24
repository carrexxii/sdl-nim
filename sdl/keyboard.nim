import common, bitgen
from video import Window
from rect  import Rect

const
    TextInputKindNumber*             = cstring "SDL.textinput.type"
    TextInputCapitalizationNumber*   = cstring "SDL.textinput.capitalization"
    TextInputAutocorrectBoolean*     = cstring "SDL.textinput.autocorrect"
    TextInputMultilineBoolean*       = cstring "SDL.textinput.multiline"
    TextInputAndroidInputKindNumber* = cstring "SDL.textinput.android.inputtype"

type
    ScanCode* = enum
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
        scKpDivide     = 84
        scKpMultiply   = 85
        scKpMinus      = 86
        scKpPlus       = 87
        scKpEnter      = 88
        scKp1          = 89
        scKp2          = 90
        scKp3          = 91
        scKp4          = 92
        scKp5          = 93
        scKp6          = 94
        scKp7          = 95
        scKp8          = 96
        scKp9          = 97
        scKp0          = 98
        scKpPeriod     = 99

        scNonUsBackSlash = 100
        scApplication    = 101
        scPower          = 102
        scKpEquals       = 103
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

        scKp00               = 176
        scKp000              = 177
        scThousandsSeperator = 178
        scDecimalSeperator   = 179
        scCurrencyUnit       = 180
        scCurrencySubunit    = 181
        scKpLeftParen        = 182
        scKpRightParen       = 183
        scKpLeftBrace        = 184
        scKpRightBrace       = 185
        scKpTab              = 186
        scKpBackspace        = 187
        scKpA                = 188
        scKpB                = 189
        scKpC                = 190
        scKpD                = 191
        scKpE                = 192
        scKpF                = 193
        scKpXor              = 194
        scKpPower            = 195
        scKpPercent          = 196
        scKpLess             = 197
        scKpGreater          = 198
        scKpAmpersand        = 199
        scKpDblAmpersand     = 200
        scKpVerticalBar      = 201
        scKpDblVerticalBar   = 202
        scKpColon            = 203
        scKpHash             = 204
        scKpSpace            = 205
        scKpAt               = 206
        scKpExclam           = 207
        scKpMemStore         = 208
        scKpMemRecall        = 209
        scKpMemClear         = 210
        scKpMemAdd           = 211
        scKpMemSubtract      = 212
        scKpMemMultiply      = 213
        scKpMemDivide        = 214
        scKpPlusMinus        = 215
        scKpClear            = 216
        scKpClearEntry       = 217
        scKpBinary           = 218
        scKpOctal            = 219
        scKpDecimal          = 220
        scKpHexadecimal      = 221

        scLCtrl  = 224
        scLShift = 225
        scLAlt   = 226
        scLGui   = 227
        scRCtrl  = 228
        scRShift = 229
        scRAlt   = 230
        scRGui   = 231

        scMode = 257

        scAudioNext   = 258
        scAudioPrev   = 259
        scAudioStop   = 260
        scAudioPlay   = 261
        scAudioMute   = 262
        scMediaSelect = 263
        scWww         = 264
        scMail        = 265
        scCalculator  = 266
        scComputer    = 267
        scAcSearch    = 268
        scAcHome      = 269
        scAcBack      = 270
        scAcForward   = 271
        scAcStop      = 272
        scAcRefresh   = 273
        scAcBookmarks = 274

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

    TextInputKind* {.size: sizeo(cint).} = enum
        inputText
        inputTextName
        inputTextEmail
        inputTextUsername
        inputTextPasswordHidden
        inputTextPasswordVisible
        inputNumber
        inputNumberPasswordHidden
        inputNumberPasswordVisible

    Capitalization* {.size: sizeof(cint).} = enum
        capitalizeNone
        capitalizeSentences
        capitalizeWords
        capitalizeLetters

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
    kcKpDivide*           = scancode_to_keycode(scKPDivide)
    kcKpMultiply*         = scancode_to_keycode(scKPMultiply)
    kcKpMinus*            = scancode_to_keycode(scKPMinus)
    kcKpPlus*             = scancode_to_keycode(scKPPlus)
    kcKpEnter*            = scancode_to_keycode(scKPEnter)
    kcKp1*                = scancode_to_keycode(scKP1)
    kcKp2*                = scancode_to_keycode(scKP2)
    kcKp3*                = scancode_to_keycode(scKP3)
    kcKp4*                = scancode_to_keycode(scKP4)
    kcKp5*                = scancode_to_keycode(scKP5)
    kcKp6*                = scancode_to_keycode(scKP6)
    kcKp7*                = scancode_to_keycode(scKP7)
    kcKp8*                = scancode_to_keycode(scKP8)
    kcKp9*                = scancode_to_keycode(scKP9)
    kcKp0*                = scancode_to_keycode(scKP0)
    kcKpPeriod*           = scancode_to_keycode(scKPPeriod)
    kcApplication*        = scancode_to_keycode(scApplication)
    kcPower*              = scancode_to_keycode(scPower)
    kcKpEquals*           = scancode_to_keycode(scKPEquals)
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
    kcCrSel*              = scancode_to_keycode(scCRSel)
    kcExSel*              = scancode_to_keycode(scEXSel)
    kcKp00*               = scancode_to_keycode(scKP00)
    kcKp000*              = scancode_to_keycode(scKP000)
    kcThousandsSeperator* = scancode_to_keycode(scThousandsSeperator)
    kcDecimalSeperator*   = scancode_to_keycode(scDecimalSeperator)
    kcCurrencyUnit*       = scancode_to_keycode(scCurrencyUnit)
    kcCurrencySubUnit*    = scancode_to_keycode(scCurrencySubUnit)
    kcKpLeftParen*        = scancode_to_keycode(scKpLeftParen)
    kcKpRightParen*       = scancode_to_keycode(scKpRightParen)
    kcKpLeftBrace*        = scancode_to_keycode(scKpLeftBrace)
    kcKpRightBrace*       = scancode_to_keycode(scKpRightBrace)
    kcKpTab*              = scancode_to_keycode(scKpTab)
    kcKpBackspace*        = scancode_to_keycode(scKpBackspace)
    kcKpA*                = scancode_to_keycode(scKpA)
    kcKpB*                = scancode_to_keycode(scKpB)
    kcKpC*                = scancode_to_keycode(scKpC)
    kcKpD*                = scancode_to_keycode(scKpD)
    kcKpE*                = scancode_to_keycode(scKpE)
    kcKpF*                = scancode_to_keycode(scKpF)
    kcKpXor*              = scancode_to_keycode(scKpXOR)
    kcKpPower*            = scancode_to_keycode(scKpPower)
    kcKpPercent*          = scancode_to_keycode(scKpPercent)
    kcKpLess*             = scancode_to_keycode(scKpLess)
    kcKpGreater*          = scancode_to_keycode(scKpGreater)
    kcKpAmpersand*        = scancode_to_keycode(scKpAmpersand)
    kcKpDblAmpersand*     = scancode_to_keycode(scKpDblAmpersand)
    kcKpVerticalBar*      = scancode_to_keycode(scKpVerticalBar)
    kcKpDblVerticalBar*   = scancode_to_keycode(scKpDblVerticalBar)
    kcKpColon*            = scancode_to_keycode(scKpColon)
    kcKpHash*             = scancode_to_keycode(scKpHash)
    kcKpSpace*            = scancode_to_keycode(scKpSpace)
    kcKpAt*               = scancode_to_keycode(scKpAt)
    kcKpExclam*           = scancode_to_keycode(scKp_Exclam)
    kcKpMemStore*         = scancode_to_keycode(scKpMemStore)
    kcKpMemRecall*        = scancode_to_keycode(scKpMemRecall)
    kcKpMemClear*         = scancode_to_keycode(scKpMemClear)
    kcKpMemAdd*           = scancode_to_keycode(scKpMemAdd)
    kcKpMemSubtract*      = scancode_to_keycode(scKpMemSubtract)
    kcKpMemMultiply*      = scancode_to_keycode(scKpMemMultiply)
    kcKpMemDivide*        = scancode_to_keycode(scKpMemDivide)
    kcKpPlusMinus*        = scancode_to_keycode(scKpPlusMinus)
    kcKpClear*            = scancode_to_keycode(scKpClear)
    kcKpClearEntry*       = scancode_to_keycode(scKpClearEntry)
    kcKpBinary*           = scancode_to_keycode(scKpBinary)
    kcKpOctal*            = scancode_to_keycode(scKpOctal)
    kcKpDecimal*          = scancode_to_keycode(scKpDecimal)
    kcKpHexadecimal*      = scancode_to_keycode(scKpHexadecimal)
    kcLCtrl*              = scancode_to_keycode(scLCtrl)
    kcLShift*             = scancode_to_keycode(scLShift)
    kcLAlt*               = scancode_to_keycode(scLAlt)
    kcLGui*               = scancode_to_keycode(scLGui)
    kcRCtrl*              = scancode_to_keycode(scRCtrl)
    kcRShift*             = scancode_to_keycode(scRShift)
    kcRAlt*               = scancode_to_keycode(scRAlt)
    kcRGui*               = scancode_to_keycode(scRGui)
    kcMode*               = scancode_to_keycode(scMode)
    kcAudioNext*          = scancode_to_keycode(scAudioNext)
    kcAudioPrev*          = scancode_to_keycode(scAudioPrev)
    kcAudioStop*          = scancode_to_keycode(scAudioStop)
    kcAudioPlay*          = scancode_to_keycode(scAudioPlay)
    kcAudioMute*          = scancode_to_keycode(scAudioMute)
    kcMediaSelect*        = scancode_to_keycode(scMediaSelect)
    kcWww*                = scancode_to_keycode(scWww)
    kcMail*               = scancode_to_keycode(scMail)
    kcCalculator*         = scancode_to_keycode(scCalculator)
    kcComputer*           = scancode_to_keycode(scComputer)
    kcAcSearch*           = scancode_to_keycode(scAcSearch)
    kcAcHome*             = scancode_to_keycode(scAcHome)
    kcAcBack*             = scancode_to_keycode(scAcBack)
    kcAcForward*          = scancode_to_keycode(scAcForward)
    kcAcStop*             = scancode_to_keycode(scAcStop)
    kcAcRefresh*          = scancode_to_keycode(scAcRefresh)
    kcAcBookmarks*        = scancode_to_keycode(scAcBookmarks)
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
const modGUI*   = modLGui   or modRGui

type
    KeyboardId* = distinct uint32

    Keysym* = object
        scancode*: ScanCode
        sym*     : KeyCode
        keymod*  : KeyMod
        _        : uint16

#[ -------------------------------------------------------------------- ]#

using
    win: ptr Window

{.push dynlib: SdlLib.}
proc sdl_has_keyboard*(): cbool                                                               {.importc: "SDL_HasKeyboard"                 .}
proc sdl_get_keyboards*(count: ptr cint): ptr UncheckedArray[KeyboardId]                      {.importc: "SDL_GetKeyboards"                .}
proc sdl_get_keyboard_instance_name*(instance_id: KeyboardId): cstring                        {.importc: "SDL_GetKeyboardNameForID"        .}
proc sdl_get_keyboard_focus*(): ptr Window                                                    {.importc: "SDL_GetKeyboardFocus"            .}
proc sdl_get_keyboard_state*(key_count: ptr cint): ptr UncheckedArray[cbool]                  {.importc: "SDL_GetKeyboardState"            .}
proc sdl_reset_keyboard*()                                                                    {.importc: "SDL_ResetKeyboard"               .}
proc sdl_get_mod_state*(): KeyMod                                                             {.importc: "SDL_GetModState"                 .}
proc sdl_set_mod_state*(mod_state: KeyMod)                                                    {.importc: "SDL_SetModState"                 .}
proc sdl_get_key_from_scancode*(code: ScanCode; mod_state: KeyMod; key_event: cbool): KeyCode {.importc: "SDL_GetKeyFromScancode"          .}
proc sdl_get_scancode_from_key*(key: KeyCode; mod_state: ptr KeyMod): ScanCode                {.importc: "SDL_GetScancodeFromKey"          .}
proc sdl_set_scancode_name*(code: ScanCode; name: cstring): cbool                             {.importc: "SDL_SetScancodeName"             .}
proc sdl_get_scancode_name*(code: ScanCode): cstring                                          {.importc: "SDL_GetScancodeName"             .}
proc sdl_get_scancode_from_name*(name: cstring): ScanCode                                     {.importc: "SDL_GetScancodeFromName"         .}
proc sdl_get_key_name*(key: KeyCode): cstring                                                 {.importc: "SDL_GetKeyName"                  .}
proc sdl_get_key_from_name*(name: cstring): KeyCode                                           {.importc: "SDL_GetKeyFromName"              .}
proc sdl_start_text_input*(win): cbool                                                        {.importc: "SDL_StartTextInput"              .}
proc sdl_start_text_input_with_properties*(win; props: PropertyId): cbool                     {.importc: "SDL_StartTextInputWithProperties".}
proc sdl_text_input_active*(win): cbool                                                       {.importc: "SDL_TextInputActive"             .}
proc sdl_stop_text_input*(win): cbool                                                         {.importc: "SDL_StopTextInput"               .}
proc sdl_clear_composition*(win): cbool                                                       {.importc: "SDL_ClearComposition"            .}
proc sdl_set_text_input_area*(win; rect: ptr Rect; cursor: cint): cbool                       {.importc: "SDL_SetTextInputArea"            .}
proc sdl_get_text_input_area*(win; rect: ptr Rect; cursor: ptr cint): cbool                   {.importc: "SDL_GetTextInputArea"            .}
proc sdl_has_screen_keyboard_support*(): cbool                                                {.importc: "SDL_HasScreenKeyboardSupport"    .}
proc sdl_screen_keyboard_shown*(win): cbool                                                   {.importc: "SDL_ScreenKeyboardShown"         .}
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

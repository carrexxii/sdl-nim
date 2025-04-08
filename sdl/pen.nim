import common, bitgen
from mouse import MouseId
from touch import TouchId

type PenInputFlag* = distinct uint32
PenInputFlag.gen_bit_ops(
    PenDown   , PenButton1, PenButton2, PenButton3,
    PenButton4, PenButton5,
)
const PenEraserTip* = PenInputFlag (1 shl 30)

type PenAxis* {.size: sizeof(cint).} = enum
    Pressure
    XTilt
    YTilt
    Distance
    Rotation
    Slider
    TangentialPressure

type PenId* = distinct uint32

const PenMouseId* = cast[MouseId](-2)
const PenTouchId* = cast[TouchId](-2)

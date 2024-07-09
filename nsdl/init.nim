import bitgen

type InitFlag* = distinct uint32
InitFlag.gen_bit_ops(
    ifTimer, _, _, _,
    ifAudio, ifVideo, _, _,
    _, ifJoystick, _, _,
    ifHaptic, ifGamepad, ifEvents, ifSensor,
    ifCamera
)


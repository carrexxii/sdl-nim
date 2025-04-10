import sdl/[init, cpuinfo, hints, iostream, filesystem, power, surface, events, joystick, gamepad, mouse, touch, pen, video, audio, clipboard, tray, sensor, camera, properties, timer, messagebox, dialog]
export      init, cpuinfo, hints, iostream, filesystem, power, surface, events, joystick, gamepad, mouse, touch, pen, video, audio, clipboard, tray, sensor, camera, properties, timer, messagebox, dialog

import sdl/common
export get_error, sdl_free

proc SDL_GetPlatform*(): cstring {.importc, cdecl, dynlib: SdlLib.}
proc get_platform*(): string = $SDL_GetPlatform()

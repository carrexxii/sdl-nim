import common, bitgen
from std/strformat import `&`

const
    AppMetadataName*       = cstring "SDL.app.metadata.name"
    AppMetadataVersion*    = cstring "SDL.app.metadata.version"
    AppMetadataIdentifier* = cstring "SDL.app.metadata.identifier"
    AppMetadataCreator*    = cstring "SDL.app.metadata.creator"
    AppMetadataCopyright*  = cstring "SDL.app.metadata.copyright"
    AppMetadataUrl*        = cstring "SDL.app.metadata.url"
    AppMetadataKind*       = cstring "SDL.app.metadata.type"

type InitFlag* = distinct uint32
InitFlag.gen_bit_ops(
    _, _, _, _,
    initAudio, initVideo, _, _,
    _, initJoystick, _, _,
    initHaptic, initGamepad, initEvents, initSensor,
    initCamera
)

type AppResult* {.size: sizeof(cint).} = enum
    appContinue
    appSuccess
    appFailure

func version*(major, minor, patch: int): Version =
    Version (1000*(1000_000*major + minor) + patch)
func major*(v: Version): int =  (int v) div 1000_000
func minor*(v: Version): int = ((int v) div 1000) mod 1000
func micro*(v: Version): int =  (int v) mod 1000
func `$`*(v: Version): string =
    &"{v.major}.{v.minor}.{v.micro}"

{.push dynlib: SdlLib.}
proc sdl_get_version*(): Version                                             {.importc: "SDL_GetVersion"            .}
proc sdl_init*(flags: InitFlag): cbool                                       {.importc: "SDL_Init"                  .}
proc sdl_init_subsystem*(flags: InitFlag): cbool                             {.importc: "SDL_InitSubSystem"         .}
proc sdl_quit_subsystem*(flags: InitFlag)                                    {.importc: "SDL_QuitSubSystem"         .}
proc sdl_was_init*(flags: InitFlag): InitFlag                                {.importc: "SDL_WasInit"               .}
proc sdl_quit*()                                                             {.importc: "SDL_Quit"                  .}
proc sdl_set_app_metadata*(app_name, app_version, app_ident: cstring): cbool {.importc: "SDL_SetAppMetadata"        .}
proc sdl_set_app_metadata_property*(name, val: cstring): cbool               {.importc: "SDL_SetAppMetadataProperty".}
proc sdl_get_app_metadata_property*(name: cstring): cstring                  {.importc: "SDL_GetAppMetadataProperty".}
{.pop.}

{.push inline.}
proc version*(): Version          = sdl_get_version()
proc init*(flags: InitFlag): bool = sdl_init flags
{.pop.}

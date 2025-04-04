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

{.push cdecl, dynlib: SdlLib.}
proc sdl_get_version*(): Version                                            {.importc: "SDL_GetVersion"            .}
proc sdl_init*(flags: InitFlag): bool                                       {.importc: "SDL_Init"                  .}
proc sdl_init_subsystem*(flags: InitFlag): bool                             {.importc: "SDL_InitSubSystem"         .}
proc sdl_quit_subsystem*(flags: InitFlag)                                   {.importc: "SDL_QuitSubSystem"         .}
proc sdl_was_init*(flags: InitFlag): InitFlag                               {.importc: "SDL_WasInit"               .}
proc sdl_quit*()                                                            {.importc: "SDL_Quit"                  .}
proc sdl_set_app_metadata*(app_name, app_version, app_ident: cstring): bool {.importc: "SDL_SetAppMetadata"        .}
proc sdl_set_app_metadata_property*(name, val: cstring): bool               {.importc: "SDL_SetAppMetadataProperty".}
proc sdl_get_app_metadata_property*(name: cstring): cstring                 {.importc: "SDL_GetAppMetadataProperty".}

proc SDL_SetMemoryFunctions*(
    malloc_fn : proc(sz: csize_t): pointer               {.cdecl.};
    calloc_fn : proc(n, sz: csize_t): pointer            {.cdecl.};
    realloc_fn: proc(mem: pointer; sz: csize_t): pointer {.cdecl.};
    free_fn   : proc(mem: pointer)                       {.cdecl.};
    ): bool {.importc.}
{.pop.}

proc nim_malloc(sz: csize_t): pointer                {.cdecl.} = alloc sz
proc nim_calloc(n, sz: csize_t): pointer             {.cdecl.} = alloc n*sz
proc nim_realloc(mem: pointer; sz: csize_t): pointer {.cdecl.} = realloc mem, sz
proc nim_free(mem: pointer)                          {.cdecl.} = dealloc mem

{.push inline.}

proc version*(): Version =
    sdl_get_version()

proc init*(flags: InitFlag): bool {.discardable.} =
    # TODO: This causes a hang
    # if not SDL_SetMemoryFunctions(nim_malloc, nim_calloc, nim_realloc, nim_free):
    #     echo "Failed to set SDL memory functions: " & $get_error()

    result = sdl_init flags
    sdl_assert result, "Failed to initialize SDL"

{.pop.}

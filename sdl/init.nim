import common, bitgen
from properties import PropertyName

type InitFlag* = distinct uint32
InitFlag.gen_bit_ops(
    _, _, _, _,
    InitAudio, InitVideo, _, _,
    _, InitJoystick, _, _,
    InitHaptic, InitGamepad, InitEvents, InitSensor,
    InitCamera
)

type AppResult* {.size: sizeof(cint).} = enum
    Continue
    Success
    Failure

func version*(major, minor, patch: int): Version =
    Version (1000*(1000_000*major + minor) + patch)
func major*(v: Version): int =  (int v) div 1000_000
func minor*(v: Version): int = ((int v) div 1000) mod 1000
func micro*(v: Version): int =  (int v) mod 1000
func `$`*(v: Version): string =
    &"{v.major}.{v.minor}.{v.micro}"

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_GetVersion*(): Version
proc SDL_Init*(flags: InitFlag): bool
proc SDL_InitSubSystem*(flags: InitFlag): bool
proc SDL_QuitSubSystem*(flags: InitFlag)
proc SDL_WasInit*(flags: InitFlag): InitFlag
proc SDL_Quit*()
proc SDL_SetAppMetadata*(app_name, app_version, app_ident: cstring): bool
proc SDL_SetAppMetadataProperty*(name: PropertyName; val: cstring): bool
proc SDL_GetAppMetadataProperty*(name: PropertyName): cstring
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
    SDL_GetVersion()

proc init*(flags: InitFlag): bool {.discardable.} =
    # TODO: This causes a hang
    # if not SDL_SetMemoryFunctions(nim_malloc, nim_calloc, nim_realloc, nim_free):
    #     echo "Failed to set SDL memory functions: " & $get_error()

    result = SDL_Init(flags)
    sdl_assert result, &"Failed to initialize SDL (flags: {flags})"

proc quit*() =
    SDL_Quit()

proc init_subsystem*(flags: InitFlag): bool {.discardable.} =
    result = SDL_InitSubSystem(flags)
    sdl_assert result, &"Failed to initialize SDL subsystem (flags: {flags})"

proc quit_subsystem*(flags: InitFlag) =
    SDL_QuitSubSystem flags

proc was_init*(): InitFlag {.discardable.} =
    SDL_WasInit InitFlag 0

proc set_metadata*(name, version, ident: string): bool {.discardable.} =
    result = SDL_SetAppMetadata(cstring name, cstring version, cstring ident)
    sdl_assert result, &"Failed to set metadata for app (name: {name}; version: {version}; ident: {ident})"

proc set_metadata*(name: PropertyName; val: string): bool {.discardable.} =
    result = SDL_SetAppMetadataProperty(name, cstring val)
    sdl_assert result, &"Failed to set app metadata ({cstring name}: {val})"

proc metadata*(name: PropertyName): string =
    $SDL_GetAppMetadataProperty(name)

{.pop.}

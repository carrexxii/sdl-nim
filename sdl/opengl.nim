import common
from video import Window

type GLContext* = distinct pointer

{.push dynlib: SDLLib.}
proc sdl_gl_get_proc_address*(name: cstring): pointer {.importc: "SDL_GL_GetProcAddress".}
proc sdl_gl_create_context*(win: Window): pointer     {.importc: "SDL_GL_CreateContext" .}
proc sdl_gl_swap_window*(win: Window): SdlBool        {.importc: "SDL_GL_SwapWindow"    .}
{.pop.}

{.push inline.}

proc gl_proc_address*(name: string): pointer =
    sdl_gl_get_proc_address name

proc create_gl_context*(win: Window): (GLContext, bool) =
    let ctx = sdl_gl_create_context win
    result[0] = GlContext ctx
    result[1] = ctx == nil

proc gl_swap*(win: Window): bool {.discardable.} =
    sdl_gl_swap_window win

{.pop.} # inline

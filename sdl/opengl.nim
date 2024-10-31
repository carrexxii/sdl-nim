import common
from video import Window

type GlContext* = object
    _: pointer

{.push dynlib: SdlLib.}
proc sdl_gl_get_proc_address*(name: cstring): pointer {.importc: "SDL_GL_GetProcAddress".}
proc sdl_gl_create_context*(win: Window): GlContext   {.importc: "SDL_GL_CreateContext" .}
proc sdl_gl_swap_window*(win: Window): cbool          {.importc: "SDL_GL_SwapWindow"    .}
{.pop.}

{.push inline.}

proc gl_proc_address*(name: string): pointer =
    sdl_gl_get_proc_address name

proc create_gl_context*(win: Window): GlContext =
    sdl_gl_create_context win

proc gl_swap*(win: Window): bool {.discardable.} =
    sdl_gl_swap_window win

{.pop.} # inline

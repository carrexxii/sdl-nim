import common
from video import Window

type GLContext* = distinct pointer

{.push dynlib: SDLPath.}
proc gl_get_proc_address*(name: cstring): pointer {.importc: "SDL_GL_GetProcAddress".}
proc gl_create_context*(window: Window): pointer  {.importc: "SDL_GL_CreateContext" .}
proc gl_swap_window*(window: Window): cint        {.importc: "SDL_GL_SwapWindow"    .}
{.pop.}

{.push inline, raises: [].}

proc gl_get_proc_address*(name: string): pointer =
    gl_get_proc_address name

proc create_opengl_context*(window: Window): GLContext {.raises: SDLError.} =
    check_ptr[GLContext] "Failed to create OpenGL context":
        gl_create_context window

proc gl_swap*(window: Window) {.raises: SDLError.} =
    check_err "Failed to swap window for OpenGL":
        gl_swap_window window

{.pop.}

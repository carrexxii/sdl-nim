import common
from video import Window

{.push dynlib: SdlLib.}
proc sdl_vulkan_load_library*(path: cstring): cbool                                             {. importc: "SDL_Vulkan_LoadLibrary"             .}
proc sdl_vulkan_get_vk_get_instance_proc_addr*(): FunctionPointer                               {. importc: "SDL_Vulkan_GetVkGetInstanceProcAddr".}
proc sdl_vulkan_unload_library*()                                                               {. importc: "SDL_Vulkan_UnloadLibrary"           .}
proc sdl_vulkan_get_instance_extensions*(count: ptr uint32): ptr UncheckedArray[cstring]        {. importc: "SDL_Vulkan_GetInstanceExtensions"   .}
proc sdl_vulkan_create_surface*(win: Window; inst, alloc, surface: pointer): cbool              {. importc: "SDL_Vulkan_CreateSurface"           .}
proc sdl_vulkan_destroy_surface*(inst, surface, alloc: pointer)                                 {. importc: "SDL_Vulkan_DestroySurface"          .}
proc sdl_vulkan_get_presentation_support*(inst, phys_dev: pointer; q_family_idx: uint32): cbool {. importc: "SDL_Vulkan_GetPresentationSupport"  .}
{.pop.}

import std/options, common
from video import Window

type
    VkInstance*            = distinct pointer
    VkPhysicalDevice*      = distinct pointer
    VkSurfaceKhr*          = distinct pointer
    VkAllocationCallbacks* = distinct pointer

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_Vulkan_LoadLibrary*(path: cstring): bool
proc SDL_Vulkan_GetVkGetInstanceProcAddr*(): FunctionPointer
proc SDL_Vulkan_UnloadLibrary*()
proc SDL_Vulkan_GetInstanceExtensions*(cnt: ptr uint32): cstringArray
proc SDL_Vulkan_CreateSurface*(win: Window; inst: VkInstance; allocator: VkAllocationCallbacks; surf: VkSurfaceKhr): bool
proc SDL_Vulkan_DestroySurface*(inst: VkInstance; surf: VkSurfaceKhr; allocator: VkAllocationCallbacks)
proc SDL_Vulkan_GetPresentationSupport*(inst: VkInstance; physical_dev: VkPhysicalDevice; queue_family_idx: uint32): bool
{.pop.}

{.push inline.}

proc load_library*(path: string): bool {.discardable.} =
    result = SDL_Vulkan_LoadLibrary(cstring path)
    sdl_assert result, &"Failed to load Vulkan library from '{path}'"

proc unload_library*() =
    SDL_Vulkan_UnloadLibrary()

proc get_instance_proc_addr*(): FunctionPointer =
    SDL_Vulkan_GetVkGetInstanceProcAddr()

proc get_instance_extensions*(): seq[string] =
    var cnt: uint32
    let exts = SDL_Vulkan_GetInstanceExtensions(cnt.addr)
    sdl_assert exts != nil, "Failed to get Vulkan instance extensions"

    if exts != nil:
        result = new_seq_of_cap[string](cnt)
        for i in 0..<cnt:
            result.add $exts[i]

proc create_surface*(win: Window; inst: VkInstance; allocator: Option[VkAllocationCallbacks] = none VkAllocationCallbacks): VkSurfaceKhr =
    let allocator = if allocator.is_some: get allocator else: VkAllocationCallbacks nil
    let success   = SDL_Vulkan_CreateSurface(win, inst, allocator, result)
    sdl_assert success, "Failed to create Vulkan surface for window"

proc destroy*(inst: VkInstance; surf: VkSurfaceKhr; allocator: Option[VkAllocationCallbacks] = none VkAllocationCallbacks) =
    let allocator = if allocator.is_some: get allocator else: VkAllocationCallbacks nil
    SDL_Vulkan_DestroySurface inst, surf, allocator

proc presentation_support*(inst: VkInstance; physical_dev: VkPhysicalDevice; queue_family_idx: SomeInteger): bool =
    SDL_Vulkan_GetPresentationSupport inst, physical_dev, uint32 queue_family_idx

{.pop.}

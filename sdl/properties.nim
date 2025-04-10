import common

type PropertyName* = cstring
const
    AppMetadataName*       = PropertyName "SDL.app.metadata.name"
    AppMetadataVersion*    = PropertyName "SDL.app.metadata.version"
    AppMetadataIdentifier* = PropertyName "SDL.app.metadata.identifier"
    AppMetadataCreator*    = PropertyName "SDL.app.metadata.creator"
    AppMetadataCopyright*  = PropertyName "SDL.app.metadata.copyright"
    AppMetadataUrl*        = PropertyName "SDL.app.metadata.url"
    AppMetadataKind*       = PropertyName "SDL.app.metadata.type"

    WindowShapePointer*                         = PropertyName "SDL.window.shape"
    WindowAndroidWindowPointer*                 = PropertyName "SDL.window.android.window"
    WindowAndroidSurfacePointer*                = PropertyName "SDL.window.android.surface"
    WindowUiKitWindowPointer*                   = PropertyName "SDL.window.uikit.window"
    WindowUiKitMetalViewTagNumber*              = PropertyName "SDL.window.uikit.metal_view_tag"
    WindowKmsDeviceIndexNumber*                 = PropertyName "SDL.window.kmsdrm.dev_index"
    WindowKmsDrmFdNumber*                       = PropertyName "SDL.window.kmsdrm.drm_fd"
    WindowKmsGbmDevicePointer*                  = PropertyName "SDL.window.kmsdrm.gbm_dev"
    WindowCocoaWindowPointer*                   = PropertyName "SDL.window.cocoa.window"
    WindowCocoaMetalViewTagNumber*              = PropertyName "SDL.window.cocoa.metal_view_tag"
    WindowVivanteDisplayPointer*                = PropertyName "SDL.window.vivante.display"
    WindowVivanteWindowPointer*                 = PropertyName "SDL.window.vivante.window"
    WindowVivanteSurfacePointer*                = PropertyName "SDL.window.vivante.surface"
    WindowWinRtWindowPointer*                   = PropertyName "SDL.window.winrt.window"
    WindowWin32HwndPointer*                     = PropertyName "SDL.window.win32.hwnd"
    WindowWin32HdcPointer*                      = PropertyName "SDL.window.win32.hdc"
    WindowWin32InstancePointer*                 = PropertyName "SDL.window.win32.instance"
    WindowWaylandDisplayPointer*                = PropertyName "SDL.window.wayland.display"
    WindowWaylandSurfacePointer*                = PropertyName "SDL.window.wayland.surface"
    WindowWaylandEglWindowPointer*              = PropertyName "SDL.window.wayland.egl_window"
    WindowWaylandXdgSurfacePointer*             = PropertyName "SDL.window.wayland.xdg_surface"
    WindowWaylandXdgToplevelPointer*            = PropertyName "SDL.window.wayland.xdg_toplevel"
    WindowWaylandXdgToplevelExportHandleString* = PropertyName "SDL.window.wayland.xdg_toplevel_export_handle"
    WindowWaylandXdgPopupPointer*               = PropertyName "SDL.window.wayland.xdg_popup"
    WindowWaylandXdgPositionerPointer*          = PropertyName "SDL.window.wayland.xdg_positioner"
    WindowX11DisplayPointer*                    = PropertyName "SDL.window.x11.display"
    WindowX11ScreenNumber*                      = PropertyName "SDL.window.x11.screen"
    WindowX11WindowNumber*                      = PropertyName "SDL.window.x11.window"

    RendererCreateNameString*                           = PropertyName "name"
    RendererCreateWindowPointer*                        = PropertyName "window"
    RendererCreateSurfacePointer*                       = PropertyName "surface"
    RendererCreateOutputColourspaceNumber*              = PropertyName "output_colorspace"
    RendererCreatePresentVSyncBoolean*                  = PropertyName "present_vsync"
    RendererCreateVulkanInstancePointer*                = PropertyName "vulkan.instance"
    RendererCreateVulkanSurfaceNumber*                  = PropertyName "vulkan.surface"
    RendererCreateVulkanPhysicalDevicePointer*          = PropertyName "vulkan.physical_device"
    RendererCreateVulkanDevicePointer*                  = PropertyName "vulkan.device"
    RendererCreateVulkanGraphicsQueueFamilyIndexNumber* = PropertyName "vulkan.graphics_queue_family_index"
    RendererCreateVulkanPresentQueueFamilyIndexNumber*  = PropertyName "vulkan.present_queue_family_index"

    RendererNameString*                           = PropertyName "SDL.renderer.name"
    RendererWindowPointer*                        = PropertyName "SDL.renderer.window"
    RendererSurfacePointer*                       = PropertyName "SDL.renderer.surface"
    RendererOutputColourspaceNumber*              = PropertyName "SDL.renderer.output_colorspace"
    RendererHdrEnabledBoolean*                    = PropertyName "SDL.renderer.HDR_enabled"
    RendererSdrWhitePointFloat*                   = PropertyName "SDL.renderer.SDR_white_point"
    RendererHdrHeadroomFloat*                     = PropertyName "SDL.renderer.HDR_headroom"
    RendererD3D9DevicePointer*                    = PropertyName "SDL.renderer.d3d9.device"
    RendererD3D11DevicePointer*                   = PropertyName "SDL.renderer.d3d11.device"
    RendererD3D12DevicePointer*                   = PropertyName "SDL.renderer.d3d12.device"
    RendererD3D12CommandQueuePointer*             = PropertyName "SDL.renderer.d3d12.command_queue"
    RendererVulkanInstancePointer*                = PropertyName "SDL.renderer.vulkan.instance"
    RendererVulkanSurfaceNumber*                  = PropertyName "SDL.renderer.vulkan.surface"
    RendererVulkanPhysicalDevicePointer*          = PropertyName "SDL.renderer.vulkan.physical_device"
    RendererVulkanDevicePointer*                  = PropertyName "SDL.renderer.vulkan.device"
    RendererVulkanGraphicsQueueFamilyIndexNumber* = PropertyName "SDL.renderer.vulkan.graphics_queue_family_index"
    RendererVulkanPresentQueueFamilyIndexNumber*  = PropertyName "SDL.renderer.vulkan.present_queue_family_index"
    RendererVulkanSwapchainImageCountNumber*      = PropertyName "SDL.renderer.vulkan.swapchain_image_count"

    TextureCreateColourspaceNumber*        = PropertyName "colorspace"
    TextureCreateFormatNumber*             = PropertyName "format"
    TextureCreateAccessNumber*             = PropertyName "access"
    TextureCreateWidthNumber*              = PropertyName "width"
    TextureCreateHeightNumber*             = PropertyName "height"
    TextureCreateSdrWhitePointFloat*       = PropertyName "SDR_white_point"
    TextureCreateHdrHeadroomFloat*         = PropertyName "HDR_headroom"
    TextureCreateD3D11TexturePointer*      = PropertyName "d3d11.texture"
    TextureCreateD3D11TextureUPointer*     = PropertyName "d3d11.texture_u"
    TextureCreateD3D11TextureVPointer*     = PropertyName "d3d11.texture_v"
    TextureCreateD3D12TexturePointer*      = PropertyName "d3d12.texture"
    TextureCreateD3D12TextureUPointer*     = PropertyName "d3d12.texture_u"
    TextureCreateD3D12TextureVPointer*     = PropertyName "d3d12.texture_v"
    TextureCreateMetalPixelbufferPointer*  = PropertyName "metal.pixelbuffer"
    TextureCreateOpenGlTextureNumber*      = PropertyName "opengl.texture"
    TextureCreateOpenGlTextureUVNumber*    = PropertyName "opengl.texture_uv"
    TextureCreateOpenGlTextureUNumber*     = PropertyName "opengl.texture_u"
    TextureCreateOpenGlTextureVNumber*     = PropertyName "opengl.texture_v"
    TextureCreateOpenGles2TextureNumber*   = PropertyName "opengles2.texture"
    TextureCreateOpenGles2TextureUvNumber* = PropertyName "opengles2.texture_uv"
    TextureCreateOpenGles2TextureUNumber*  = PropertyName "opengles2.texture_u"
    TextureCreateOpenGles2TextureVNumber*  = PropertyName "opengles2.texture_v"
    TextureCreateVulkanTextureNumber*      = PropertyName "vulkan.texture"

    TextureColourspaceNumber*            = PropertyName "SDL.texture.colorspace"
    TextureSdrWhitePointFloat*           = PropertyName "SDL.texture.SDR_white_point"
    TextureHdrHeadroomFloat*             = PropertyName "SDL.texture.HDR_headroom"
    TextureD3D11TexturePointer*          = PropertyName "SDL.texture.d3d11.texture"
    TextureD3D11TextureUPointer*         = PropertyName "SDL.texture.d3d11.texture_u"
    TextureD3D11TextureVPointer*         = PropertyName "SDL.texture.d3d11.texture_v"
    TextureD3D12TexturePointer*          = PropertyName "SDL.texture.d3d12.texture"
    TextureD3D12TextureUPointer*         = PropertyName "SDL.texture.d3d12.texture_u"
    TextureD3D12TextureVPointer*         = PropertyName "SDL.texture.d3d12.texture_v"
    TextureOpenGLTextureNumber*          = PropertyName "SDL.texture.opengl.texture"
    TextureOpenGLTextureUVNumber*        = PropertyName "SDL.texture.opengl.texture_uv"
    TextureOpenGLTextureUNumber*         = PropertyName "SDL.texture.opengl.texture_u"
    TextureOpenGLTextureVNumber*         = PropertyName "SDL.texture.opengl.texture_v"
    TextureOpenGLTextureTargetNumber*    = PropertyName "SDL.texture.opengl.target"
    TextureOpenGLTexWFloat*              = PropertyName "SDL.texture.opengl.tex_w"
    TextureOpenGLTexHFloat*              = PropertyName "SDL.texture.opengl.tex_h"
    TextureOpenGles2TextureNumber*       = PropertyName "SDL.texture.opengles2.texture"
    TextureOpenGles2TextureUvNumber*     = PropertyName "SDL.texture.opengles2.texture_uv"
    TextureOpenGles2TextureUNumber*      = PropertyName "SDL.texture.opengles2.texture_u"
    TextureOpenGles2TextureVNumber*      = PropertyName "SDL.texture.opengles2.texture_v"
    TextureOpenGles2TextureTargetNumber* = PropertyName "SDL.texture.opengles2.target"
    TextureVulkanTextureNumber*          = PropertyName "SDL.texture.vulkan.texture"

    SurfaceSdrWhitePointFloat*     = PropertyName "SDL.surface.SDR_white_point"
    SurfaceHdrHeadroomFloat*       = PropertyName "SDL.surface.HDR_headroom"
    SurfaceTonemapGeneratorString* = PropertyName "SDL.surface.tonemap"
    SurfaceHotspotXNumber*         = PropertyName "SDL.surface.hotspot.x"
    SurfaceHotspotyNumber*         = PropertyName "SDL.surface.hotspot.y"

    GpuDeviceCreateDebugModeBool*           = PropertyName "SDL.gpu.device.create.debugmode"
    GpuDeviceCreatePreferLowPowerBool*      = PropertyName "SDL.gpu.device.create.preferlowpower"
    GpuDeviceCreateNameString*              = PropertyName "SDL.gpu.device.create.name"
    GpuDeviceCreateShadersPrivateBool*      = PropertyName "SDL.gpu.device.create.shaders.private"
    GpuDeviceCreateShadersSpirVBool*        = PropertyName "SDL.gpu.device.create.shaders.spirv"
    GpuDeviceCreateShadersDxBcBool*         = PropertyName "SDL.gpu.device.create.shaders.dxbc"
    GpuDeviceCreateShadersDxIlBool*         = PropertyName "SDL.gpu.device.create.shaders.dxil"
    GpuDeviceCreateShadersMslBool*          = PropertyName "SDL.gpu.device.create.shaders.msl"
    GpuDeviceCreateShadersMetalLib*         = PropertyName "SDL.gpu.device.create.shaders.metallib"
    GpuDeviceCreateD3D12SemanticNameString* = PropertyName "SDL.gpu.device.create.d3d12.semantic"

    GpuTextureCreateD3D12ClearRFloat*       = PropertyName "SDL.gpu.texture.create.d3d12.clear.r"
    GpuTextureCreateD3D12ClearGFloat*       = PropertyName "SDL.gpu.texture.create.d3d12.clear.g"
    GpuTextureCreateD3D12ClearBFloat*       = PropertyName "SDL.gpu.texture.create.d3d12.clear.b"
    GpuTextureCreateD3D12ClearAFloat*       = PropertyName "SDL.gpu.texture.create.d3d12.clear.a"
    GpuTextureCreateD3D12ClearDepthFloat*   = PropertyName "SDL.gpu.texture.create.d3d12.clear.depth"
    GpuTextureCreateD3D12ClearStencilUint8* = PropertyName "SDL.gpu.texture.create.d3d12.clear.stencil"

    GpuTextureCreateNameString*          = PropertyName "SDL.gpu.texture.create.name"
    GpuComputePipelineCreateNameString*  = PropertyName "SDL.gpu.computepipeline.create.name"
    GpuGraphicsPipelineCreateNameString* = PropertyName "SDL.gpu.graphicspipeline.create.name"
    GpuSamplerCreateNameString*          = PropertyName "SDL.gpu.sampler.create.name"
    GpuBufferCreateNameString*           = PropertyName "SDL.gpu.buffer.create.name"
    GpuTransferBufferCreateNameString*   = PropertyName "SDL.gpu.transferbuffer.create.name"

    IoStreamWindowsHandlePointer*   = PropertyName "SDL.iostream.windows.handle"
    IoStreamStdioFilePointer*       = PropertyName "SDL.iostream.stdio.file"
    IoStreamFileDescriptorName*     = PropertyName "SDL.iostream.file_descriptor"
    IoStreamAndroidAassetPointer*   = PropertyName "SDL.iostream.android.aasset"
    IoStreamMemoryPointer*          = PropertyName "SDL.iostream.memory.base"
    IoStreamMemorySizeNumber*       = PropertyName "SDL.iostream.memory.size"
    IoStreamDynamicMemoryPointer*   = PropertyName "SDL.iostream.dynamic.memory"
    IoStreamDynamicChunkSizeNumber* = PropertyName "SDL.iostream.dynamic.chunksize"

    JoystickCapMonoLedBoolean*       = PropertyName "SDL.joystick.cap.mono_led"
    JoystickCapRgbLedBoolean*        = PropertyName "SDL.joystick.cap.rgb_led"
    JoystickCapPlayerLedBoolean*     = PropertyName "SDL.joystick.cap.player_led"
    JoystickCapRumbleBoolean*        = PropertyName "SDL.joystick.cap.rumble"
    JoystickCapTriggerRumbleBoolean* = PropertyName "SDL.joystick.cap.trigger_rumble"

    GamepadCapMonoLedBoolean*       = JoystickCapMonoLedBoolean
    GamepadCapRgbLedBoolean*        = JoystickCapRgbLedBoolean
    GamepadCapPlayerLedBoolean*     = JoystickCapPlayerLedBoolean
    GamepadCapRumbleBoolean*        = JoystickCapRumbleBoolean
    GamepadCapTriggerRumbleBoolean* = JoystickCapTriggerRumbleBoolean

type PropertyKind* {.size: sizeof(cint).} = enum
    Invalid
    Pointer
    String
    Number
    Float
    Boolean

type
    PropertiesId* = distinct uint32

    CleanupPropertyCallback*     = proc(user_data, val: pointer) {.cdecl.}
    EnumeratePropertiesCallback* = proc(user_data: pointer; props: PropertiesId; name: PropertyName) {.cdecl.}

proc SDL_DestroyProperties*(props: PropertiesId) {.importc, cdecl, dynlib: SdlLib.}
proc `=destroy`*(props: PropertiesId) = SDL_DestroyProperties props

func `$`*(id: PropertiesId): string  {.borrow.}
func `==`*(a, b: PropertiesId): bool {.borrow.}

const InvalidProperty* = PropertiesId 0

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_GetGlobalProperties*(): PropertiesId
proc SDL_CreateProperties*(): PropertiesId
proc SDL_CopyProperties*(src, dst: PropertiesId): bool
proc SDL_LockProperties*(props: PropertiesId): bool
proc SDL_UnlockProperties*(props: PropertiesId)
proc SDL_SetPointerPropertyWithCleanup*(props: PropertiesId; name: PropertyName; val: pointer; cb: CleanupPropertyCallback; user_data: pointer): bool
proc SDL_SetPointerProperty*(props: PropertiesId; name: PropertyName; val: pointer): bool
proc SDL_SetStringProperty*(props: PropertiesId; name, val: cstring): bool
proc SDL_SetNumberProperty*(props: PropertiesId; name: PropertyName; val: int64): bool
proc SDL_SetFloatProperty*(props: PropertiesId; name: PropertyName; val: cfloat): bool
proc SDL_SetBooleanProperty*(props: PropertiesId; name: PropertyName; val: bool): bool
proc SDL_HasProperty*(props: PropertiesId; name: PropertyName): bool
proc SDL_GetPropertyType*(props: PropertiesId; name: PropertyName): PropertyKind
proc SDL_GetPointerProperty*(props: PropertiesId; name: PropertyName; default_val: pointer): pointer
proc SDL_GetStringProperty*(props: PropertiesId; name: PropertyName; default_val: cstring): cstring
proc SDL_GetNumberProperty*(props: PropertiesId; name: PropertyName; default_val: int64): int64
proc SDL_GetFloatProperty*(props: PropertiesId; name: PropertyName; default_val: cfloat): cfloat
proc SDL_GetBooleanProperty*(props: PropertiesId; name: PropertyName; default_val: bool): bool
proc SDL_ClearProperty*(props: PropertiesId; name: PropertyName): bool
proc SDL_EnumerateProperties*(props: PropertiesId; cb: EnumeratePropertiesCallback; user_data: pointer): bool
{.pop.}

# FIXME: The get/set string properties probably can't be implemented like this

{.push inline.}

proc get_global_properties*(): PropertiesId = SDL_GetGlobalProperties()
proc create_properties*(): PropertiesId =
    result = SDL_CreateProperties()
    sdl_assert result != InvalidProperty, &"Failed to create properties"

proc copy*(src, dst: PropertiesId): bool {.discardable.} =
    result = SDL_CopyProperties(src, dst)
    sdl_assert result, &"Failed to copy properties from '{dst}' to '{src}'"

proc lock*(props: PropertiesId): bool {.discardable.} =
    result = SDL_LockProperties(props)
    sdl_assert result, &"Failed to lock properties '{props}'"

proc unlock*(props: PropertiesId) =
    SDL_UnlockProperties props

proc set_property*(props: PropertiesId; name: PropertyName; val: pointer): bool {.discardable.} =
    result = SDL_SetPointerProperty(props, name, val)
    sdl_assert result, &"Failed to set pointer property for '{props}' (\"{name}\": 0x{cast[int](val):X})"
proc set_property*(props: PropertiesId; name: PropertyName; val: string): bool {.discardable.} =
    result = SDL_SetStringProperty(props, name, cstring val)
    sdl_assert result, &"Failed to set string property for '{props}' (\"{name}\": \"{val}\")"
proc set_property*(props: PropertiesId; name: PropertyName; val: int64): bool {.discardable.} =
    result = SDL_SetNumberProperty(props, name, val)
    sdl_assert result, &"Failed to set number property for '{props}' (\"{name}\": {val})"
proc set_property*(props: PropertiesId; name: PropertyName; val: float32): bool {.discardable.} =
    result = SDL_SetFloatProperty(props, name, cfloat val)
    sdl_assert result, &"Failed to set float property for '{props}' (\"{name}\": {val})"
proc set_property*(props: PropertiesId; name: PropertyName; val: bool): bool {.discardable.} =
    result = SDL_SetBooleanProperty(props, name, val)
    sdl_assert result, &"Failed to set boolean property for '{props}' (\"{name}\": {val})"
proc `property=`*(props: PropertiesId; pair: tuple[name: PropertyName; val: pointer | string | int64 | float32 | bool]) =
    set_property props, pair.name, pair.val

proc has*(props: PropertiesId; name: PropertyName): bool          = SDL_HasProperty props, name
proc kind*(props: PropertiesId; name: PropertyName): PropertyKind = SDL_GetPropertyType props, name
proc get*(props: PropertiesId; name: PropertyName; default_val: pointer): pointer = SDL_GetPointerProperty props, name, default_val
proc get*(props: PropertiesId; name: PropertyName; default_val: string): string   = $SDL_GetStringProperty(props, name, default_val)
proc get*(props: PropertiesId; name: PropertyName; default_val: int64): int64     = SDL_GetNumberProperty props, name, default_val
proc get*(props: PropertiesId; name: PropertyName; default_val: float32): float32 = SDL_GetFloatProperty props, name, default_val
proc get*(props: PropertiesId; name: PropertyName; default_val: bool): bool       = SDL_GetBooleanProperty props, name, default_val

proc clear*(props: PropertiesId; name: PropertyName): bool {.discardable.} =
    result = SDL_ClearProperty(props, name)
    sdl_assert result, &"Failed to clear \"{name}\" properties for '{props}'"

proc enumerate*(props: PropertiesId; cb: EnumeratePropertiesCallback; user_data: pointer = nil): bool {.discardable.} =
    result = SDL_EnumerateProperties(props, cb, user_data)
    sdl_assert result, &"Failed to enumerate properties for '{props}' (user data: 0x{cast[int](user_data):X})"

{.pop.}

# proc properties*(win: pointer): PropertiesId =
#     PropertiesId SDL_GetWindowProperties win

# proc get_number_property*(id: PropertiesId; name: PropertyName; default: int64 = -1): int64 =
#     SDL_GetNumberProperty id, name, default

# proc x11_screen_number*(win: pointer): int64 = get_number_property properties(win), WindowX11ScreenNumber
# proc x11_window_number*(win: pointer): int64 = get_number_property properties(win), WindowX11WindowNumber

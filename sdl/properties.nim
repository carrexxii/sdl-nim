import common

type PropertyName* = distinct cstring
const
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

type
    Property*   = distinct pointer
    PropertyId* = distinct uint32
func `$`*(id: PropertyId): string  {.borrow.}
func `==`*(a, b: PropertyId): bool {.borrow.}

const InvalidProperty* = PropertyId 0

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_GetProperty*(id: PropertyId; name: PropertyName; default: pointer): pointer
proc SDL_GetNumberProperty*(id: PropertyId; name: PropertyName; default: int64): int64
proc SDL_GetWindowProperties*(win: pointer): uint32
{.pop.}

{.push inline.}

proc properties*(win: pointer): PropertyId =
    PropertyId SDL_GetWindowProperties win

proc get_number_property*(id: PropertyId; name: PropertyName; default: int64 = -1): int64 =
    SDL_GetNumberProperty id, name, default

proc x11_screen_number*(win: pointer): int64      = get_number_property properties(win), WindowX11ScreenNumber
proc x11_window_number*(win: pointer): int64      = get_number_property properties(win), WindowX11WindowNumber
proc x11_display_pointer*(win: pointer): Property = Property SDL_GetProperty(properties(win), WindowX11DisplayPointer, nil)

{.pop.}

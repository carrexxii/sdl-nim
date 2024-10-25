import common

type PropertyName* = distinct cstring
const
    ShapePointer*                         = PropertyName "SDL.window.shape"
    AndroidWindowPointer*                 = PropertyName "SDL.window.android.window"
    AndroidSurfacePointer*                = PropertyName "SDL.window.android.surface"
    UiKitWindowPointer*                   = PropertyName "SDL.window.uikit.window"
    UiKitMetalViewTagNumber*              = PropertyName "SDL.window.uikit.metal_view_tag"
    KmsDeviceIndexNumber*                 = PropertyName "SDL.window.kmsdrm.dev_index"
    KmsDrmFdNumber*                       = PropertyName "SDL.window.kmsdrm.drm_fd"
    KmsGbmDevicePointer*                  = PropertyName "SDL.window.kmsdrm.gbm_dev"
    CocoaWindowPointer*                   = PropertyName "SDL.window.cocoa.window"
    CocoaMetalViewTagNumber*              = PropertyName "SDL.window.cocoa.metal_view_tag"
    VivanteDisplayPointer*                = PropertyName "SDL.window.vivante.display"
    VivanteWindowPointer*                 = PropertyName "SDL.window.vivante.window"
    VivanteSurfacePointer*                = PropertyName "SDL.window.vivante.surface"
    WinRtWindowPointer*                   = PropertyName "SDL.window.winrt.window"
    Win32HwndPointer*                     = PropertyName "SDL.window.win32.hwnd"
    Win32HdcPointer*                      = PropertyName "SDL.window.win32.hdc"
    Win32InstancePointer*                 = PropertyName "SDL.window.win32.instance"
    WaylandDisplayPointer*                = PropertyName "SDL.window.wayland.display"
    WaylandSurfacePointer*                = PropertyName "SDL.window.wayland.surface"
    WaylandEglWindowPointer*              = PropertyName "SDL.window.wayland.egl_window"
    WaylandXdgSurfacePointer*             = PropertyName "SDL.window.wayland.xdg_surface"
    WaylandXdgToplevelPointer*            = PropertyName "SDL.window.wayland.xdg_toplevel"
    WaylandXdgToplevelExportHandleString* = PropertyName "SDL.window.wayland.xdg_toplevel_export_handle"
    WaylandXdgPopupPointer*               = PropertyName "SDL.window.wayland.xdg_popup"
    WaylandXdgPositionerPointer*          = PropertyName "SDL.window.wayland.xdg_positioner"
    X11DisplayPointer*                    = PropertyName "SDL.window.x11.display"
    X11ScreenNumber*                      = PropertyName "SDL.window.x11.screen"
    X11WindowNumber*                      = PropertyName "SDL.window.x11.window"

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

    SurfaceColourspaceNumber*      = PropertyName "SDL.surface.colorspace"
    SurfaceSdrWhitePointFloat*     = PropertyName "SDL.surface.SDR_white_point"
    SurfaceHdrHeadroomFloat*       = PropertyName "SDL.surface.HDR_headroom"
    SurfaceTonemapGeneratorString* = PropertyName "SDL.surface.tonemap"

type
    Property*   = distinct pointer
    PropertyId* = distinct uint32
func `$`*(x: PropertyId): string {.borrow.}

const InvalidProperty* = PropertyId 0

#[ -------------------------------------------------------------------- ]#

from video import Window

using
    id  : PropertyId
    name: PropertyName
    win : ptr Window

{.push dynlib: SdlLib.}
proc sdl_get_property*       (id; name; default: pointer): pointer {.importc: "SDL_GetProperty"        .}
proc sdl_get_number_property*(id; name; default: int64  ): int64   {.importc: "SDL_GetNumberProperty"  .}
proc sdl_get_window_properties*(win): uint32                       {.importc: "SDL_GetWindowProperties".}
{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}
proc properties*(win): PropertyId = PropertyId sdl_get_window_properties(win)

proc x11_screen_number*(win): int64 = sdl_get_number_property properties(win), X11ScreenNumber, -1
proc x11_window_number*(win): int64 = sdl_get_number_property properties(win), X11WindowNumber, -1
proc x11_display_pointer*(win): Property = Property sdl_get_property(properties(win), X11DisplayPointer, nil)
{.pop.}

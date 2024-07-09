{.push raises: [].}

import common

type PropertyName* = distinct cstring
const
    ShapePointer*                         = PropertyName "SDL.window.shape"
    AndroidWindowPointer*                 = PropertyName "SDL.window.android.window"
    AndroidSurfacePointer*                = PropertyName "SDL.window.android.surface"
    UIKitWindowPointer*                   = PropertyName "SDL.window.uikit.window"
    UIKitMetalViewTagNumber*              = PropertyName "SDL.window.uikit.metal_view_tag"
    KMSDeviceIndexNumber*                 = PropertyName "SDL.window.kmsdrm.dev_index"
    KMSDRMFDNumber*                       = PropertyName "SDL.window.kmsdrm.drm_fd"
    KMSGBMDevicePointer*                  = PropertyName "SDL.window.kmsdrm.gbm_dev"
    CocoaWindowPointer*                   = PropertyName "SDL.window.cocoa.window"
    CocoaMetalViewTagNumber*              = PropertyName "SDL.window.cocoa.metal_view_tag"
    VivanteDisplayPointer*                = PropertyName "SDL.window.vivante.display"
    VivanteWindowPointer*                 = PropertyName "SDL.window.vivante.window"
    VivanteSurfacePointer*                = PropertyName "SDL.window.vivante.surface"
    WinRTWindowPointer*                   = PropertyName "SDL.window.winrt.window"
    Win32HWNDPointer*                     = PropertyName "SDL.window.win32.hwnd"
    Win32HDCPointer*                      = PropertyName "SDL.window.win32.hdc"
    Win32InstancePointer*                 = PropertyName "SDL.window.win32.instance"
    WaylandDisplayPointer*                = PropertyName "SDL.window.wayland.display"
    WaylandSurfacePointer*                = PropertyName "SDL.window.wayland.surface"
    WaylandEGLWindowPointer*              = PropertyName "SDL.window.wayland.egl_window"
    WaylandXDGSurfacePointer*             = PropertyName "SDL.window.wayland.xdg_surface"
    WaylandXDGToplevelPointer*            = PropertyName "SDL.window.wayland.xdg_toplevel"
    WaylandXDGToplevelExportHandleString* = PropertyName "SDL.window.wayland.xdg_toplevel_export_handle"
    WaylandXDGPopupPointer*               = PropertyName "SDL.window.wayland.xdg_popup"
    WaylandXDGPositionerPointer*          = PropertyName "SDL.window.wayland.xdg_positioner"
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
    RendererHDREnabledBoolean*                    = PropertyName "SDL.renderer.HDR_enabled"
    RendererSDRWhitePointFloat*                   = PropertyName "SDL.renderer.SDR_white_point"
    RendererHDRHeadroomFloat*                     = PropertyName "SDL.renderer.HDR_headroom"
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
    TextureCreateSDRWhitePointFloat*       = PropertyName "SDR_white_point"
    TextureCreateHDRHeadroomFloat*         = PropertyName "HDR_headroom"
    TextureCreateD3D11TexturePointer*      = PropertyName "d3d11.texture"
    TextureCreateD3D11TextureUPointer*     = PropertyName "d3d11.texture_u"
    TextureCreateD3D11TextureVPointer*     = PropertyName "d3d11.texture_v"
    TextureCreateD3D12TexturePointer*      = PropertyName "d3d12.texture"
    TextureCreateD3D12TextureUPointer*     = PropertyName "d3d12.texture_u"
    TextureCreateD3D12TextureVPointer*     = PropertyName "d3d12.texture_v"
    TextureCreateMetalPixelbufferPointer*  = PropertyName "metal.pixelbuffer"
    TextureCreateOpenGLTextureNumber*      = PropertyName "opengl.texture"
    TextureCreateOpenGLTextureUVNumber*    = PropertyName "opengl.texture_uv"
    TextureCreateOpenGLTextureUNumber*     = PropertyName "opengl.texture_u"
    TextureCreateOpenGLTextureVNumber*     = PropertyName "opengl.texture_v"
    TextureCreateOpenGLES2TextureNumber*   = PropertyName "opengles2.texture"
    TextureCreateOpenGLES2TextureUVNumber* = PropertyName "opengles2.texture_uv"
    TextureCreateOpenGLES2TextureUNumber*  = PropertyName "opengles2.texture_u"
    TextureCreateOpenGLES2TextureVNumber*  = PropertyName "opengles2.texture_v"
    TextureCreateVulkanTextureNumber*      = PropertyName "vulkan.texture"

    TextureColourspaceNumber*            = PropertyName "SDL.texture.colorspace"
    TextureSDRWhitePointFloat*           = PropertyName "SDL.texture.SDR_white_point"
    TextureHDRHeadroomFloat*             = PropertyName "SDL.texture.HDR_headroom"
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
    TextureOpenGLES2TextureNumber*       = PropertyName "SDL.texture.opengles2.texture"
    TextureOpenGLES2TextureUVNumber*     = PropertyName "SDL.texture.opengles2.texture_uv"
    TextureOpenGLES2TextureUNumber*      = PropertyName "SDL.texture.opengles2.texture_u"
    TextureOpenGLES2TextureVNumber*      = PropertyName "SDL.texture.opengles2.texture_v"
    TextureOpenGLES2TextureTargetNumber* = PropertyName "SDL.texture.opengles2.target"
    TextureVulkanTextureNumber*          = PropertyName "SDL.texture.vulkan.texture"

type
    Property*   = distinct pointer
    PropertyID* = distinct uint32
func `$`*(x: PropertyID): string {.borrow.}

#[ -------------------------------------------------------------------- ]#

from video    import Window
from renderer import Texture

{.push dynlib: SDLLib.}
proc get_property*       (id: PropertyID; name: PropertyName; default: pointer): pointer {.importc: "SDL_GetProperty"         .}
proc get_number_property*(id: PropertyID; name: PropertyName; default: int64  ): int64   {.importc: "SDL_GetNumberProperty"   .}
proc get_window_properties*(window: Window): uint32                                      {.importc: "SDL_GetWindowProperties" .}
proc get_texture_properties*(texture: Texture): uint32                                   {.importc: "SDL_GetTextureProperties".}
{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}

proc get_properties*(window: Window): PropertyID {.raises: SDLError.} =
    let prop = get_window_properties window
    if prop == 0:
        raise new_exception(SDLError, "Error: " & "Failed to get window properties" & " (" & $get_error() & ")")

    result = PropertyID prop

proc get_properties*(texture: Texture): PropertyID {.raises: SDLError.} =
    let prop = get_texture_properties texture
    if prop == 0:
        raise new_exception(SDLError, "Error: " & "Failed to get texture properties" & " (" & $get_error() & ")")

    result = PropertyID prop

proc get_x11_display_pointer*(window: Window): Property {.raises: SDLError.} =
    check_ptr[Property] "Failed to get X11 display pointer":
        get_property(get_properties window, X11DisplayPointer, nil)
proc get_x11_screen_number*(window: Window): int64 {.raises: SDLError.} =
    check_err -1, "Failed to get X11 screen number":
        get_number_property(get_properties window, X11ScreenNumber, -1)
proc get_x11_window_number*(window: Window): int64 {.raises: SDLError.} =
    check_err -1, "Failed to get X11 window number":
        get_number_property(get_properties window, X11WindowNumber, -1)

proc get_texture_number*(texture: Texture): int64 {.raises: SDLError.} =
    check_err -1, "Failed to get texture number":
        get_number_property(get_properties texture, TextureOpenGLTextureNumber, -1)

{.pop.}


import video

type PropertyName = enum
    ShapePointer                         = cstring "SDL.window.shape"
    AndroidWindowPointer                 = cstring "SDL.window.android.window"
    AndroidSurfacePointer                = cstring "SDL.window.android.surface"
    UIKitWindowPointer                   = cstring "SDL.window.uikit.window"
    UIKitMetalViewTagNumber              = cstring "SDL.window.uikit.metal_view_tag"
    KMSDeviceIndexNumber                 = cstring "SDL.window.kmsdrm.dev_index"
    KMSDRMFDNumber                       = cstring "SDL.window.kmsdrm.drm_fd"
    KMSGBMDevicePointer                  = cstring "SDL.window.kmsdrm.gbm_dev"
    CocoaWindowPointer                   = cstring "SDL.window.cocoa.window"
    CocoaMetalViewTagNumber              = cstring "SDL.window.cocoa.metal_view_tag"
    VivanteDisplayPointer                = cstring "SDL.window.vivante.display"
    VivanteWindowPointer                 = cstring "SDL.window.vivante.window"
    VivanteSurfacePointer                = cstring "SDL.window.vivante.surface"
    WinRTWindowPointer                   = cstring "SDL.window.winrt.window"
    Win32HWNDPointer                     = cstring "SDL.window.win32.hwnd"
    Win32HDCPointer                      = cstring "SDL.window.win32.hdc"
    Win32InstancePointer                 = cstring "SDL.window.win32.instance"
    WaylandDisplayPointer                = cstring "SDL.window.wayland.display"
    WaylandSurfacePointer                = cstring "SDL.window.wayland.surface"
    WaylandEGLWindowPointer              = cstring "SDL.window.wayland.egl_window"
    WaylandXDGSurfacePointer             = cstring "SDL.window.wayland.xdg_surface"
    WaylandXDGToplevelPointer            = cstring "SDL.window.wayland.xdg_toplevel"
    WaylandXDGToplevelExportHandleString = cstring "SDL.window.wayland.xdg_toplevel_export_handle"
    WaylandXDGPopupPointer               = cstring "SDL.window.wayland.xdg_popup"
    WaylandXDGPositionerPointer          = cstring "SDL.window.wayland.xdg_positioner"
    X11DisplayPointer                    = cstring "SDL.window.x11.display"
    X11ScreenNumber                      = cstring "SDL.window.x11.screen"
    X11WindowNumber                      = cstring "SDL.window.x11.window"

    RendererCreateNameString                           = cstring "name"
    RendererCreateWindwoPointer                        = cstring "window"
    RendererCreateSurfacePointer                       = cstring "surface"
    RendererCreateOutputColourspaceNumber              = cstring "output_colorspace"
    RendererCreatePresentVSyncBoolean                  = cstring "present_vsync"
    RendererCreateVulkanInstancePointer                = cstring "vulkan.instance"
    RendererCreateVulkanSurfaceNumber                  = cstring "vulkan.surface"
    RendererCreateVulkanPhysicalDevicePointer          = cstring "vulkan.physical_device"
    RendererCreateVulkanDevicePointer                  = cstring "vulkan.device"
    RendererCreateVulkanGraphicsQueueFamilyIndexNumber = cstring "vulkan.graphics_queue_family_index"
    RendererCreateVulkanPresentQueueFamilyIndexNumber  = cstring "vulkan.present_queue_family_index"

    RendererNameString                           = cstring "SDL.renderer.name"
    RendererWindowPointer                        = cstring "SDL.renderer.window"
    RendererSurfacePointer                       = cstring "SDL.renderer.surface"
    RendererOutputColourspaceNumber              = cstring "SDL.renderer.output_colorspace"
    RendererHDREnabledBoolean                    = cstring "SDL.renderer.HDR_enabled"
    RendererSDRWhitePointFloat                   = cstring "SDL.renderer.SDR_white_point"
    RendererHDRHeadroomFloat                     = cstring "SDL.renderer.HDR_headroom"
    RendererD3D9DevicePointer                    = cstring "SDL.renderer.d3d9.device"
    RendererD3D11DevicePointer                   = cstring "SDL.renderer.d3d11.device"
    RendererD3D12DevicePointer                   = cstring "SDL.renderer.d3d12.device"
    RendererD3D12CommandQueuePointer             = cstring "SDL.renderer.d3d12.command_queue"
    RendererVulkanInstancePointer                = cstring "SDL.renderer.vulkan.instance"
    RendererVulkanSurfaceNumber                  = cstring "SDL.renderer.vulkan.surface"
    RendererVulkanPhysicalDevicePointer          = cstring "SDL.renderer.vulkan.physical_device"
    RendererVulkanDevicePointer                  = cstring "SDL.renderer.vulkan.device"
    RendererVulkanGraphicsQueueFamilyIndexNumber = cstring "SDL.renderer.vulkan.graphics_queue_family_index"
    RendererVulkanPresentQueueFamilyIndexNumber  = cstring "SDL.renderer.vulkan.present_queue_family_index"
    RendererVulkanSwapchainImageCountNumber      = cstring "SDL.renderer.vulkan.swapchain_image_count"

    TextureCreateColourspaceNumber        = cstring "colorspace"
    TextureCreateFormatNumber             = cstring "format"
    TextureCreateAccessNumber             = cstring "access"
    TextureCreateWidthNumber              = cstring "width"
    TextureCreateHeightNumber             = cstring "height"
    TextureCreateSDRWhitePointFloat       = cstring "SDR_white_point"
    TextureCreateHDRHeadroomFloat         = cstring "HDR_headroom"
    TextureCreateD3D11TexturePointer      = cstring "d3d11.texture"
    TextureCreateD3D11TextureUPointer     = cstring "d3d11.texture_u"
    TextureCreateD3D11TextureVPointer     = cstring "d3d11.texture_v"
    TextureCreateD3D12TexturePointer      = cstring "d3d12.texture"
    TextureCreateD3D12TextureUPointer     = cstring "d3d12.texture_u"
    TextureCreateD3D12TextureVPointer     = cstring "d3d12.texture_v"
    TextureCreateMetalPixelbufferPointer  = cstring "metal.pixelbuffer"
    TextureCreateOpenGLTextureNumber      = cstring "opengl.texture"
    TextureCreateOpenGLTextureUVNumber    = cstring "opengl.texture_uv"
    TextureCreateOpenGLTextureUNumber     = cstring "opengl.texture_u"
    TextureCreateOpenGLTextureVNumber     = cstring "opengl.texture_v"
    TextureCreateOpenGLES2TextureNumber   = cstring "opengles2.texture"
    TextureCreateOpenGLES2TextureUVNumber = cstring "opengles2.texture_uv"
    TextureCreateOpenGLES2TextureUNumber  = cstring "opengles2.texture_u"
    TextureCreateOpenGLES2TextureVNumber  = cstring "opengles2.texture_v"
    TextureCreateVulkanTextureNumber      = cstring "vulkan.texture"

    TextureColourspaceNumber            = cstring "SDL.texture.colorspace"
    TextureSDRWhitePointFloat           = cstring "SDL.texture.SDR_white_point"
    TextureHDRHeadroomFloat             = cstring "SDL.texture.HDR_headroom"
    TextureD3D11TexturePointer          = cstring "SDL.texture.d3d11.texture"
    TextureD3D11TextureUPointer         = cstring "SDL.texture.d3d11.texture_u"
    TextureD3D11TextureVPointer         = cstring "SDL.texture.d3d11.texture_v"
    TextureD3D12TexturePointer          = cstring "SDL.texture.d3d12.texture"
    TextureD3D12TextureUPointer         = cstring "SDL.texture.d3d12.texture_u"
    TextureD3D12TextureVPointer         = cstring "SDL.texture.d3d12.texture_v"
    TextureOpenGLTextureNumber          = cstring "SDL.texture.opengl.texture"
    TextureOpenGLTextureUVNumber        = cstring "SDL.texture.opengl.texture_uv"
    TextureOpenGLTextureUNumber         = cstring "SDL.texture.opengl.texture_u"
    TextureOpenGLTextureVNumber         = cstring "SDL.texture.opengl.texture_v"
    TextureOpenGLTextureTargetNumber    = cstring "SDL.texture.opengl.target"
    TextureOpenGLTexWFloat              = cstring "SDL.texture.opengl.tex_w"
    TextureOpenGLTexHFloat              = cstring "SDL.texture.opengl.tex_h"
    TextureOpenGLES2TextureNumber       = cstring "SDL.texture.opengles2.texture"
    TextureOpenGLES2TextureUVNumber     = cstring "SDL.texture.opengles2.texture_uv"
    TextureOpenGLES2TextureUNumber      = cstring "SDL.texture.opengles2.texture_u"
    TextureOpenGLES2TextureVNumber      = cstring "SDL.texture.opengles2.texture_v"
    TextureOpenGLES2TextureTargetNumber = cstring "SDL.texture.opengles2.target"
    TextureVulkanTextureNumber          = cstring "SDL.texture.vulkan.texture"

type
    Property*   = distinct pointer
    PropertyID* = distinct int32
proc get_property       (id: PropertyID, name: PropertyName, default: pointer): Property {.importc: "SDL_GetProperty"      .}
proc get_number_property(id: PropertyID, name: PropertyName, default: int64  ): int64    {.importc: "SDL_GetNumberProperty".}
proc get_window_property(window: Window): PropertyID {.importc: "SDL_GetWindowProperties".}

proc get_x11_display_pointer*(window: Window): Property = get_property(get_window_property window, X11DisplayPointer, nil)
proc get_x11_screen_number*  (window: Window): int64    = get_number_property(get_window_property window, X11ScreenNumber, 0)
proc get_x11_window_number*  (window: Window): int64    = get_number_property(get_window_property window, X11WindowNumber, 0)
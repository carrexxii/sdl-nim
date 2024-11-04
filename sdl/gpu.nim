import common, bitgen, properties
from pixels  import FColour
from rect    import Rect
from surface import FlipMode
from video   import Window

type TextureUsageFlag* = distinct uint32
TextureUsageFlag.gen_bit_ops(
    texUsageSampler, texUsageColourTarget, texUsageDepthStencilTarget, texUsageGraphicsStorageRead,
    texUsageComputeStorageRead, texUsageComputeStorageWrite, texUsageComputeStorageSimultaneousReadWrite, _
)

type BufferUsageFlag* = distinct uint32
BufferUsageFlag.gen_bit_ops(
    bufUsageVertex, bufUsageIndex, bufUsageIndirect, bufUsageGraphicsStorage,
    bufUsageComputeStorageRead, bufUsageComputeStorageWrite, _
)

type ShaderFormatFlag* = distinct uint32
ShaderFormatFlag.gen_bit_ops(
    shaderFmtPrivate, shaderFmtSpirV, shaderFmtDxBc, shaderFmtDxIl,
    shaderFmtMsl, shaderFmtMetalLib
)
const shaderFmtInvalid* = ShaderFormatFlag 0

type ColourComponentFlag* = distinct uint32
ColourComponentFlag.gen_bit_ops colourCompR, colourCompG, colourCompB, colourCompA

type
    PrimitiveKind* {.importc.} = enum
        primTriangleList
        primTriangleStrip
        primLineList
        primLineStrip
        primPointList

    LoadOp* {.importc.} = enum
        loadLoad
        loadClear
        loadDontCare

    StoreOp* {.importc.} = enum
        storeStore
        storeDontCare
        storeResolve
        storeResolveAndStore

    IndexElementSize* {.importc.} = enum
        elemSz16
        elemSz32

    TextureFormat* {.importc.} = enum
        texFmtInvalid

        texFmtA8Unorm
        texFmtR8Unorm
        texFmtR8G8Unorm
        texFmtR8G8B8A8Unorm
        texFmtR16Unorm
        texFmtR16G16Unorm
        texFmtR16G16B16A16Unorm
        texFmtR10G10B10A2Unorm
        texFmtB5G6R5Unorm
        texFmtB5G5R5A1Unorm
        texFmtB4G4R4A4Unorm
        texFmtB8G8R8A8Unorm

        texFmtBc1RgbaUnorm
        texFmtBc2RgbaUnorm
        texFmtBc3RgbaUnorm
        texFmtBc4RUnorm
        texFmtBc5RgUnorm
        texFmtBc7RgbaUnorm

        texFmtBc6HRgbFloat

        texFmtBc6HRgbUfloat

        texFmtR8Snorm
        texFmtR8G8Snorm
        texFmtR8G8B8A8Snorm
        texFmtR16Snorm
        texFmtR16G16Snorm
        texFmtR16G16B16A16Snorm

        texFmtR16Float
        texFmtR16G16Float
        texFmtR16G16B16A16Float
        texFmtR32Float
        texFmtR32G32Float
        texFmtR32G32B32A32Float

        texFmtR11G11B10Ufloat

        texFmtR8Uint
        texFmtR8G8Uint
        texFmtR8G8B8A8Uint
        texFmtR16Uint
        texFmtR16G16Uint
        texFmtR16G16B16A16Uint
        texFmtR32Uint
        texFmtR32G32Uint
        texFmtR32G32B32A32Uint

        texFmtR8Int
        texFmtR8G8Int
        texFmtR8G8B8A8Int
        texFmtR16Int
        texFmtR16G16Int
        texFmtR16G16B16A16Int
        texFmtR32Int
        texFmtR32G32Int
        texFmtR32G32B32A32Int

        texFmtR8G8B8A8UnormSrgb
        texFmtB8G8R8A8UnormSrgb

        texFmtBc1RgbaUnormSrgb
        texFmtBc2RgbaUnormSrgb
        texFmtBc3RgbaUnormSrgb
        texFmtBc7RgbaUnormSrgb

        texFmtD16Unorm
        texFmtD24Unorm
        texFmtD32Float
        texFmtD24UnormS8Uint
        texFmtD32FloatS8Uint

    TextureKind* {.importc.} = enum
        tex2D
        tex2DArray
        tex3D
        texCube
        texCubeArray

    SampleCount* {.importc.} = enum
        sampleCount1
        sampleCount2
        sampleCount4
        sampleCount8

    CubeMapFace* {.importc.} = enum
        facePositiveX
        faceNegativeX
        facePositiveY
        faceNegativeY
        facePositiveZ
        faceNegativeZ

    TransferBufferUsage* {.importc.} = enum
        transBufUpload
        transBufDownload

    ShaderStage* {.importc.} = enum
        shaderVertex
        shaderFragment

    VertexElementFormat* {.importc.} = enum
        vtxElemInvalid
        vtxElemInt
        vtxElemInt2
        vtxElemInt3
        vtxElemInt4
        vtxElemUint
        vtxElemUint2
        vtxElemUint3
        vtxElemUint4
        vtxElemFloat
        vtxElemFloat2
        vtxElemFloat3
        vtxElemFloat4
        vtxElemByte2
        vtxElemByte4
        vtxElemUbyte2
        vtxElemUbyte4
        vtxElemByte2Norm
        vtxElemByte4Norm
        vtxElemUbyte2Norm
        vtxElemUbyte4Norm
        vtxElemShort2
        vtxElemShort4
        vtxElemUshort2
        vtxElemUshort4
        vtxElemShort2Norm
        vtxElemShort4Norm
        vtxElemUshort2Norm
        vtxElemUshort4Norm
        vtxElemHalf2
        vtxElemHalf4

    VertexInputRate* {.importc.} = enum
        inputRateVertex
        inputRateInstance

    FillMode* {.importc.} = enum
        fillModeFill
        fillModeLine

    CullMode* {.importc.} = enum
        cullModeNone
        cullModeFront
        cullModeBack

    FrontFace* {.importc.} = enum
        frontFaceCcw
        frontFaceCw

    CompareOp* {.importc.} = enum
        compareInvalid
        compareNever
        compareLess
        compareEqual
        compareLessOrEqual
        compareGreater
        compareNotEqual
        compareGreaterOrEqual
        compareAlways

    StencilOp* {.importc.} = enum
        stencilInvalid
        stencilKeep
        stencilZero
        stencilReplace
        stencilIncrAndClamp
        stencilDecrAndClamp
        stencilInvert
        stencilIncrAndWrap
        stencilDecrAndWrap

    BlendOp* {.importc.} = enum
        blendInvalid
        blendAdd
        blendSub
        blendRevSub
        blendMin
        blendMax

    BlendFactor* {.importc.} = enum
        blendFacInvalid
        blendFacZero
        blendFacOne
        blendFacSrcColour
        blendFacOneMinusSrcColour
        blendFacDstColour
        blendFacOneMinusDstColour
        blendFacSrcAlpha
        blendFacOneMinusAlpha
        blendFacDstAlpha
        blendFacOneMinusDstAlpha
        blendFacConstColour
        blendFacOneMinusConstColour
        blendFacSrcAlphaSaturate

    Filter* {.importc.} = enum
        filterNearest
        filterLinear

    SamplerMipMapMode* {.importc.} = enum
        mipMapModeNearest
        mipMapModeLinear

    SamplerAddressMode* {.importc.} = enum
        addrModeRepeat
        addrModeMirroredRepeat
        addrModeClampToEdge

    PresentMode* {.importc.} = enum
        presentModeVsync
        presentModeImmediate
        presentModeMailbox

    SwapchainComposition* {.importc.} = enum
        swapchainSdr
        swapchainSdrLinear
        swapchainHdrExtendedLinear
        swapchainHdr10St2048

type
    Device*           = OpaquePointer
    Buffer*           = OpaquePointer
    TransferBuffer*   = OpaquePointer
    Texture*          = OpaquePointer
    Sampler*          = OpaquePointer
    Shader*           = OpaquePointer
    ComputePipeline*  = OpaquePointer
    GraphicsPipeline* = OpaquePointer
    CommandBuffer*    = OpaquePointer
    RenderPass*       = OpaquePointer
    ComputePass*      = OpaquePointer
    CopyPass*         = OpaquePointer
    Fence*            = OpaquePointer

    Viewport* = object
        x*, y*, w*, h*: float32
        min_depth*    : float32
        max_depth*    : float32

    TextureTransferInfo* = object
        trans_buf*     : TransferBuffer
        offset*        : uint32
        px_per_row*    : uint32
        rows_per_layer*: uint32

    TransferBufferLocation* = object
        trans_buf*: TransferBuffer
        offset*   : uint32

    TextureLocation* = object
        tex*      : Texture
        mip_lvl*  : uint32
        layer*    : uint32
        x*, y*, z*: uint32

    TextureRegion* = object
        tex*      : Texture
        mip_lvl*  : uint32
        layer*    : uint32
        x*, y*, z*: uint32
        w*, h*, d*: uint32

    BlitRegion* = object
        tex*                 : Texture
        mip_lvl*             : uint32
        layer_or_depth_plane*: uint32
        x*, y*, w*, h*       : uint32

    BufferLocation* = object
        buf*   : Buffer
        offset*: uint32

    BufferRegion* = object
        buf*   : Buffer
        offset*: uint32
        sz*    : uint32

    IndirectDrawCommand* = object
        vtx_count* : uint32
        inst_count*: uint32
        fst_vtx*   : uint32
        fst_inst*  : uint32

    IndexedIndirectDrawCommand* = object
        idx_count* : uint32
        inst_count*: uint32
        fst_idx*   : uint32
        vtx_offset*: int32
        fst_inst*  : uint32

    IndirectDispatchCommand* = object
        group_count_x*: uint32
        group_count_y*: uint32
        group_count_z*: uint32

    SamplerCreateInfo* = object
        min_filter*       : Filter
        mag_filter*       : Filter
        mip_map_mode*     : SamplerMipMapMode
        addr_mode_u*      : SamplerAddressMode
        addr_mode_v*      : SamplerAddressMode
        addr_mode_w*      : SamplerAddressMode
        mip_lod_bias*     : float32
        max_anisotropy*   : float32
        compare_op*       : CompareOp
        min_lod*          : float32
        max_lod*          : float32
        enable_anisotropy*: cbool
        enable_compare*   : cbool
        _                 : array[2, byte]
        props*            : PropertyId

    VertexBufferDescription* = object
        slot*      : uint32
        pitch*     : uint32
        input_rate*: VertexInputRate
        step_rate* : uint32

    VertexAttribute* = object
        location*: uint32
        buf_slot*: uint32
        fmt*     : VertexElementFormat
        offset*  : uint32

    VertexInputState* = object
        buf_descrs*    : ptr UncheckedArray[VertexBufferDescription]
        vtx_buf_count* : uint32
        vtx_attrs*     : ptr UncheckedArray[VertexAttribute]
        vtx_attr_count*: uint32

    StencilOpState* = object
        fail_op*      : StencilOp
        pass_op*      : StencilOp
        depth_fail_op*: StencilOp
        compare_op*   : CompareOp

    ColourTargetBlendState* = object
        src_colour_blend_factor* : BlendFactor
        dst_colour_blend_factor* : BlendFactor
        colour_blend_op*         : BlendOp
        src_alpha_blend_factor*  : BlendFactor
        dst_alpha_blend_factor*  : BlendFactor
        alpha_blend_op*          : BlendOp
        colour_write_mask*       : ColourComponentFlag
        enable_blend*            : cbool
        enable_colour_write_mask*: cbool
        _                        : array[2, byte]

    ShaderCreateInfo* = object
        code_sz*          : uint
        code*             : pointer
        entry_point*      : cstring
        fmt*              : ShaderFormatFlag
        stage*            : ShaderStage
        sampler_count*    : uint32
        storage_tex_count*: uint32
        storage_buf_count*: uint32
        uniform_buf_count*: uint32
        props*            : PropertyId

    TextureCreateInfo* = object
        kind*            : TextureKind
        fmt*             : TextureFormat
        usage*           : TextureUsageFlag
        w*, h*           : uint32
        d_or_layer_count*: uint32
        lvl_count*       : uint32
        sample_count*    : SampleCount
        props*           : PropertyId

    BufferCreateInfo* = object
        usage*: BufferUsageFlag
        sz*   : uint32
        props*: PropertyId

    TransferBufferCreateInfo* = object
        usage*: TransferBufferUsage
        sz*   : uint32
        props*: PropertyId

    RasterizerState* = object
        fill_mode*          : FillMode
        cull_mode*          : CullMode
        front_face*         : FrontFace
        d_bias_const_factor*: float32
        d_bias_clamp*       : float32
        d_bias_slope_factor*: float32
        enable_depth_bias*  : cbool
        enable_depth_clip*  : cbool
        _                   : array[2, byte]

    MultisampleState* = object
        sample_count*: SampleCount
        sample_mask* : uint32
        enable_mask* : cbool
        _            : array[3, byte]

    DepthStencilState* = object
        compare_op*         : CompareOp
        back_stencil_state* : StencilOpState
        front_stencil_state*: StencilOpState
        compare_mask*       : uint8
        write_mask*         : uint8
        enable_depth_test*  : cbool
        enable_depth_write* : cbool
        enable_stencil_test*: cbool
        _                   : array[3, byte]

    ColourTargetDescription* = object
        fmt*        : TextureFormat
        blend_state*: ColourTargetBlendState

    GraphicsPipelineTargetInfo* = object
        colour_target_descrs*    : ptr UncheckedArray[ColourTargetDescription]
        colour_target_count*     : uint32
        d_stencil_fmt*           : TextureFormat
        has_depth_stencil_target*: cbool
        _                        : array[3, byte]

    GraphicsPipelineCreateInfo* = object
        vtx_shader*       : Shader
        frag_shader*      : Shader
        vtx_input_state*  : VertexInputState
        prim_kind*        : PrimitiveKind
        raster_state*     : RasterizerState
        multisample_state*: MultisampleState
        d_stencil_state*  : DepthStencilState
        target_info*      : GraphicsPipelineTargetInfo
        props*            : PropertyId

    ComputePipelineCreateInfo* = object
        code_sz*                    : uint
        code*                       : pointer
        entry_point*                : cstring
        fmt*                        : ShaderFormatFlag
        sampler_count*              : uint32
        readonly_storage_tex_count* : uint32
        readonly_storage_buf_count* : uint32
        readwrite_storage_tex_count*: uint32
        readwrite_storage_buf_count*: uint32
        uniform_buf_count*          : uint32
        thread_count_x*             : uint32
        thread_count_y*             : uint32
        thread_count_z*             : uint32
        props*                      : PropertyId

    ColourTargetInfo* = object
        tex*                 : Texture
        mip_lvl*             : uint32
        layer_or_depth_plane*: uint32
        clear_colour*        : FColour
        load_op*             : LoadOp
        store_op*            : StoreOp
        resolve_tex*         : Texture
        resolve_mip_lvl*     : uint32
        resolve_layer*       : uint32
        cycle*               : cbool
        cycle_resolve_tex*   : cbool
        _                    : array[2, byte]

    DepthStencilTargetInfo* = object
        tex*             : Texture
        clear_depth*     : float32
        load_op*         : LoadOp
        store_op*        : StoreOp
        stencil_load_op* : LoadOp
        stencil_store_op*: StoreOp
        cycle*           : cbool
        clear_stencil*   : uint8
        _                : array[2, byte]

    BlitInfo* = object
        src*, dst*   : BlitRegion
        load_op*     : LoadOp
        clear_colour*: FColour
        flip_mode*   : FlipMode
        filter*      : Filter
        cycle*       : cbool
        _            : array[3, byte]

    BufferBinding* = object
        buf*   : Buffer
        offset*: uint32

    TextureSamplerBinding* = object
        tex*    : Texture
        sampler*: Sampler

    StorageBufferReadWriteBinding* = object
        buf*  : Buffer
        cycle*: cbool
        _     : array[3, byte]

    StorageTextureReadWriteBinding* = object
        tex*    : Texture
        mip_lvl*: uint32
        layer*  : uint32
        cycle*  : cbool
        _       : array[3, byte]

#[ -------------------------------------------------------------------- ]#

using
    dev         : Device
    win         : Window
    buf         : Buffer
    trans_buf   : TransferBuffer
    cmd_buf     : CommandBuffer
    tex         : Texture
    sampler     : Sampler
    shader      : Shader
    ren_pass    : RenderPass
    compute_pass: ComputePass
    copy_pass   : CopyPass
    fst_slot    : uint32
    bind_count  : uint32

{.push dynlib: SdlLib.}
proc sdl_gpu_supports_shader_formats*(fmt_flags: ShaderFormatFlag; name: cstring): cbool           {.importc: "SDL_GPUSupportsShaderFormats"     .}
proc sdl_gpu_supports_properties*(props: PropertyId): cbool                                        {.importc: "SDL_GPUSupportsProperties"        .}

proc sdl_create_gpu_device*(fmt_flags: ShaderFormatFlag; debug_mode: cbool; name: cstring): Device {.importc: "SDL_CreateGPUDevice"              .}
proc sdl_create_gpu_device_with_properties*(props: PropertyId): Device                             {.importc: "SDL_CreateGPUDeviceWithProperties".}
proc sdl_destroy_gpu_device*(dev)                                                                  {.importc: "SDL_DestroyGPUDevice"             .}
proc sdl_get_num_gpu_drivers*(): cint                                                              {.importc: "SDL_GetNumGPUDrivers"             .}
proc sdl_get_gpu_driver*(idx: cint): cstring                                                       {.importc: "SDL_GetGPUDriver"                 .}
proc sdl_get_gpu_device_driver*(dev): cstring                                                      {.importc: "SDL_GetGPUDeviceDriver"           .}
proc sdl_get_gpu_shader_formats*(dev): ShaderFormatFlag                                            {.importc: "SDL_GetGPUShaderFormats"          .}

proc sdl_create_gpu_compute_pipeline*(dev; create_info: ComputePipelineCreateInfo): ComputePipeline    {.importc: "SDL_CreateGPUComputePipeline" .}
proc sdl_create_gpu_graphics_pipeline*(dev; create_info: GraphicsPipelineCreateInfo): GraphicsPipeline {.importc: "SDL_CreateGPUGraphicsPipeline".}
proc sdl_create_gpu_sampler*(dev; create_info: SamplerCreateInfo): Sampler                             {.importc: "SDL_CreateGPUSampler"         .}
proc sdl_create_gpu_shader*(dev; create_info: ShaderCreateInfo): Shader                                {.importc: "SDL_CreateGPUShader"          .}
proc sdl_create_gpu_texture*(dev; create_info: TextureCreateInfo): Texture                             {.importc: "SDL_CreateGPUTexture"         .}
proc sdl_create_gpu_buffer*(dev; create_info: BufferCreateInfo): Buffer                                {.importc: "SDL_CreateGPUBuffer"          .}
proc sdl_create_gpu_transfer_buffer*(dev; create_info: TransferBufferCreateInfo): TransferBuffer       {.importc: "SDL_CreateGPUTransferBuffer"  .}

proc sdl_release_gpu_texture*(dev; tex)                                {.importc: "SDL_ReleaseGPUTexture"         .}
proc sdl_release_gpu_sampler*(dev; sampler)                            {.importc: "SDL_ReleaseGPUSampler"         .}
proc sdl_release_gpu_buffer*(dev; buf)                                 {.importc: "SDL_ReleaseGPUBuffer"          .}
proc sdl_release_gpu_transfer_buffer*(dev; trans_buf)                  {.importc: "SDL_ReleaseGPUTransferBuffer"  .}
proc sdl_release_gpu_compute_pipeline*(dev; pipeln: ComputePipeline)   {.importc: "SDL_ReleaseGPUComputePipeline" .}
proc sdl_release_gpu_shader*(dev; shader)                              {.importc: "SDL_ReleaseGPUShader"          .}
proc sdl_release_gpu_graphics_pipeline*(dev; pipeln: GraphicsPipeline) {.importc: "SDL_ReleaseGPUGraphicsPipeline".}

proc sdl_set_gpu_buffer_name*(dev; buf; text: cstring)       {.importc: "SDL_SetGPUBufferName"  .}
proc sdl_set_gpu_texture_name*(dev; tex; text: cstring)       {.importc: "SDL_SetGPUTextureName"  .}
proc sdl_insert_gpu_debug_label*(cmd_buf; text: cstring)       {.importc: "SDL_InsertGPUDebugLabel"  .}
proc sdl_push_gpu_debug_group*(cmd_buf; name: cstring)       {.importc: "SDL_PushGPUDebugGroup"  .}
proc sdl_pop_gpu_debug_group*(cmd_buf)       {.importc: "SDL_PopGPUDebugGroup"  .}

proc sdl_acquire_gpu_command_buffer*(dev): CommandBuffer       {.importc: "SDL_AcquireGPUCommandBuffer"  .}
proc sdl_push_gpu_vertex_uniform_data*(cmd_buf; slot_idx: uint32; data: pointer; len: uint32)       {.importc: "SDL_PushGPUVertexUniformData"  .}
proc sdl_push_gpu_fragment_uniform_data*(cmd_buf; slot_idx: uint32; data: pointer; len: uint32)       {.importc: "SDL_PushGPUFragmentUniformData"  .}
proc sdl_push_gpu_compute_uniform_data*(cmd_buf; slot_idx: uint32; data: pointer; len: uint32)       {.importc: "SDL_PushGPUComputeUniformData"  .}

proc sdl_begin_gpu_render_pass*(cmd_buf; cti: ptr ColourTargetInfo; ct_count: uint32; dsti: ptr DepthStencilTargetInfo): RenderPass {.importc: "SDL_BeginGPURenderPass"              .}
proc sdl_bind_gpu_graphics_pipeline*(ren_pass; gfx_pipeln: GraphicsPipeline)                                                        {.importc: "SDL_BindGPUGraphicsPipeline"         .}
proc sdl_set_gpu_viewport*(ren_pass; viewport: ptr Viewport)                                                                        {.importc: "SDL_SetGPUViewport"                  .}
proc sdl_set_gpu_scissor*(ren_pass; scissor: ptr Rect)                                                                              {.importc: "SDL_SetGPUScissor"                   .}
proc sdl_set_gpu_blend_constants*(ren_pass; blend_consts: FColour)                                                                  {.importc: "SDL_SetGPUBlendConstants"            .}
proc sdl_set_gpu_stencil_reference*(ren_pass; `ref`: uint8)                                                                         {.importc: "SDL_SetGPUStencilReference"          .}
proc sdl_bind_gpu_vertex_buffer*(ren_pass; fst_slot; binds: ptr BufferBinding; bind_count)                                          {.importc: "SDL_BindGPUVertexBuffers"            .}
proc sdl_bind_gpu_index_buffer*(ren_pass; `bind`: ptr BufferBinding; idx_elem_sz: IndexElementSize)                                 {.importc: "SDL_BindGPUIndexBuffer"              .}
proc sdl_bind_gpu_vertex_samplers*(ren_pass; fst_slot; binds: ptr TextureSamplerBinding; bind_count)                                {.importc: "SDL_BindGPUVertexSamplers"           .}
proc sdl_bind_gpu_vertex_storage_textures*(ren_pass; fst_slot; texs: ptr Texture; bind_count)                                       {.importc: "SDL_BindGPUVertexStorageTextures"    .}
proc sdl_bind_gpu_vertex_storage_buffers*(ren_pass; fst_slot; bufs: Buffer; bind_count)                                             {.importc: "SDL_BindGPUVertexStorageBuffers"     .}
proc sdl_bind_gpu_fragment_samplers*(ren_pass; fst_slot; binds: ptr TextureSamplerBinding; bind_count)                              {.importc: "SDL_BindGPUFragmentSamplers"         .}
proc sdl_bind_gpu_fragment_storage_textures*(ren_pass; fst_slot; texs: ptr Texture; bind_count)                                     {.importc: "SDL_BindGPUFragmentStorageTextures"  .}
proc sdl_bind_gpu_fragment_storage_buffers*(ren_pass; fst_slot; bufs: Buffer; bind_count)                                           {.importc: "SDL_BindGPUFragmentStorageBuffers"   .}
proc sdl_draw_gpu_indexed_primitives*(ren_pass; idx_count, inst_count, fst_idx: uint32; vtx_offset: int32; fst_inst: uint32)        {.importc: "SDL_DrawGPUIndexedPrimitives"        .}
proc sdl_draw_gpu_primitives*(ren_pass; vtx_count, inst_count, fst_vtx, fst_inst: uint32)                                           {.importc: "SDL_DrawGPUPrimitives"               .}
proc sdl_draw_gpu_primitives_indirect*(ren_pass; buf: Buffer; offset, draw_count: uint32)                                           {.importc: "SDL_DrawGPUPrimitivesIndirect"       .}
proc sdl_draw_gpu_indexed_primitives_indirect*(ren_pass; buf: Buffer; offset, draw_count: uint32)                                   {.importc: "SDL_DrawGPUIndexedPrimitivesIndirect".}
proc sdl_end_gpu_render_pass*(ren_pass)                                                                                             {.importc: "SDL_EndGPURenderPass"                .}

proc sdl_begin_gpu_compute_pass*(cmd_buf; storage_tex_binds: ptr StorageTextureReadWriteBinding; storage_tex_bind_count: uint32;
                                          storage_buf_binds: ptr StorageBufferReadWriteBinding ; storage_buf_bind_count: uint32): ComputePass {.importc: "SDL_BeginGPUComputePass"          .}
proc sdl_bind_gpu_compute_pipeline*(compute_pass; pipeln: ComputePipeline)                                                                    {.importc: "SDL_BindGPUComputePipeline"       .}
proc sdl_bind_gpu_compute_samplers*(compute_pass; fst_slot; binds: ptr TextureSamplerBinding; bind_count: uint32)                             {.importc: "SDL_BindGPUComputeSamplers"       .}
proc sdl_bind_gpu_compute_storage_textures*(compute_pass; fst_slot; texs: ptr Texture; tex_count: uint32)                                     {.importc: "SDL_BindGPUComputeStorageTextures".}
proc sdl_bind_gpu_compute_storage_buffers*(compute_pass; fst_slot; bufs: ptr Buffer; buf_count: uint32)                                       {.importc: "SDL_BindGPUComputeStorageBuffers" .}
proc sdl_dispatch_gpu_compute*(compute_pass; group_count_x, group_count_y, group_count_z: uint32)                                             {.importc: "SDL_DispatchGPUCompute"           .}
proc sdl_dispatch_gpu_compute_indirect*(compute_pass; buf: Buffer; offset: uint32)                                                            {.importc: "SDL_DispatchGPUComputeIndirect"   .}
proc sdl_end_gpu_compute_pass*(compute_pass)                                                                                                  {.importc: "SDL_EndGPUComputePass"            .}

proc sdl_map_gpu_transfer_buffer*(dev; buf: TransferBuffer; cycle: cbool): pointer {.importc: "SDL_MapGPUTransferBuffer"  .}
proc sdl_unmap_gpu_transfer_buffer*(dev; buf: TransferBuffer) {.importc: "SDL_UnmapGPUTransferBuffer".}

proc sdl_begin_gpu_copy_pass*(cmd_buf): CopyPass                                                                {.importc: "SDL_BeginGPUCopyPass"       .}
proc sdl_upload_to_gpu_texture*(copy_pass; src: ptr TextureTransferInfo; dst: ptr TextureRegion; cycle: cbool)  {.importc: "SDL_UploadToGPUTexture"     .}
proc sdl_upload_to_gpu_buffer*(copy_pass; src: ptr TransferBufferLocation; dst: ptr BufferRegion; cycle: cbool) {.importc: "SDL_UploadToGPUBuffer"      .}
proc sdl_copy_gpu_texture_to_texture*(copy_pass; src, dst: ptr TextureLocation; w, h, d: uint32; cycle: cbool)  {.importc: "SDL_CopyGPUTextureToTexture".}
proc sdl_copy_gpu_buffer_to_buffer*(copy_pass; src, dst: ptr BufferLocation; sz: uint32; cycle: cbool)          {.importc: "SDL_CopyGPUBufferToBuffer"  .}
proc sdl_download_from_gpu_texture*(copy_pass; src: ptr TextureRegion; dst: ptr TextureTransferInfo)            {.importc: "SDL_DownloadFromGPUTexture" .}
proc sdl_download_from_gpu_buffer*(copy_pass; src: ptr BufferRegion; dst: ptr TransferBufferLocation)           {.importc: "SDL_DownloadFromGPUBuffer"  .}
proc sdl_end_gpu_copy_pass*(copy_pass)                                                                          {.importc: "SDL_EndGPUCopyPass"         .}

proc sdl_generate_mip_maps_for_gpu_texture*(cmd_buf; tex) {.importc: "SDL_GenerateMipmapsForGPUTexture".}
proc sdl_blit_gpu_texture*(cmd_buf; info: ptr BlitInfo)   {.importc: "SDL_BlitGPUTexture"              .}

proc sdl_window_supports_gpu_swapchain_composition*(dev; win; comp: SwapchainComposition): cbool         {.importc: "SDL_WindowSupportsGPUSwapchainComposition".}
proc sdl_window_supports_gpu_present_mode*(dev; win; mode: PresentMode): cbool                           {.importc: "SDL_WindowSupportsGPUPresentMode"         .}
proc sdl_claim_window_for_gpu_device*(dev; win): cbool                                                   {.importc: "SDL_ClaimWindowForGPUDevice"              .}
proc sdl_release_window_from_gpu_device*(dev; win)                                                       {.importc: "SDL_ReleaseWindowFromGPUDevice"           .}
proc sdl_set_gpu_swapchain_parameters*(dev; win; comp: SwapchainComposition; mode: PresentMode): cbool   {.importc: "SDL_SetGPUSwapchainParameters"            .}
proc sdl_get_gpu_swapchain_texture_format*(dev; win): TextureFormat                                      {.importc: "SDL_GetGPUSwapchainTextureFormat"         .}
proc sdl_acquire_gpu_swapchain_texture*(cmd_buf; win; tex: ptr Texture; tex_w, tex_h: ptr uint32): cbool {.importc: "SDL_AcquireGPUSwapchainTexture"           .}
proc sdl_submit_gpu_command_buffer*(cmd_buf): cbool                                                      {.importc: "SDL_SubmitGPUCommandBuffer"               .}
proc sdl_submit_gpu_command_buffer_and_acquire_fence*(cmd_buf): Fence                                    {.importc: "SDL_SubmitGPUCommandBufferAndAcquireFence".}
proc sdl_wait_for_gpu_idle*(dev): cbool                                                                  {.importc: "SDL_WaitForGPUIdle"                       .}
proc sdl_wait_for_gpu_fences*(dev; wait_all: cbool; fences: Fence; fence_count: uint32): cbool           {.importc: "SDL_WaitForGPUFences"                     .}
proc sdl_query_gpu_fence*(dev; fence: Fence): cbool                                                      {.importc: "SDL_QueryGPUFence"                        .}
proc sdl_release_gpu_fence*(dev; fence: Fence)                                                           {.importc: "SDL_ReleaseGPUFence"                      .}

proc sdl_gpu_texture_format_texel_block_size*(fmt: TextureFormat): uint32                                         {.importc: "SDL_GPUTextureFormatTexelBlockSize".}
proc sdl_gpu_texture_supports_format*(dev; fmt: TextureFormat; kind: TextureKind; usage: TextureUsageFlag): cbool {.importc: "SDL_GPUTextureSupportsFormat"      .}
proc sdl_gpu_texture_supports_sample_count*(dev; fmt: TextureFormat; cample_count: SampleCount): cbool            {.importc: "SDL_GPUTextureSupportsSampleCount" .}

# TODO
when defined SdlPlatformGdk:
    proc sdl_gdk_suspend_gpu*(dev) {.importc: "SDL_GDKSuspendGPU".}
    proc sdl_gdk_resume_gpu*(dev)  {.importc: "SDL_GDKResumeGPU" .}
{.pop.}

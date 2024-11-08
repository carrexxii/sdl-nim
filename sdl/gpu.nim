import common, bitgen, properties
from std/strformat import `&`
from pixels  import FColour
from rect    import Rect
from surface import FlipMode
from video   import Window

# TODO: create separate kinds for buffers

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
    shaderFmtMsl, shaderFmtMetalLib, _, _,
)
const shaderFmtInvalid* = ShaderFormatFlag 0

type ColourComponentFlag* = distinct uint32
ColourComponentFlag.gen_bit_ops colourCompR, colourCompG, colourCompB, colourCompA

type
    PrimitiveKind* {.size: sizeof(cint).} = enum
        primTriangleList
        primTriangleStrip
        primLineList
        primLineStrip
        primPointList

    LoadOp* {.size: sizeof(cint).} = enum
        loadLoad
        loadClear
        loadDontCare

    StoreOp* {.size: sizeof(cint).} = enum
        storeStore
        storeDontCare
        storeResolve
        storeResolveAndStore

    IndexElementSize* {.size: sizeof(cint).} = enum
        elemSz16
        elemSz32

    TextureFormat* {.size: sizeof(cint).} = enum
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

    TextureKind* {.size: sizeof(cint).} = enum
        tex2D
        tex2DArray
        tex3D
        texCube
        texCubeArray

    SampleCount* {.size: sizeof(cint).} = enum
        sampleCount1
        sampleCount2
        sampleCount4
        sampleCount8

    CubeMapFace* {.size: sizeof(cint).} = enum
        facePositiveX
        faceNegativeX
        facePositiveY
        faceNegativeY
        facePositiveZ
        faceNegativeZ

    TransferBufferUsage* {.size: sizeof(cint).} = enum
        transferUpload
        transferDownload

    ShaderStage* {.size: sizeof(cint).} = enum
        shaderVertex
        shaderFragment

    VertexElementFormat* {.size: sizeof(cint).} = enum
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

    VertexInputRate* {.size: sizeof(cint).} = enum
        inputVertex
        inputInstance

    FillMode* {.size: sizeof(cint).} = enum
        fillFill
        fillLine

    CullMode* {.size: sizeof(cint).} = enum
        cullNone
        cullFront
        cullBack

    FrontFace* {.size: sizeof(cint).} = enum
        frontCcw
        frontCw

    CompareOp* {.size: sizeof(cint).} = enum
        cmpInvalid
        cmpNever
        cmpLess
        cmpEqual
        cmpLessOrEqual
        cmpGreater
        cmpNotEqual
        cmpGreaterOrEqual
        cmpAlways

    StencilOp* {.size: sizeof(cint).} = enum
        stencilInvalid
        stencilKeep
        stencilZero
        stencilReplace
        stencilIncrAndClamp
        stencilDecrAndClamp
        stencilInvert
        stencilIncrAndWrap
        stencilDecrAndWrap

    BlendOp* {.size: sizeof(cint).} = enum
        blendInvalid
        blendAdd
        blendSub
        blendRevSub
        blendMin
        blendMax

    BlendFactor* {.size: sizeof(cint).} = enum
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

    Filter* {.size: sizeof(cint).} = enum
        filterNearest
        filterLinear

    SamplerMipMapMode* {.size: sizeof(cint).} = enum
        mipMapModeNearest
        mipMapModeLinear

    SamplerAddressMode* {.size: sizeof(cint).} = enum
        addrModeRepeat
        addrModeMirroredRepeat
        addrModeClampToEdge

    PresentMode* {.size: sizeof(cint).} = enum
        presentModeVsync
        presentModeImmediate
        presentModeMailbox

    SwapchainComposition* {.size: sizeof(cint).} = enum
        swapchainSdr
        swapchainSdrLinear
        swapchainHdrExtendedLinear
        swapchainHdr10St2048

type
    Device*           = distinct pointer
    Buffer*           = distinct pointer
    TransferBuffer*   = distinct pointer
    Texture*          = distinct pointer
    Sampler*          = distinct pointer
    Shader*           = distinct pointer
    ComputePipeline*  = distinct pointer
    GraphicsPipeline* = distinct pointer
    CommandBuffer*    = distinct pointer
    RenderPass*       = distinct pointer
    ComputePass*      = distinct pointer
    CopyPass*         = distinct pointer
    Fence*            = distinct pointer

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
        enable_anisotropy*: bool
        enable_compare*   : bool
        _                 : array[2, byte]
        props*            : PropertyId

    VertexBufferDescription* = object
        slot*      : uint32
        pitch*     : uint32
        input_rate*: VertexInputRate
        step_rate* : uint32

    VertexAttribute* = object
        loc*   : uint32
        slot*  : uint32
        fmt*   : VertexElementFormat
        offset*: uint32

    VertexInputState* = object
        buf_descrs*: ptr UncheckedArray[VertexBufferDescription]
        buf_count* : uint32
        attrs*     : ptr UncheckedArray[VertexAttribute]
        attr_count*: uint32

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
        enable_blend*            : bool
        enable_colour_write_mask*: bool
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
        kind*                : TextureKind
        fmt*                 : TextureFormat
        usage*               : TextureUsageFlag
        w*, h*               : uint32
        depth_or_layer_count*: uint32
        lvl_count*           : uint32
        sample_count*        : SampleCount
        props*               : PropertyId

    BufferCreateInfo* = object
        usage*: BufferUsageFlag
        sz*   : uint32
        props*: PropertyId

    TransferBufferCreateInfo* = object
        usage*: TransferBufferUsage
        sz*   : uint32
        props*: PropertyId

    RasterizerState* = object
        fill_mode*              : FillMode
        cull_mode*              : CullMode
        front_face*             : FrontFace
        depth_bias_const_factor*: float32
        depth_bias_clamp*       : float32
        depth_bias_slope_factor*: float32
        enable_depth_bias*      : bool
        enable_depth_clip*      : bool
        _                       : array[2, byte]

    MultisampleState* = object
        sample_count*: SampleCount
        sample_mask* : uint32
        enable_mask* : bool
        _            : array[3, byte]

    DepthStencilState* = object
        compare_op*         : CompareOp
        back_stencil_state* : StencilOpState
        front_stencil_state*: StencilOpState
        compare_mask*       : uint8
        write_mask*         : uint8
        enable_depth_test*  : bool
        enable_depth_write* : bool
        enable_stencil_test*: bool
        _                   : array[3, byte]

    ColourTargetDescription* = object
        fmt*        : TextureFormat
        blend_state*: ColourTargetBlendState

    GraphicsPipelineTargetInfo* = object
        colour_target_descrs*    : ptr UncheckedArray[ColourTargetDescription]
        colour_target_count*     : uint32
        depth_stencil_fmt*       : TextureFormat
        has_depth_stencil_target*: bool
        _                        : array[3, byte]

    GraphicsPipelineCreateInfo* = object
        vtx_shader*         : Shader
        frag_shader*        : Shader
        vtx_input_state*    : VertexInputState
        prim_kind*          : PrimitiveKind
        raster_state*       : RasterizerState
        multisample_state*  : MultisampleState
        depth_stencil_state*: DepthStencilState
        target_info*        : GraphicsPipelineTargetInfo
        props*              : PropertyId

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
        cycle*               : bool
        cycle_resolve_tex*   : bool
        _                    : array[2, byte]

    DepthStencilTargetInfo* = object
        tex*             : Texture
        clear_depth*     : float32
        load_op*         : LoadOp
        store_op*        : StoreOp
        stencil_load_op* : LoadOp
        stencil_store_op*: StoreOp
        cycle*           : bool
        clear_stencil*   : uint8
        _                : array[2, byte]

    BlitInfo* = object
        src*, dst*   : BlitRegion
        load_op*     : LoadOp
        clear_colour*: FColour
        flip_mode*   : FlipMode
        filter*      : Filter
        cycle*       : bool
        _            : array[3, byte]

    BufferBinding* = object
        buf*   : Buffer
        offset*: uint32

    TextureSamplerBinding* = object
        tex*    : Texture
        sampler*: Sampler

    StorageBufferReadWriteBinding* = object
        buf*  : Buffer
        cycle*: bool
        _     : array[3, byte]

    StorageTextureReadWriteBinding* = object
        tex*    : Texture
        mip_lvl*: uint32
        layer*  : uint32
        cycle*  : bool
        _       : array[3, byte]

converter `Device -> bool`*(p: Device): bool                     = cast[pointer](p) != nil
converter `Buffer -> bool`*(p: Buffer): bool                     = cast[pointer](p) != nil
converter `TransferBuffer -> bool`*(p: TransferBuffer): bool     = cast[pointer](p) != nil
converter `Texture -> bool`*(p: Texture): bool                   = cast[pointer](p) != nil
converter `Sampler -> bool`*(p: Sampler): bool                   = cast[pointer](p) != nil
converter `Shader -> bool`*(p: Shader): bool                     = cast[pointer](p) != nil
converter `ComputePipeline -> bool`*(p: ComputePipeline): bool   = cast[pointer](p) != nil
converter `GraphicsPipeline -> bool`*(p: GraphicsPipeline): bool = cast[pointer](p) != nil
converter `CommandBuffer -> bool`*(p: CommandBuffer): bool       = cast[pointer](p) != nil
converter `RenderPass -> bool`*(p: RenderPass): bool             = cast[pointer](p) != nil
converter `ComputePass -> bool`*(p: ComputePass): bool           = cast[pointer](p) != nil
converter `CopyPass -> bool`*(p: CopyPass): bool                 = cast[pointer](p) != nil
converter `Fence -> bool`*(p: Fence): bool                       = cast[pointer](p) != nil

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
proc sdl_gpu_supports_shader_formats*(fmt_flags: ShaderFormatFlag; name: cstring): bool           {.importc: "SDL_GPUSupportsShaderFormats"     .}
proc sdl_gpu_supports_properties*(props: PropertyId): bool                                        {.importc: "SDL_GPUSupportsProperties"        .}

proc sdl_create_gpu_device*(fmt_flags: ShaderFormatFlag; debug_mode: bool; name: cstring): Device {.importc: "SDL_CreateGPUDevice"              .}
proc sdl_create_gpu_device_with_properties*(props: PropertyId): Device                            {.importc: "SDL_CreateGPUDeviceWithProperties".}
proc sdl_destroy_gpu_device*(dev)                                                                 {.importc: "SDL_DestroyGPUDevice"             .}
proc sdl_get_num_gpu_drivers*(): cint                                                             {.importc: "SDL_GetNumGPUDrivers"             .}
proc sdl_get_gpu_driver*(idx: cint): cstring                                                      {.importc: "SDL_GetGPUDriver"                 .}
proc sdl_get_gpu_device_driver*(dev): cstring                                                     {.importc: "SDL_GetGPUDeviceDriver"           .}
proc sdl_get_gpu_shader_formats*(dev): ShaderFormatFlag                                           {.importc: "SDL_GetGPUShaderFormats"          .}

proc sdl_create_gpu_compute_pipeline*(dev; create_info: ptr ComputePipelineCreateInfo): ComputePipeline    {.importc: "SDL_CreateGPUComputePipeline" .}
proc sdl_create_gpu_graphics_pipeline*(dev; create_info: ptr GraphicsPipelineCreateInfo): GraphicsPipeline {.importc: "SDL_CreateGPUGraphicsPipeline".}
proc sdl_create_gpu_sampler*(dev; create_info: ptr SamplerCreateInfo): Sampler                             {.importc: "SDL_CreateGPUSampler"         .}
proc sdl_create_gpu_shader*(dev; create_info: ptr ShaderCreateInfo): Shader                                {.importc: "SDL_CreateGPUShader"          .}
proc sdl_create_gpu_texture*(dev; create_info: ptr TextureCreateInfo): Texture                             {.importc: "SDL_CreateGPUTexture"         .}
proc sdl_create_gpu_buffer*(dev; create_info: ptr BufferCreateInfo): Buffer                                {.importc: "SDL_CreateGPUBuffer"          .}
proc sdl_create_gpu_transfer_buffer*(dev; create_info: ptr TransferBufferCreateInfo): TransferBuffer       {.importc: "SDL_CreateGPUTransferBuffer"  .}

proc sdl_release_gpu_texture*(dev; tex)                                {.importc: "SDL_ReleaseGPUTexture"         .}
proc sdl_release_gpu_sampler*(dev; sampler)                            {.importc: "SDL_ReleaseGPUSampler"         .}
proc sdl_release_gpu_buffer*(dev; buf)                                 {.importc: "SDL_ReleaseGPUBuffer"          .}
proc sdl_release_gpu_transfer_buffer*(dev; trans_buf)                  {.importc: "SDL_ReleaseGPUTransferBuffer"  .}
proc sdl_release_gpu_compute_pipeline*(dev; pipeln: ComputePipeline)   {.importc: "SDL_ReleaseGPUComputePipeline" .}
proc sdl_release_gpu_shader*(dev; shader)                              {.importc: "SDL_ReleaseGPUShader"          .}
proc sdl_release_gpu_graphics_pipeline*(dev; pipeln: GraphicsPipeline) {.importc: "SDL_ReleaseGPUGraphicsPipeline".}

proc sdl_set_gpu_buffer_name*(dev; buf; text: cstring)   {.importc: "SDL_SetGPUBufferName"   .}
proc sdl_set_gpu_texture_name*(dev; tex; text: cstring)  {.importc: "SDL_SetGPUTextureName"  .}
proc sdl_insert_gpu_debug_label*(cmd_buf; text: cstring) {.importc: "SDL_InsertGPUDebugLabel".}
proc sdl_push_gpu_debug_group*(cmd_buf; name: cstring)   {.importc: "SDL_PushGPUDebugGroup"  .}
proc sdl_pop_gpu_debug_group*(cmd_buf)                   {.importc: "SDL_PopGPUDebugGroup"   .}

proc sdl_acquire_gpu_command_buffer*(dev): CommandBuffer                                        {.importc: "SDL_AcquireGPUCommandBuffer"   .}
proc sdl_push_gpu_vertex_uniform_data*(cmd_buf; slot_idx: uint32; data: pointer; len: uint32)   {.importc: "SDL_PushGPUVertexUniformData"  .}
proc sdl_push_gpu_fragment_uniform_data*(cmd_buf; slot_idx: uint32; data: pointer; len: uint32) {.importc: "SDL_PushGPUFragmentUniformData".}
proc sdl_push_gpu_compute_uniform_data*(cmd_buf; slot_idx: uint32; data: pointer; len: uint32)  {.importc: "SDL_PushGPUComputeUniformData" .}

proc sdl_begin_gpu_render_pass*(cmd_buf; cti: ptr ColourTargetInfo; ct_count: uint32; dsti: ptr DepthStencilTargetInfo): RenderPass {.importc: "SDL_BeginGPURenderPass"              .}
proc sdl_bind_gpu_graphics_pipeline*(ren_pass; pipeln: GraphicsPipeline)                                                            {.importc: "SDL_BindGPUGraphicsPipeline"         .}
proc sdl_set_gpu_viewport*(ren_pass; viewport: ptr Viewport)                                                                        {.importc: "SDL_SetGPUViewport"                  .}
proc sdl_set_gpu_scissor*(ren_pass; scissor: ptr Rect)                                                                              {.importc: "SDL_SetGPUScissor"                   .}
proc sdl_set_gpu_blend_constants*(ren_pass; blend_consts: FColour)                                                                  {.importc: "SDL_SetGPUBlendConstants"            .}
proc sdl_set_gpu_stencil_reference*(ren_pass; `ref`: uint8)                                                                         {.importc: "SDL_SetGPUStencilReference"          .}
proc sdl_bind_gpu_vertex_buffer*(ren_pass; fst_slot; binds: ptr BufferBinding; bind_count)                                          {.importc: "SDL_BindGPUVertexBuffers"            .}
proc sdl_bind_gpu_index_buffer*(ren_pass; `bind`: ptr BufferBinding; idx_elem_sz: IndexElementSize)                                 {.importc: "SDL_BindGPUIndexBuffer"              .}
proc sdl_bind_gpu_vertex_samplers*(ren_pass; fst_slot; binds: ptr TextureSamplerBinding; bind_count)                                {.importc: "SDL_BindGPUVertexSamplers"           .}
proc sdl_bind_gpu_vertex_storage_textures*(ren_pass; fst_slot; texs: ptr Texture; bind_count)                                       {.importc: "SDL_BindGPUVertexStorageTextures"    .}
proc sdl_bind_gpu_vertex_storage_buffers*(ren_pass; fst_slot; bufs: ptr Buffer; bind_count)                                         {.importc: "SDL_BindGPUVertexStorageBuffers"     .}
proc sdl_bind_gpu_fragment_samplers*(ren_pass; fst_slot; binds: ptr TextureSamplerBinding; bind_count)                              {.importc: "SDL_BindGPUFragmentSamplers"         .}
proc sdl_bind_gpu_fragment_storage_textures*(ren_pass; fst_slot; texs: ptr Texture; bind_count)                                     {.importc: "SDL_BindGPUFragmentStorageTextures"  .}
proc sdl_bind_gpu_fragment_storage_buffers*(ren_pass; fst_slot; bufs: ptr Buffer; bind_count)                                       {.importc: "SDL_BindGPUFragmentStorageBuffers"   .}
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

proc sdl_map_gpu_transfer_buffer*(dev; buf: TransferBuffer; cycle: bool): pointer {.importc: "SDL_MapGPUTransferBuffer"  .}
proc sdl_unmap_gpu_transfer_buffer*(dev; buf: TransferBuffer)                     {.importc: "SDL_UnmapGPUTransferBuffer".}

proc sdl_begin_gpu_copy_pass*(cmd_buf): CopyPass                                                               {.importc: "SDL_BeginGPUCopyPass"       .}
proc sdl_upload_to_gpu_texture*(copy_pass; src: ptr TextureTransferInfo; dst: ptr TextureRegion; cycle: bool)  {.importc: "SDL_UploadToGPUTexture"     .}
proc sdl_upload_to_gpu_buffer*(copy_pass; src: ptr TransferBufferLocation; dst: ptr BufferRegion; cycle: bool) {.importc: "SDL_UploadToGPUBuffer"      .}
proc sdl_copy_gpu_texture_to_texture*(copy_pass; src, dst: ptr TextureLocation; w, h, d: uint32; cycle: bool)  {.importc: "SDL_CopyGPUTextureToTexture".}
proc sdl_copy_gpu_buffer_to_buffer*(copy_pass; src, dst: ptr BufferLocation; sz: uint32; cycle: bool)          {.importc: "SDL_CopyGPUBufferToBuffer"  .}
proc sdl_download_from_gpu_texture*(copy_pass; src: ptr TextureRegion; dst: ptr TextureTransferInfo)           {.importc: "SDL_DownloadFromGPUTexture" .}
proc sdl_download_from_gpu_buffer*(copy_pass; src: ptr BufferRegion; dst: ptr TransferBufferLocation)          {.importc: "SDL_DownloadFromGPUBuffer"  .}
proc sdl_end_gpu_copy_pass*(copy_pass)                                                                         {.importc: "SDL_EndGPUCopyPass"         .}

proc sdl_generate_mip_maps_for_gpu_texture*(cmd_buf; tex) {.importc: "SDL_GenerateMipmapsForGPUTexture".}
proc sdl_blit_gpu_texture*(cmd_buf; info: ptr BlitInfo)   {.importc: "SDL_BlitGPUTexture"              .}

proc sdl_window_supports_gpu_swapchain_composition*(dev; win; comp: SwapchainComposition): bool         {.importc: "SDL_WindowSupportsGPUSwapchainComposition".}
proc sdl_window_supports_gpu_present_mode*(dev; win; mode: PresentMode): bool                           {.importc: "SDL_WindowSupportsGPUPresentMode"         .}
proc sdl_claim_window_for_gpu_device*(dev; win): bool                                                   {.importc: "SDL_ClaimWindowForGPUDevice"              .}
proc sdl_release_window_from_gpu_device*(dev; win)                                                      {.importc: "SDL_ReleaseWindowFromGPUDevice"           .}
proc sdl_set_gpu_swapchain_parameters*(dev; win; comp: SwapchainComposition; mode: PresentMode): bool   {.importc: "SDL_SetGPUSwapchainParameters"            .}
proc sdl_get_gpu_swapchain_texture_format*(dev; win): TextureFormat                                     {.importc: "SDL_GetGPUSwapchainTextureFormat"         .}
proc sdl_acquire_gpu_swapchain_texture*(cmd_buf; win; tex: ptr Texture; tex_w, tex_h: ptr uint32): bool {.importc: "SDL_AcquireGPUSwapchainTexture"           .}
proc sdl_submit_gpu_command_buffer*(cmd_buf): bool                                                      {.importc: "SDL_SubmitGPUCommandBuffer"               .}
proc sdl_submit_gpu_command_buffer_and_acquire_fence*(cmd_buf): Fence                                   {.importc: "SDL_SubmitGPUCommandBufferAndAcquireFence".}
proc sdl_wait_for_gpu_idle*(dev): bool                                                                  {.importc: "SDL_WaitForGPUIdle"                       .}
proc sdl_wait_for_gpu_fences*(dev; wait_all: bool; fences: Fence; fence_count: uint32): bool            {.importc: "SDL_WaitForGPUFences"                     .}
proc sdl_query_gpu_fence*(dev; fence: Fence): bool                                                      {.importc: "SDL_QueryGPUFence"                        .}
proc sdl_release_gpu_fence*(dev; fence: Fence)                                                          {.importc: "SDL_ReleaseGPUFence"                      .}

proc sdl_gpu_texture_format_texel_block_size*(fmt: TextureFormat): uint32                                        {.importc: "SDL_GPUTextureFormatTexelBlockSize".}
proc sdl_gpu_texture_supports_format*(dev; fmt: TextureFormat; kind: TextureKind; usage: TextureUsageFlag): bool {.importc: "SDL_GPUTextureSupportsFormat"      .}
proc sdl_gpu_texture_supports_sample_count*(dev; fmt: TextureFormat; cample_count: SampleCount): bool            {.importc: "SDL_GPUTextureSupportsSampleCount" .}

# TODO
when defined SdlPlatformGdk:
    proc sdl_gdk_suspend_gpu*(dev) {.importc: "SDL_GDKSuspendGPU".}
    proc sdl_gdk_resume_gpu*(dev)  {.importc: "SDL_GDKResumeGPU" .}
{.pop.}

#[ -------------------------------------------------------------------- ]#

import shadercross
export shadercross

{.push inline.}

proc destroy*(dev)                           = sdl_destroy_gpu_device dev
proc destroy*(dev; pipeln: GraphicsPipeline) = sdl_release_gpu_graphics_pipeline dev, pipeln
proc destroy*(dev; shader)                   = sdl_release_gpu_shader dev, shader
proc destroy*(dev; tex)                      = sdl_release_gpu_texture dev, tex
proc destroy*(dev; sampler)                  = sdl_release_gpu_sampler dev, sampler
proc destroy*(dev; buf)                      = sdl_release_gpu_buffer dev, buf
proc destroy*(dev; trans_buf)                = sdl_release_gpu_transfer_buffer dev, trans_buf

func viewport*(x, y, w, h, min_d, max_d: float32): Viewport =
    Viewport(x: x, y: y, w: w, h: h, min_depth: min_d, max_depth: max_d)

func vertex_input_state*(descrs: openArray[VertexBufferDescription]; attrs: openArray[VertexAttribute]): VertexInputState =
    VertexInputState(
        buf_descrs: cast[ptr UncheckedArray[VertexBufferDescription]](descrs[0].addr),
        buf_count : uint32 descrs.len,
        attrs     : cast[ptr UncheckedArray[VertexAttribute]](attrs[0].addr),
        attr_count: uint32 attrs.len
    )

func vertex_descriptor*(slot, pitch: int; input_rate: VertexInputRate; step_rate = 1): VertexBufferDescription =
    VertexBufferDescription(
        slot      : uint32 slot,
        pitch     : uint32 pitch,
        input_rate: input_rate,
        step_rate : uint32 step_rate,
    )
const vtx_descr* = vertex_descriptor

func vertex_attribute*(loc, slot: int; fmt: VertexElementFormat; offset = 0): VertexAttribute =
    VertexAttribute(
        loc   : uint32 loc,
        slot  : uint32 slot,
        fmt   : fmt,
        offset: uint32 offset,
    )
const vtx_attr* = vertex_attribute

proc create_device*(fmt_flags: ShaderFormatFlag; debug_mode: bool; name = ""): Device =
    sdl_create_gpu_device fmt_flags, debug_mode, (if name == "": nil else: cstring name)

proc create_device*(props: PropertyId): Device =
    sdl_create_gpu_device_with_properties props

proc create_graphics_pipeline*(dev; vs, fs: Shader; vtx_input_state: VertexInputState;
                               prim_kind           = primTriangleList;
                               raster_state        = RasterizerState();
                               multisample_state   = MultisampleState();
                               depth_stencil_state = DepthStencilState();
                               target_info         = GraphicsPipelineTargetInfo();
                               props               = InvalidProperty;
                               ): GraphicsPipeline =
    let ci = GraphicsPipelineCreateinfo(
        vtx_shader         : vs,
        frag_shader        : fs,
        vtx_input_state    : vtx_input_state,
        prim_kind          : prim_kind,
        raster_state       : raster_state,
        multisample_state  : multisample_state,
        depth_stencil_state: depth_stencil_state,
        target_info        : target_info,
        props              : props,
    )
    sdl_create_gpu_graphics_pipeline dev, ci.addr

proc create_shader*(dev; stage: ShaderStage; code: pointer; code_sz: int; entry = "main"; fmt = shaderFmtSpirV;
                    sampler_count, storage_tex_count, storage_buf_count, uniform_buf_count: SomeInteger = 0; props = InvalidProperty;
                    ): Shader =
    let ci = ShaderCreateInfo(
        code_sz          : uint code_sz,
        code             : code,
        entry_point      : cstring entry,
        fmt              : fmt,
        stage            : stage,
        sampler_count    : uint32 sampler_count,
        storage_tex_count: uint32 storage_tex_count,
        storage_buf_count: uint32 storage_buf_count,
        uniform_buf_count: uint32 uniform_buf_count,
        props            : props,
    )
    sdl_create_gpu_shader dev, ci.addr

# TODO: shader format and shader stage detection via file extension
proc create_shader*(dev; stage: ShaderStage; path: string; entry = "main"; fmt = shaderFmtSpirV;
                    sampler_count, storage_tex_count, storage_buf_count, uniform_buf_count: SomeNumber = 0; props = InvalidProperty;
                    ): Shader =
    let code = read_file path
    create_shader dev, stage, code[0].addr, code.len, entry, fmt, sampler_count, storage_tex_count, storage_buf_count, uniform_buf_count, props

proc create_buffer*(dev; usage: BufferUsageFlag; sz: SomeInteger; props = InvalidProperty): Buffer =
    let ci = BufferCreateInfo(
        usage: usage,
        sz   : uint32 sz,
        props: props,
    )
    sdl_create_gpu_buffer dev, ci.addr

proc create_sampler*(dev; min_filter, mag_filter = filterNearest; mip_map_mode = mipMapModeNearest;
                     addr_mode_u, addr_mode_v, addr_mode_w = addrModeRepeat; mip_lod_bias = 0'f32;
                     max_anisotropy = 1'f32; compare_op = cmpInvalid; min_lod, max_lod = 1'f32;
                     enable_anisotropy, enable_compare = false; props = InvalidProperty;
                     ): Sampler =
    let ci = SamplerCreateInfo(
        min_filter       : min_filter,
        mag_filter       : mag_filter,
        mip_map_mode     : mip_map_mode,
        addr_mode_u      : addr_mode_u,
        addr_mode_v      : addr_mode_v,
        addr_mode_w      : addr_mode_w,
        mip_lod_bias     : mip_lod_bias,
        max_anisotropy   : max_anisotropy,
        compare_op       : compare_op,
        min_lod          : min_lod,
        max_lod          : max_lod,
        enable_anisotropy: enable_anisotropy,
        enable_compare   : enable_compare,
        props            : props,
    )
    sdl_create_gpu_sampler dev, ci.addr

proc create_texture*(dev; w, h: uint32; depth_or_layer_count = 1'u32; kind = tex2D; fmt = texFmtR8G8B8A8Uint;
                     usage = texUsageGraphicsStorageRead; lvl_count = 1'u32; sample_count = sampleCount1;
                     props = InvalidProperty;
                     ): Texture =
    let ci = TextureCreateInfo(
        kind                : kind,
        fmt                 : fmt,
        usage               : usage,
        w                   : w,
        h                   : h,
        depth_or_layer_count: depth_or_layer_count,
        lvl_count           : lvl_count,
        sample_count        : sample_count,
        props               : props,
    )
    sdl_create_gpu_texture dev, ci.addr

proc create_transfer_buffer*(dev; sz: SomeInteger; usage = transferUpload; props = InvalidProperty): TransferBuffer =
    let ci = TransferBufferCreateInfo(
        usage: usage,
        sz   : uint32 sz,
        props: props,
    )
    sdl_create_gpu_transfer_buffer dev, ci.addr

proc map*(dev; buf: TransferBuffer; cycle = false): pointer =
    sdl_map_gpu_transfer_buffer(dev, buf, cycle)

proc unmap*(dev; buf: TransferBuffer) =
    sdl_unmap_gpu_transfer_buffer dev, buf

proc begin_copy_pass*(cmd_buf): CopyPass = sdl_begin_gpu_copy_pass cmd_buf
proc end_copy_pass*(copy_pass)           = sdl_end_gpu_copy_pass copy_pass

proc upload*(copy_pass; buf: TransferBuffer; px_w, px_h: SomeNumber; tex; offset, mip_lvl, layer: SomeNumber = 0;
             x, y, z: SomeNumber = 0; w: SomeNumber = px_w; h: SomeNumber = px_h; d: SomeNumber = 0; cycle = false;
             ) =
    let src = TextureTransferInfo(
        trans_buf     : buf,
        offset        : uint32 offset,
        px_per_row    : uint32 px_w,
        rows_per_layer: uint32 px_h,
    )
    let dst = TextureRegion(
        tex    : tex,
        mip_lvl: uint32 mip_lvl,
        layer  : uint32 layer,
        x: uint32 x, y: uint32 y, z: uint32 z,
        w: uint32 w, h: uint32 h, d: uint32 d,
    )
    sdl_upload_to_gpu_texture copy_pass, src.addr, dst.addr, cycle

proc upload*(copy_pass; trans_buf: TransferBuffer; buf: Buffer; sz: SomeNumber;
             trans_buf_offset, buf_offset: SomeInteger = 0; cycle = false;
             ) =
    let src = TransferBufferLocation(
        trans_buf: trans_buf,
        offset   : uint32 trans_buf_offset,
    )
    let dst = BufferRegion(
        buf   : buf,
        offset: uint32 buf_offset,
        sz    : uint32 sz,
    )
    sdl_upload_to_gpu_buffer copy_pass, src.addr, dst.addr, cycle

# proc sdl_copy_gpu_texture_to_texture*(copy_pass; src, dst: ptr TextureLocation; w, h, d: uint32; cycle: bool)
# proc sdl_copy_gpu_buffer_to_buffer*(copy_pass; src, dst: ptr BufferLocation; sz: uint32; cycle: bool)
# proc sdl_download_from_gpu_texture*(copy_pass; src: ptr TextureRegion; dst: ptr TextureTransferInfo)
# proc sdl_download_from_gpu_buffer*(copy_pass; src: ptr BufferRegion; dst: ptr TransferBufferLocation)

proc get_device_count*(): int                   = sdl_get_num_gpu_drivers()
proc get_driver*(i: int): cstring               = sdl_get_gpu_driver cint i
proc get_driver*(dev): cstring                  = sdl_get_gpu_device_driver dev
proc get_shader_formats*(dev): ShaderFormatFlag = sdl_get_gpu_shader_formats dev

proc claim_window*(dev; win): bool = sdl_claim_window_for_gpu_device dev, win

proc acquire_command_buffer*(dev): CommandBuffer = sdl_acquire_gpu_command_buffer dev
const acquire_cmd_buf* = acquire_command_buffer

proc acquire_swapchain_texture*(cmd_buf; win): tuple[tex: Texture; w, h: uint32] =
    assert sdl_acquire_gpu_swapchain_texture(cmd_buf, win, result.tex.addr, result.w.addr, result.h.addr)
    # TODO error
const acquire_swapchain* = acquire_swapchain_texture

proc submit*(cmd_buf; acquire_fence: static[bool] = false) =
    when acquire_fence:
        sdl_submit_gpu_command_buffer_and_acquire_fence cmd_buf
    else:
        assert sdl_submit_gpu_command_buffer(cmd_buf), &"Failed to submit command buffer: '{get_error()}'"

proc begin_render_pass*(cmd_buf; cti: openArray[ColourTargetInfo]; dsti: DepthStencilTargetInfo): RenderPass =
    result = sdl_begin_gpu_render_pass(cmd_buf, cti[0].addr, uint32 cti.len, dsti.addr)
proc begin_render_pass*(cmd_buf; cti: openArray[ColourTargetInfo]): RenderPass =
    result = sdl_begin_gpu_render_pass(cmd_buf, cti[0].addr, uint32 cti.len, nil)
    # TODO error

proc end_render_pass*(ren_pass) = sdl_end_gpu_render_pass ren_pass

proc `bind`*(ren_pass; pipeln: GraphicsPipeline)                                          = ren_pass.sdl_bind_gpu_graphics_pipeline pipeln
proc `bind`*(ren_pass; buf: BufferBinding; idx_elem_sz: IndexElementSize)                 = ren_pass.sdl_bind_gpu_index_buffer buf.addr, idx_elem_sz
proc `bind`*(ren_pass; fst_slot: SomeInteger; binds: openArray[TextureSamplerBinding])    = ren_pass.sdl_bind_gpu_vertex_samplers uint32 fst_slot, binds[0].addr, uint32 binds.len
proc `bind`*(ren_pass; fst_slot: SomeInteger; samplers: openArray[TextureSamplerBinding]) = ren_pass.sdl_bind_gpu_fragment_samplers uint32 fst_slot, samplers[0].addr, uint32 samplers.len
proc `bind`*(ren_pass; fst_slot: SomeInteger; bufs: openArray[BufferBinding])             = ren_pass.sdl_bind_gpu_vertex_buffer uint32 fst_slot, bufs[0].addr, uint32 bufs.len
proc `bind`*(ren_pass; fst_slot: SomeInteger; texs: openArray[Texture]; stage = shaderVertex) =
    case stage
    of shaderVertex  : ren_pass.sdl_bind_gpu_vertex_storage_textures   uint32 fst_slot, texs[0].addr, uint32 texs.len
    of shaderFragment: ren_pass.sdl_bind_gpu_fragment_storage_textures uint32 fst_slot, texs[0].addr, uint32 texs.len
proc `bind`*(ren_pass; fst_slot: SomeInteger; bufs: openArray[Buffer]; stage = shaderVertex) =
    case stage
    of shaderVertex  : ren_pass.sdl_bind_gpu_vertex_storage_buffers   uint32 fst_slot, bufs[0].addr, uint32 bufs.len
    of shaderFragment: ren_pass.sdl_bind_gpu_fragment_storage_buffers uint32 fst_slot, bufs[0].addr, uint32 bufs.len

proc draw*(ren_pass; vtx_count: int; inst_count = 1; fst_vtx, fst_inst = 0) =
    ren_pass.sdl_draw_gpu_primitives uint32 vtx_count, uint32 inst_count, uint32 fst_vtx, uint32 fst_inst
proc draw_indexed*(ren_pass; idx_count: int; inst_count = 1; fst_idx, vtx_offset, fst_inst = 0) =
    ren_pass.sdl_draw_gpu_indexed_primitives uint32 idx_count, uint32 inst_count, uint32 fst_idx, int32 vtx_offset, uint32 fst_inst
proc draw_indirect*(ren_pass; buf: Buffer; offset = 0; draw_count = 1) =
    ren_pass.sdl_draw_gpu_primitives_indirect buf, uint32 offset, uint32 draw_count
proc draw_indirect_indexed*(ren_pass; buf: Buffer; offset = 0; draw_count = 1) =
    ren_pass.sdl_draw_gpu_indexed_primitives_indirect buf, uint32 offset, uint32 draw_count

proc `viewport=`*(ren_pass; vp: Viewport)        = ren_pass.sdl_set_gpu_viewport vp.addr
proc `scissor=`*(ren_pass; scissor: Rect)        = ren_pass.sdl_set_gpu_scissor scissor.addr
proc `blend_consts=`*(ren_pass; consts: FColour) = ren_pass.sdl_set_gpu_blend_constants consts
proc `stencil_ref=`*(ren_pass; `ref`: uint8)     = ren_pass.sdl_set_gpu_stencil_reference `ref`

# `depth_target: DepthStencilTargetInfo` is left out for overload resolution to work
template render_pass*(cmd_buf; targets: openArray[ColourTargetInfo]; depth_target; body) =
    let ren_pass = begin_render_pass(cmd_buf, targets, depth_target)
    with ren_pass:
        body
    end_render_pass ren_pass
template render_pass*(cmd_buf; targets: openArray[ColourTargetInfo]; body) =
    let ren_pass = begin_render_pass(cmd_buf, targets)
    with ren_pass:
        body
    end_render_pass ren_pass

{.pop.}
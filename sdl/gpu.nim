import common, bitgen, properties
from pixels  import FColour
from surface import FlipMode

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

# extern SDL_DECLSPEC bool SDLCALL SDL_GPUSupportsShaderFormats(SDL_GPUShaderFormat format_flags, const char *name);
# extern SDL_DECLSPEC bool SDLCALL SDL_GPUSupportsProperties(SDL_PropertiesID props);
# extern SDL_DECLSPEC SDL_GPUDevice *SDLCALL SDL_CreateGPUDevice(SDL_GPUShaderFormat format_flags, bool debug_mode, const char *name);
# extern SDL_DECLSPEC SDL_GPUDevice *SDLCALL SDL_CreateGPUDeviceWithProperties(SDL_PropertiesID props);

# extern SDL_DECLSPEC void SDLCALL SDL_DestroyGPUDevice(SDL_GPUDevice *device);
# extern SDL_DECLSPEC int SDLCALL SDL_GetNumGPUDrivers(void);
# extern SDL_DECLSPEC const char * SDLCALL SDL_GetGPUDriver(int index);
# extern SDL_DECLSPEC const char * SDLCALL SDL_GetGPUDeviceDriver(SDL_GPUDevice *device);
# extern SDL_DECLSPEC SDL_GPUShaderFormat SDLCALL SDL_GetGPUShaderFormats(SDL_GPUDevice *device);
# extern SDL_DECLSPEC SDL_GPUComputePipeline *SDLCALL SDL_CreateGPUComputePipeline(SDL_GPUDevice *device, const SDL_GPUComputePipelineCreateInfo *createinfo);
# extern SDL_DECLSPEC SDL_GPUGraphicsPipeline *SDLCALL SDL_CreateGPUGraphicsPipeline(SDL_GPUDevice *device, const SDL_GPUGraphicsPipelineCreateInfo *createinfo);
# extern SDL_DECLSPEC SDL_GPUSampler *SDLCALL SDL_CreateGPUSampler(SDL_GPUDevice *device, const SDL_GPUSamplerCreateInfo *createinfo);
# extern SDL_DECLSPEC SDL_GPUShader *SDLCALL SDL_CreateGPUShader(SDL_GPUDevice *device, const SDL_GPUShaderCreateInfo *createinfo);
# extern SDL_DECLSPEC SDL_GPUTexture *SDLCALL SDL_CreateGPUTexture(SDL_GPUDevice *device, const SDL_GPUTextureCreateInfo *createinfo);
# extern SDL_DECLSPEC SDL_GPUBuffer *SDLCALL SDL_CreateGPUBuffer(SDL_GPUDevice *device,const SDL_GPUBufferCreateInfo *createinfo);
# extern SDL_DECLSPEC SDL_GPUTransferBuffer *SDLCALL SDL_CreateGPUTransferBuffer(SDL_GPUDevice *device, const SDL_GPUTransferBufferCreateInfo *createinfo);
# extern SDL_DECLSPEC void SDLCALL SDL_SetGPUBufferName(SDL_GPUDevice *device, SDL_GPUBuffer *buffer, const char *text);
# extern SDL_DECLSPEC void SDLCALL SDL_SetGPUTextureName(SDL_GPUDevice *device, SDL_GPUTexture *texture, const char *text);
# extern SDL_DECLSPEC void SDLCALL SDL_InsertGPUDebugLabel(SDL_GPUCommandBuffer *command_buffer, const char *text);
# extern SDL_DECLSPEC void SDLCALL SDL_PushGPUDebugGroup(SDL_GPUCommandBuffer *command_buffer, const char *name);
# extern SDL_DECLSPEC void SDLCALL SDL_PopGPUDebugGroup(SDL_GPUCommandBuffer *command_buffer);
# extern SDL_DECLSPEC void SDLCALL SDL_ReleaseGPUTexture(SDL_GPUDevice *device, SDL_GPUTexture *texture);
# extern SDL_DECLSPEC void SDLCALL SDL_ReleaseGPUSampler(SDL_GPUDevice *device, SDL_GPUSampler *sampler);
# extern SDL_DECLSPEC void SDLCALL SDL_ReleaseGPUBuffer(SDL_GPUDevice *device, SDL_GPUBuffer *buffer);
# extern SDL_DECLSPEC void SDLCALL SDL_ReleaseGPUTransferBuffer(SDL_GPUDevice *device, SDL_GPUTransferBuffer *transfer_buffer);
# extern SDL_DECLSPEC void SDLCALL SDL_ReleaseGPUComputePipeline(SDL_GPUDevice *device, SDL_GPUComputePipeline *compute_pipeline);
# extern SDL_DECLSPEC void SDLCALL SDL_ReleaseGPUShader(SDL_GPUDevice *device, SDL_GPUShader *shader);
# extern SDL_DECLSPEC void SDLCALL SDL_ReleaseGPUGraphicsPipeline(SDL_GPUDevice *device, SDL_GPUGraphicsPipeline *graphics_pipeline);
# extern SDL_DECLSPEC SDL_GPUCommandBuffer *SDLCALL SDL_AcquireGPUCommandBuffer(SDL_GPUDevice *device);
# extern SDL_DECLSPEC void SDLCALL SDL_PushGPUVertexUniformData(SDL_GPUCommandBuffer *command_buffer, Uint32 slot_index, const void *data, Uint32 length);
# extern SDL_DECLSPEC void SDLCALL SDL_PushGPUFragmentUniformData(SDL_GPUCommandBuffer *command_buffer, Uint32 slot_index, const void *data, Uint32 length);
# extern SDL_DECLSPEC void SDLCALL SDL_PushGPUComputeUniformData(SDL_GPUCommandBuffer *command_buffer, Uint32 slot_index, const void *data, Uint32 length);

# extern SDL_DECLSPEC SDL_GPURenderPass *SDLCALL SDL_BeginGPURenderPass(SDL_GPUCommandBuffer *command_buffer, const SDL_GPUColorTargetInfo *color_target_infos, Uint32 num_color_targets, const SDL_GPUDepthStencilTargetInfo *depth_stencil_target_info);
# extern SDL_DECLSPEC void SDLCALL SDL_BindGPUGraphicsPipeline(SDL_GPURenderPass *render_pass, SDL_GPUGraphicsPipeline *graphics_pipeline);
# extern SDL_DECLSPEC void SDLCALL SDL_SetGPUViewport(SDL_GPURenderPass *render_pass, const SDL_GPUViewport *viewport);
# extern SDL_DECLSPEC void SDLCALL SDL_SetGPUScissor(SDL_GPURenderPass *render_pass, const SDL_Rect *scissor);
# extern SDL_DECLSPEC void SDLCALL SDL_SetGPUBlendConstants(SDL_GPURenderPass *render_pass, SDL_FColor blend_constants);
# extern SDL_DECLSPEC void SDLCALL SDL_SetGPUStencilReference(SDL_GPURenderPass *render_pass, Uint8 reference);
# extern SDL_DECLSPEC void SDLCALL SDL_BindGPUVertexBuffers(SDL_GPURenderPass *render_pass, Uint32 first_slot, const SDL_GPUBufferBinding *bindings, Uint32 num_bindings);
# extern SDL_DECLSPEC void SDLCALL SDL_BindGPUIndexBuffer(SDL_GPURenderPass *render_pass, const SDL_GPUBufferBinding *binding, SDL_GPUIndexElementSize index_element_size);
# extern SDL_DECLSPEC void SDLCALL SDL_BindGPUVertexSamplers(SDL_GPURenderPass *render_pass, Uint32 first_slot, const SDL_GPUTextureSamplerBinding *texture_sampler_bindings, Uint32 num_bindings);
# extern SDL_DECLSPEC void SDLCALL SDL_BindGPUVertexStorageTextures(SDL_GPURenderPass *render_pass, Uint32 first_slot, SDL_GPUTexture *const *storage_textures, Uint32 num_bindings);
# extern SDL_DECLSPEC void SDLCALL SDL_BindGPUVertexStorageBuffers(SDL_GPURenderPass *render_pass, Uint32 first_slot, SDL_GPUBuffer *const *storage_buffers, Uint32 num_bindings);
# extern SDL_DECLSPEC void SDLCALL SDL_BindGPUFragmentSamplers(SDL_GPURenderPass *render_pass, Uint32 first_slot, const SDL_GPUTextureSamplerBinding *texture_sampler_bindings, Uint32 num_bindings);
# extern SDL_DECLSPEC void SDLCALL SDL_BindGPUFragmentStorageTextures(SDL_GPURenderPass *render_pass, Uint32 first_slot, SDL_GPUTexture *const *storage_textures, Uint32 num_bindings);
# extern SDL_DECLSPEC void SDLCALL SDL_BindGPUFragmentStorageBuffers(SDL_GPURenderPass *render_pass, Uint32 first_slot, SDL_GPUBuffer *const *storage_buffers, Uint32 num_bindings);

# extern SDL_DECLSPEC void SDLCALL SDL_DrawGPUIndexedPrimitives(SDL_GPURenderPass *render_pass, Uint32 num_indices, Uint32 num_instances, Uint32 first_index, Sint32 vertex_offset, Uint32 first_instance);
# extern SDL_DECLSPEC void SDLCALL SDL_DrawGPUPrimitives(SDL_GPURenderPass *render_pass, Uint32 num_vertices, Uint32 num_instances, Uint32 first_vertex, Uint32 first_instance);
# extern SDL_DECLSPEC void SDLCALL SDL_DrawGPUPrimitivesIndirect(SDL_GPURenderPass *render_pass, SDL_GPUBuffer *buffer, Uint32 offset, Uint32 draw_count);
# extern SDL_DECLSPEC void SDLCALL SDL_DrawGPUIndexedPrimitivesIndirect(SDL_GPURenderPass *render_pass, SDL_GPUBuffer *buffer, Uint32 offset, Uint32 draw_count);
# extern SDL_DECLSPEC void SDLCALL SDL_EndGPURenderPass(SDL_GPURenderPass *render_pass);

# extern SDL_DECLSPEC SDL_GPUComputePass *SDLCALL SDL_BeginGPUComputePass( SDL_GPUCommandBuffer *command_buffer, const SDL_GPUStorageTextureReadWriteBinding *storage_texture_bindings, Uint32 num_storage_texture_bindings, const SDL_GPUStorageBufferReadWriteBinding *storage_buffer_bindings, Uint32 num_storage_buffer_bindings);
# extern SDL_DECLSPEC void SDLCALL SDL_BindGPUComputePipeline(SDL_GPUComputePass *compute_pass, SDL_GPUComputePipeline *compute_pipeline);
# extern SDL_DECLSPEC void SDLCALL SDL_BindGPUComputeSamplers(SDL_GPUComputePass *compute_pass, Uint32 first_slot, const SDL_GPUTextureSamplerBinding *texture_sampler_bindings, Uint32 num_bindings);
# extern SDL_DECLSPEC void SDLCALL SDL_BindGPUComputeStorageTextures(SDL_GPUComputePass *compute_pass, Uint32 first_slot, SDL_GPUTexture *const *storage_textures, Uint32 num_bindings);
# extern SDL_DECLSPEC void SDLCALL SDL_BindGPUComputeStorageBuffers(SDL_GPUComputePass *compute_pass, Uint32 first_slot, SDL_GPUBuffer *const *storage_buffers, Uint32 num_bindings);
# extern SDL_DECLSPEC void SDLCALL SDL_DispatchGPUCompute(SDL_GPUComputePass *compute_pass, Uint32 groupcount_x, Uint32 groupcount_y, Uint32 groupcount_z);
# extern SDL_DECLSPEC void SDLCALL SDL_DispatchGPUComputeIndirect(SDL_GPUComputePass *compute_pass, SDL_GPUBuffer *buffer, Uint32 offset);
# extern SDL_DECLSPEC void SDLCALL SDL_EndGPUComputePass(SDL_GPUComputePass *compute_pass);

# extern SDL_DECLSPEC void *SDLCALL SDL_MapGPUTransferBuffer(SDL_GPUDevice *device, SDL_GPUTransferBuffer *transfer_buffer, bool cycle);
# extern SDL_DECLSPEC void SDLCALL SDL_UnmapGPUTransferBuffer(SDL_GPUDevice *device, SDL_GPUTransferBuffer *transfer_buffer);

# extern SDL_DECLSPEC SDL_GPUCopyPass *SDLCALL SDL_BeginGPUCopyPass(SDL_GPUCommandBuffer *command_buffer);
# extern SDL_DECLSPEC void SDLCALL SDL_UploadToGPUTexture(SDL_GPUCopyPass *copy_pass, const SDL_GPUTextureTransferInfo *source, const SDL_GPUTextureRegion *destination, bool cycle);

# extern SDL_DECLSPEC void SDLCALL SDL_UploadToGPUBuffer(SDL_GPUCopyPass *copy_pass, const SDL_GPUTransferBufferLocation *source, const SDL_GPUBufferRegion *destination, bool cycle);
# extern SDL_DECLSPEC void SDLCALL SDL_CopyGPUTextureToTexture(SDL_GPUCopyPass *copy_pass, const SDL_GPUTextureLocation *source, const SDL_GPUTextureLocation *destination, Uint32 w, Uint32 h, Uint32 d, bool cycle);

# extern SDL_DECLSPEC void SDLCALL SDL_CopyGPUBufferToBuffer(SDL_GPUCopyPass *copy_pass, const SDL_GPUBufferLocation *source, const SDL_GPUBufferLocation *destination, Uint32 size, bool cycle);
# extern SDL_DECLSPEC void SDLCALL SDL_DownloadFromGPUTexture(SDL_GPUCopyPass *copy_pass, const SDL_GPUTextureRegion *source, const SDL_GPUTextureTransferInfo *destination);
# extern SDL_DECLSPEC void SDLCALL SDL_DownloadFromGPUBuffer(SDL_GPUCopyPass *copy_pass, const SDL_GPUBufferRegion *source, const SDL_GPUTransferBufferLocation *destination);
# extern SDL_DECLSPEC void SDLCALL SDL_EndGPUCopyPass(SDL_GPUCopyPass *copy_pass);
# extern SDL_DECLSPEC void SDLCALL SDL_GenerateMipmapsForGPUTexture(SDL_GPUCommandBuffer *command_buffer, SDL_GPUTexture *texture);
# extern SDL_DECLSPEC void SDLCALL SDL_BlitGPUTexture(SDL_GPUCommandBuffer *command_buffer, const SDL_GPUBlitInfo *info);

# extern SDL_DECLSPEC bool SDLCALL SDL_WindowSupportsGPUSwapchainComposition(SDL_GPUDevice *device, SDL_Window *window, SDL_GPUSwapchainComposition swapchain_composition);
# extern SDL_DECLSPEC bool SDLCALL SDL_WindowSupportsGPUPresentMode(SDL_GPUDevice *device, SDL_Window *window, SDL_GPUPresentMode present_mode);
# extern SDL_DECLSPEC bool SDLCALL SDL_ClaimWindowForGPUDevice(SDL_GPUDevice *device, SDL_Window *window);
# extern SDL_DECLSPEC void SDLCALL SDL_ReleaseWindowFromGPUDevice(SDL_GPUDevice *device, SDL_Window *window);
# extern SDL_DECLSPEC bool SDLCALL SDL_SetGPUSwapchainParameters(SDL_GPUDevice *device, SDL_Window *window, SDL_GPUSwapchainComposition swapchain_composition, SDL_GPUPresentMode present_mode);
# extern SDL_DECLSPEC SDL_GPUTextureFormat SDLCALL SDL_GetGPUSwapchainTextureFormat(SDL_GPUDevice *device, SDL_Window *window);
# extern SDL_DECLSPEC bool SDLCALL SDL_AcquireGPUSwapchainTexture(SDL_GPUCommandBuffer *command_buffer, SDL_Window *window, SDL_GPUTexture **swapchain_texture, Uint32 *swapchain_texture_width, Uint32 *swapchain_texture_height);
# extern SDL_DECLSPEC bool SDLCALL SDL_SubmitGPUCommandBuffer(SDL_GPUCommandBuffer *command_buffer);
# extern SDL_DECLSPEC SDL_GPUFence *SDLCALL SDL_SubmitGPUCommandBufferAndAcquireFence(SDL_GPUCommandBuffer *command_buffer);
# extern SDL_DECLSPEC bool SDLCALL SDL_WaitForGPUIdle(SDL_GPUDevice *device);
# extern SDL_DECLSPEC bool SDLCALL SDL_WaitForGPUFences(SDL_GPUDevice *device, bool wait_all, SDL_GPUFence *const *fences, Uint32 num_fences);
# extern SDL_DECLSPEC bool SDLCALL SDL_QueryGPUFence(SDL_GPUDevice *device, SDL_GPUFence *fence);
# extern SDL_DECLSPEC void SDLCALL SDL_ReleaseGPUFence(SDL_GPUDevice *device, SDL_GPUFence *fence);

# extern SDL_DECLSPEC Uint32 SDLCALL SDL_GPUTextureFormatTexelBlockSize(SDL_GPUTextureFormat format);
# extern SDL_DECLSPEC bool SDLCALL SDL_GPUTextureSupportsFormat(SDL_GPUDevice *device, SDL_GPUTextureFormat format, SDL_GPUTextureType type, SDL_GPUTextureUsageFlags usage);
# extern SDL_DECLSPEC bool SDLCALL SDL_GPUTextureSupportsSampleCount(SDL_GPUDevice *device, SDL_GPUTextureFormat format, SDL_GPUSampleCount sample_count);

# #ifdef SDL_PLATFORM_GDK
# extern SDL_DECLSPEC void SDLCALL SDL_GDKSuspendGPU(SDL_GPUDevice *device);
# extern SDL_DECLSPEC void SDLCALL SDL_GDKResumeGPU(SDL_GPUDevice *device);
# #endif /* SDL_PLATFORM_GDK */

import std/options, common, bitgen, properties, pixels
from rect    import Rect
from surface import FlipMode
from video   import Window

# TODO: create separate kinds for buffers

type TextureUsageFlag* = distinct uint32
TextureUsageFlag.gen_bit_ops(
    tufSampler           , tufColourTarget       , tufDepthStencilTarget                 , tufGraphicsStorageRead,
    tufComputeStorageRead, tufComputeStorageWrite, tufComputeStorageSimultaneousReadWrite,
)

type BufferUsageFlag* = distinct uint32
BufferUsageFlag.gen_bit_ops(
    bufVertex            , bufIndex              , bufIndirect, bufGraphicsStorage,
    bufComputeStorageRead, bufComputeStorageWrite,
)

type ShaderFormatFlag* = distinct uint32
ShaderFormatFlag.gen_bit_ops(
    sffPrivate, sffSpirV   , sffDxBc, sffDxIl,
    sffMsl    , sffMetalLib,
)
const sfFlagInvalid* = ShaderFormatFlag 0

type ColourComponentFlag* = distinct uint8
ColourComponentFlag.gen_bit_ops ccfR, ccfG, ccfB, ccfA
const ccfNone* = ColourComponentFlag 0
const ccfRgba* = ccfR or ccfG or ccfB or ccfA

type
    PrimitiveKind* {.size: sizeof(cint).} = enum
        pkTriangleList
        pkTriangleStrip
        pkLineList
        pkLineStrip
        pkPointList

    LoadOp* {.size: sizeof(cint).} = enum
        loLoad
        loClear
        loDontCare

    StoreOp* {.size: sizeof(cint).} = enum
        soStore
        soDontCare
        soResolve
        soResolveAndStore

    IndexElementSize* {.size: sizeof(cint).} = enum
        ies16
        ies32

    TextureFormat* {.size: sizeof(cint).} = enum
        tfInvalid

        tfA8UNorm
        tfR8UNorm
        tfR8G8UNorm
        tfR8G8B8A8UNorm
        tfR16UNorm
        tfR16G16UNorm
        tfR16G16B16A16UNorm
        tfR10G10B10A2UNorm
        tfB5G6R5UNorm
        tfB5G5R5A1UNorm
        tfB4G4R4A4UNorm
        tfB8G8R8A8UNorm

        tfBc1RgbaUNorm
        tfBc2RgbaUNorm
        tfBc3RgbaUNorm
        tfBc4RUNorm
        tfBc5RgUNorm
        tfBc7RgbaUNorm
        tfBc6HRgbFloat
        tfBc6HRgbUFloat

        tfR8SNorm
        tfR8G8SNorm
        tfR8G8B8A8SNorm
        tfR16SNorm
        tfR16G16SNorm
        tfR16G16B16A16SNorm

        tfR16Float
        tfR16G16Float
        tfR16G16B16A16Float
        tfR32Float
        tfR32G32Float
        tfR32G32B32A32Float
        tfR11G11B10UFloat

        tfR8UInt
        tfR8G8UInt
        tfR8G8B8A8UInt
        tfR16UInt
        tfR16G16UInt
        tfR16G16B16A16UInt
        tfR32UInt
        tfR32G32UInt
        tfR32G32B32A32UInt

        tfR8Int
        tfR8G8Int
        tfR8G8B8A8Int
        tfR16Int
        tfR16G16Int
        tfR16G16B16A16Int
        tfR32Int
        tfR32G32Int
        tfR32G32B32A32Int

        tfR8G8B8A8UNormSrgb
        tfB8G8R8A8UNormSrgb

        tfBc1RgbaUNormSrgb
        tfBc2RgbaUNormSrgb
        tfBc3RgbaUNormSrgb
        tfBc7RgbaUNormSrgb

        tfD16UNorm
        tfD24UNorm
        tfD32Float
        tfD24UNormS8UInt
        tfD32FloatS8UInt

        tfAstc4x4UNorm
        tfAstc5x4UNorm
        tfAstc5x5UNorm
        tfAstc6x5UNorm
        tfAstc6x6UNorm
        tfAstc8x5UNorm
        tfAstc8x6UNorm
        tfAstc8x8UNorm
        tfAstc10x5UNorm
        tfAstc10x6UNorm
        tfAstc10x8UNorm
        tfAstc10x10UNorm
        tfAstc12x10UNorm
        tfAstc12x12UNorm

        tfAstc4x4UNormSrgb
        tfAstc5x4UNormSrgb
        tfAstc5x5UNormSrgb
        tfAstc6x5UNormSrgb
        tfAstc6x6UNormSrgb
        tfAstc8x5UNormSrgb
        tfAstc8x6UNormSrgb
        tfAstc8x8UNormSrgb
        tfAstc10x5UNormSrgb
        tfAstc10x6UNormSrgb
        tfAstc10x8UNormSrgb
        tfAstc10x10UNormSrgb
        tfAstc12x10UNormSrgb
        tfAstc12x12UNormSrgb

        tfAstc4x4Float
        tfAstc5x4Float
        tfAstc5x5Float
        tfAstc6x5Float
        tfAstc6x6Float
        tfAstc8x5Float
        tfAstc8x6Float
        tfAstc8x8Float
        tfAstc10x5Float
        tfAstc10x6Float
        tfAstc10x8Float
        tfAstc10x10Float
        tfAstc12x10Float
        tfAstc12x12Float

    TextureKind* {.size: sizeof(cint).} = enum
        tk2D
        tk2DArray
        tk3D
        tkCube
        tkCubeArray

    SampleCount* {.size: sizeof(cint).} = enum
        sc1
        sc2
        sc4
        sc8

    CubeMapFace* {.size: sizeof(cint).} = enum
        cmfPositiveX
        cmfNegativeX
        cmfPositiveY
        cmfNegativeY
        cmfPositiveZ
        cmfNegativeZ

    TransferBufferUsage* {.size: sizeof(cint).} = enum
        tbuUpload
        tbuDownload

    ShaderStage* {.size: sizeof(cint).} = enum
        ssVertex
        ssFragment

    VertexElementFormat* {.size: sizeof(cint).} = enum
        vefInvalid
        vefInt
        vefInt2
        vefInt3
        vefInt4
        vefUInt
        vefUInt2
        vefUInt3
        vefUInt4
        vefFloat
        vefFloat2
        vefFloat3
        vefFloat4
        vefByte2
        vefByte4
        vefUByte2
        vefUByte4
        vefByte2Norm
        vefByte4Norm
        vefUByte2Norm
        vefUByte4Norm
        vefShort2
        vefShort4
        vefUShort2
        vefUShort4
        vefShort2Norm
        vefShort4Norm
        vefUShort2Norm
        vefUShort4Norm
        vefHalf2
        vefHalf4

    VertexInputRate* {.size: sizeof(cint).} = enum
        virVertex
        virInstance

    FillMode* {.size: sizeof(cint).} = enum
        fmFill
        fmLine

    CullMode* {.size: sizeof(cint).} = enum
        cmNone
        cmFront
        cmBack

    FrontFace* {.size: sizeof(cint).} = enum
        ffCcw
        ffCw

    CompareOp* {.size: sizeof(cint).} = enum
        coInvalid
        coNever
        coLess
        coEqual
        coLessOrEqual
        coGreater
        coNotEqual
        coGreaterOrEqual
        coAlways

    StencilOp* {.size: sizeof(cint).} = enum
        soInvalid
        soKeep
        soZero
        soReplace
        soIncrAndClamp
        soDecrAndClamp
        soInvert
        soIncrAndWrap
        soDecrAndWrap

    BlendOp* {.size: sizeof(cint).} = enum
        boInvalid
        boAdd
        boSub
        boRevSub
        boMin
        boMax

    BlendFactor* {.size: sizeof(cint).} = enum
        bfInvalid
        bfZero
        bfOne
        bfSrcColour
        bfOneMinusSrcColour
        bfDstColour
        bfOneMinusDstColour
        bfSrcAlpha
        bfOneMinusAlpha
        bfDstAlpha
        bfOneMinusDstAlpha
        bfConstColour
        bfOneMinusConstColour
        bfSrcAlphaSaturate

    Filter* {.size: sizeof(cint).} = enum
        fNearest
        fLinear

    SamplerMipmapMode* {.size: sizeof(cint).} = enum
        smmNearest
        smmLinear

    SamplerAddressMode* {.size: sizeof(cint).} = enum
        samRepeat
        samMirroredRepeat
        samClampToEdge

    PresentMode* {.size: sizeof(cint).} = enum
        pmVsync
        pmImmediate
        pmMailbox

    SwapchainComposition* {.size: sizeof(cint).} = enum
        scSdr
        scSdrLinear
        scHdrExtendedLinear
        scHdr10St2084

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
        vtx_cnt* : uint32
        inst_cnt*: uint32
        fst_vtx* : uint32
        fst_inst*: uint32

    IndexedIndirectDrawCommand* = object
        idx_cnt*   : uint32
        inst_cnt*  : uint32
        fst_idx*   : uint32
        vtx_offset*: int32
        fst_inst*  : uint32

    IndirectDispatchCommand* = object
        group_cnt_x*: uint32
        group_cnt_y*: uint32
        group_cnt_z*: uint32

    SamplerCreateInfo* = object
        min_filter*       : Filter
        mag_filter*       : Filter
        mip_map_mode*     : SamplerMipmapMode
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
        buf_descrs*: ptr VertexBufferDescription
        buf_cnt*   : uint32
        attrs*     : ptr VertexAttribute
        attr_cnt*  : uint32

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
        code_sz*        : uint
        code*           : pointer
        entry_point*    : cstring
        fmt*            : ShaderFormatFlag
        stage*          : ShaderStage
        sampler_cnt*    : uint32
        storage_tex_cnt*: uint32
        storage_buf_cnt*: uint32
        uniform_buf_cnt*: uint32
        props*          : PropertyId

    TextureCreateInfo* = object
        kind*              : TextureKind
        fmt*               : TextureFormat
        usage*             : TextureUsageFlag
        w*, h*             : uint32
        depth_or_layer_cnt*: uint32
        lvl_cnt*           : uint32
        sample_cnt*        : SampleCount
        props*             : PropertyId

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
        sample_cnt* : SampleCount
        sample_mask*: uint32
        enable_mask*: bool
        _           : array[3, byte]

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
        colour_target_descrs*    : ptr ColourTargetDescription
        colour_target_cnt*       : uint32
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
        code_sz*                  : uint
        code*                     : pointer
        entry_point*              : cstring
        fmt*                      : ShaderFormatFlag
        sampler_cnt*              : uint32
        readonly_storage_tex_cnt* : uint32
        readonly_storage_buf_cnt* : uint32
        readwrite_storage_tex_cnt*: uint32
        readwrite_storage_buf_cnt*: uint32
        uniform_buf_cnt*          : uint32
        thread_cnt_x*             : uint32
        thread_cnt_y*             : uint32
        thread_cnt_z*             : uint32
        props*                    : PropertyId

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

func viewport*(x, y, w, h, min_d, max_d: float32): Viewport =
    Viewport(x: x, y: y, w: w, h: h, min_depth: min_d, max_depth: max_d)

func vertex_input_state*(descrs: openArray[VertexBufferDescription];
                         attrs : openArray[VertexAttribute];
                         ): VertexInputState =
    VertexInputState(
        buf_descrs: (if descrs.len > 0: descrs[0].addr else: nil),
        buf_cnt   : uint32 descrs.len,
        attrs     : (if attrs.len > 0: attrs[0].addr else: nil),
        attr_cnt  : uint32 attrs.len,
    )

func vertex_descriptor*(slot      : SomeInteger;
                        pitch     : SomeInteger;
                        input_rate: VertexInputRate;
                        step_rate : SomeInteger = 0;
                        ): VertexBufferDescription =
    VertexBufferDescription(
        slot      : uint32 slot,
        pitch     : uint32 pitch,
        input_rate: input_rate,
        step_rate : uint32 step_rate,
    )

func vertex_attribute*(loc   : SomeInteger;
                       slot  : SomeInteger;
                       fmt   : VertexElementFormat;
                       offset: SomeInteger;
                       ): VertexAttribute =
    VertexAttribute(
        loc   : uint32 loc,
        slot  : uint32 slot,
        fmt   : fmt,
        offset: uint32 offset,
    )

func vtx_descr*(slot      : SomeInteger;
                pitch     : SomeInteger;
                input_rate: VertexInputRate;
                step_rate : SomeInteger = 0;
                ): VertexBufferDescription =
    vertex_descriptor slot, pitch, input_rate, step_rate

func vtx_attr*(loc   : SomeInteger;
               slot  : SomeInteger;
               fmt   : VertexElementFormat;
               offset: SomeInteger;
               ): VertexAttribute =
    vertex_attribute loc, slot, fmt, offset

#[ -------------------------------------------------------------------- ]#

using
    dev           : Device
    win           : Window
    gfx_pipeln    : GraphicsPipeline
    compute_pipeln: ComputePipeline
    buf           : Buffer
    trans_buf     : TransferBuffer
    cmd_buf       : CommandBuffer

    ren_pass    : RenderPass
    compute_pass: ComputePass
    copy_pass   : CopyPass

    tex     : Texture
    tex_fmt : TextureFormat
    sampler : Sampler
    shader  : Shader
    fst_slot: uint32
    bind_cnt: uint32

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

proc sdl_release_gpu_texture*(dev; tex)                     {.importc: "SDL_ReleaseGPUTexture"         .}
proc sdl_release_gpu_sampler*(dev; sampler)                 {.importc: "SDL_ReleaseGPUSampler"         .}
proc sdl_release_gpu_buffer*(dev; buf)                      {.importc: "SDL_ReleaseGPUBuffer"          .}
proc sdl_release_gpu_transfer_buffer*(dev; trans_buf)       {.importc: "SDL_ReleaseGPUTransferBuffer"  .}
proc sdl_release_gpu_compute_pipeline*(dev; compute_pipeln) {.importc: "SDL_ReleaseGPUComputePipeline" .}
proc sdl_release_gpu_shader*(dev; shader)                   {.importc: "SDL_ReleaseGPUShader"          .}
proc sdl_release_gpu_graphics_pipeline*(dev; gfx_pipeln)    {.importc: "SDL_ReleaseGPUGraphicsPipeline".}

proc sdl_set_gpu_buffer_name*(dev; buf; text: cstring)   {.importc: "SDL_SetGPUBufferName"   .}
proc sdl_set_gpu_texture_name*(dev; tex; text: cstring)  {.importc: "SDL_SetGPUTextureName"  .}
proc sdl_insert_gpu_debug_label*(cmd_buf; text: cstring) {.importc: "SDL_InsertGPUDebugLabel".}
proc sdl_push_gpu_debug_group*(cmd_buf; name: cstring)   {.importc: "SDL_PushGPUDebugGroup"  .}
proc sdl_pop_gpu_debug_group*(cmd_buf)                   {.importc: "SDL_PopGPUDebugGroup"   .}

proc sdl_acquire_gpu_command_buffer*(dev): CommandBuffer                                        {.importc: "SDL_AcquireGPUCommandBuffer"   .}
proc sdl_push_gpu_vertex_uniform_data*(cmd_buf; slot_idx: uint32; data: pointer; len: uint32)   {.importc: "SDL_PushGPUVertexUniformData"  .}
proc sdl_push_gpu_fragment_uniform_data*(cmd_buf; slot_idx: uint32; data: pointer; len: uint32) {.importc: "SDL_PushGPUFragmentUniformData".}
proc sdl_push_gpu_compute_uniform_data*(cmd_buf; slot_idx: uint32; data: pointer; len: uint32)  {.importc: "SDL_PushGPUComputeUniformData" .}

using dsti: ptr DepthStencilTargetInfo
proc sdl_begin_gpu_render_pass*(cmd_buf; cti: ptr ColourTargetInfo; ct_cnt: uint32; dsti): RenderPass                    {.importc: "SDL_BeginGPURenderPass"              .}
proc sdl_bind_gpu_graphics_pipeline*(ren_pass; gfx_pipeln)                                                               {.importc: "SDL_BindGPUGraphicsPipeline"         .}
proc sdl_set_gpu_viewport*(ren_pass; viewport: ptr Viewport)                                                             {.importc: "SDL_SetGPUViewport"                  .}
proc sdl_set_gpu_scissor*(ren_pass; scissor: ptr Rect)                                                                   {.importc: "SDL_SetGPUScissor"                   .}
proc sdl_set_gpu_blend_constants*(ren_pass; blend_consts: FColour)                                                       {.importc: "SDL_SetGPUBlendConstants"            .}
proc sdl_set_gpu_stencil_reference*(ren_pass; `ref`: uint8)                                                              {.importc: "SDL_SetGPUStencilReference"          .}
proc sdl_bind_gpu_vertex_buffer*(ren_pass; fst_slot; binds: ptr BufferBinding; bind_cnt)                                 {.importc: "SDL_BindGPUVertexBuffers"            .}
proc sdl_bind_gpu_index_buffer*(ren_pass; `bind`: ptr BufferBinding; idx_elem_sz: IndexElementSize)                      {.importc: "SDL_BindGPUIndexBuffer"              .}
proc sdl_bind_gpu_vertex_samplers*(ren_pass; fst_slot; binds: ptr TextureSamplerBinding; bind_cnt)                       {.importc: "SDL_BindGPUVertexSamplers"           .}
proc sdl_bind_gpu_vertex_storage_textures*(ren_pass; fst_slot; texs: ptr Texture; bind_cnt)                              {.importc: "SDL_BindGPUVertexStorageTextures"    .}
proc sdl_bind_gpu_vertex_storage_buffers*(ren_pass; fst_slot; bufs: ptr Buffer; bind_cnt)                                {.importc: "SDL_BindGPUVertexStorageBuffers"     .}
proc sdl_bind_gpu_fragment_samplers*(ren_pass; fst_slot; binds: ptr TextureSamplerBinding; bind_cnt)                     {.importc: "SDL_BindGPUFragmentSamplers"         .}
proc sdl_bind_gpu_fragment_storage_textures*(ren_pass; fst_slot; texs: ptr Texture; bind_cnt)                            {.importc: "SDL_BindGPUFragmentStorageTextures"  .}
proc sdl_bind_gpu_fragment_storage_buffers*(ren_pass; fst_slot; bufs: ptr Buffer; bind_cnt)                              {.importc: "SDL_BindGPUFragmentStorageBuffers"   .}
proc sdl_draw_gpu_indexed_primitives*(ren_pass; idx_cnt, inst_cnt, fst_idx: uint32; vtx_offset: int32; fst_inst: uint32) {.importc: "SDL_DrawGPUIndexedPrimitives"        .}
proc sdl_draw_gpu_primitives*(ren_pass; vtx_cnt, inst_cnt, fst_vtx, fst_inst: uint32)                                    {.importc: "SDL_DrawGPUPrimitives"               .}
proc sdl_draw_gpu_primitives_indirect*(ren_pass; buf: Buffer; offset, draw_cnt: uint32)                                  {.importc: "SDL_DrawGPUPrimitivesIndirect"       .}
proc sdl_draw_gpu_indexed_primitives_indirect*(ren_pass; buf: Buffer; offset, draw_cnt: uint32)                          {.importc: "SDL_DrawGPUIndexedPrimitivesIndirect".}
proc sdl_end_gpu_render_pass*(ren_pass)                                                                                  {.importc: "SDL_EndGPURenderPass"                .}

using
    stb: ptr StorageTextureReadWriteBinding
    sbb: ptr StorageBufferReadWriteBinding
proc sdl_begin_gpu_compute_pass*(cmd_buf; stb; stb_cnt: uint32; sbb; sbb_cnt: uint32): ComputePass              {.importc: "SDL_BeginGPUComputePass"          .}
proc sdl_bind_gpu_compute_pipeline*(compute_pass; compute_pipeln)                                               {.importc: "SDL_BindGPUComputePipeline"       .}
proc sdl_bind_gpu_compute_samplers*(compute_pass; fst_slot; binds: ptr TextureSamplerBinding; bind_cnt: uint32) {.importc: "SDL_BindGPUComputeSamplers"       .}
proc sdl_bind_gpu_compute_storage_textures*(compute_pass; fst_slot; texs: ptr Texture; tex_cnt: uint32)         {.importc: "SDL_BindGPUComputeStorageTextures".}
proc sdl_bind_gpu_compute_storage_buffers*(compute_pass; fst_slot; bufs: ptr Buffer; buf_cnt: uint32)           {.importc: "SDL_BindGPUComputeStorageBuffers" .}
proc sdl_dispatch_gpu_compute*(compute_pass; group_cnt_x, group_cnt_y, group_cnt_z: uint32)                     {.importc: "SDL_DispatchGPUCompute"           .}
proc sdl_dispatch_gpu_compute_indirect*(compute_pass; buf: Buffer; offset: uint32)                              {.importc: "SDL_DispatchGPUComputeIndirect"   .}
proc sdl_end_gpu_compute_pass*(compute_pass)                                                                    {.importc: "SDL_EndGPUComputePass"            .}

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

proc sdl_window_supports_gpu_swapchain_composition*(dev; win; comp: SwapchainComposition): bool          {.importc: "SDL_WindowSupportsGPUSwapchainComposition".}
proc sdl_window_supports_gpu_present_mode*(dev; win; mode: PresentMode): bool                            {.importc: "SDL_WindowSupportsGPUPresentMode"         .}
proc sdl_claim_window_for_gpu_device*(dev; win): bool                                                    {.importc: "SDL_ClaimWindowForGPUDevice"              .}
proc sdl_release_window_from_gpu_device*(dev; win)                                                       {.importc: "SDL_ReleaseWindowFromGPUDevice"           .}
proc sdl_set_gpu_swapchain_parameters*(dev; win; comp: SwapchainComposition; mode: PresentMode): bool    {.importc: "SDL_SetGPUSwapchainParameters"            .}
proc sdl_get_gpu_swapchain_texture_format*(dev; win): TextureFormat                                      {.importc: "SDL_GetGPUSwapchainTextureFormat"         .}
proc sdl_acquire_gpu_swapchain_texture*(cmd_buf; win; tex: ptr Texture; tex_w, tex_h: ptr uint32): bool  {.importc: "SDL_AcquireGPUSwapchainTexture"           .}
proc sdl_set_gpu_allowed_frames_in_flight*(dev; allowed_fif: uint32): bool                               {.importc: "SDL_SetGPUAllowedFramesInFlight"          .}
proc sdl_wait_for_gpu_swapchain*(dev; win): bool                                                         {.importc: "SDL_WaitForGPUSwapchain"                  .}
proc sdl_wait_and_acquire_gpu_swapchain_texture*(cmd_buf; win; tex: ptr Texture; w, h: ptr uint32): bool {.importc: "SDL_WaitAndAcquireGPUSwapchainTexture"    .}
proc sdl_submit_gpu_command_buffer*(cmd_buf): bool                                                       {.importc: "SDL_SubmitGPUCommandBuffer"               .}
proc sdl_submit_gpu_command_buffer_and_acquire_fence*(cmd_buf): Fence                                    {.importc: "SDL_SubmitGPUCommandBufferAndAcquireFence".}
proc sdl_cancel_gpu_command_buffer*(cmd_buf): bool                                                       {.importc: "SDL_CancelGPUCommandBuffer"               .}
proc sdl_wait_for_gpu_idle*(dev): bool                                                                   {.importc: "SDL_WaitForGPUIdle"                       .}
proc sdl_wait_for_gpu_fences*(dev; wait_all: bool; fences: ptr Fence; fence_cnt: uint32): bool           {.importc: "SDL_WaitForGPUFences"                     .}
proc sdl_query_gpu_fence*(dev; fence: Fence): bool                                                       {.importc: "SDL_QueryGPUFence"                        .}
proc sdl_release_gpu_fence*(dev; fence: Fence)                                                           {.importc: "SDL_ReleaseGPUFence"                      .}

proc sdl_gpu_texture_format_texel_block_size*(tex_fmt): uint32                                        {.importc: "SDL_GPUTextureFormatTexelBlockSize".}
proc sdl_gpu_texture_supports_format*(dev; tex_fmt; kind: TextureKind; usage: TextureUsageFlag): bool {.importc: "SDL_GPUTextureSupportsFormat"      .}
proc sdl_gpu_texture_supports_sample_cnt*(dev; tex_fmt; cample_cnt: SampleCount): bool                {.importc: "SDL_GPUTextureSupportsSampleCount" .}
proc sdl_calculate_gpu_texture_format_size*(tex_fmt; w, h, depth_or_layer_count: uint32): uint32      {.importc: "SDL_CalculateGPUTextureFormatSize" .}

# TODO
when defined SdlPlatformGdk:
    proc sdl_gdk_suspend_gpu*(dev) {.importc: "SDL_GDKSuspendGPU".}
    proc sdl_gdk_resume_gpu*(dev)  {.importc: "SDL_GDKResumeGPU" .}
{.pop.}


#[ -------------------------------------------------------------------- ]#

{.push inline.}

proc get_device_cnt*(): int                     = int sdl_get_num_gpu_drivers()
proc get_driver*(i: SomeInteger): cstring       = sdl_get_gpu_driver cint i
proc get_driver*(dev): cstring                  = sdl_get_gpu_device_driver dev
proc get_shader_formats*(dev): ShaderFormatFlag = sdl_get_gpu_shader_formats dev

proc set_frames_in_flight*(dev; cnt: range[1..3]): bool {.discardable.} =
    result = dev.sdl_set_gpu_allowed_frames_in_flight uint32 cnt
    sdl_assert result, &"Failed to set GPU device frames-in-flight to {cnt}: '{get_error()}'"

proc swapchain_texture_format*(dev; win): TextureFormat                               = sdl_get_gpu_swapchain_texture_format dev, win
proc supports_swapchain_composition*(dev; win; comp: SwapchainComposition): bool      = sdl_window_supports_gpu_swapchain_composition dev, win, comp
proc supports_present_mode*(dev; win; mode: PresentMode): bool                        = sdl_window_supports_gpu_present_mode dev, win, mode
proc supports_format*(dev; tex_fmt; kind: TextureKind; usage: TextureUsageFlag): bool = sdl_gpu_texture_supports_format dev, tex_fmt, kind, usage
proc supports_sample_cnt*(dev; tex_fmt; cnt: SampleCount): bool                       = sdl_gpu_texture_supports_sample_cnt dev, tex_fmt, cnt
proc set_swapchain_params*(dev; win; comp: SwapchainComposition; mode: PresentMode): bool {.discardable.} =
    result = sdl_set_gpu_swapchain_parameters(dev, win, comp, mode)
    sdl_assert result, &"Failed to set GPU swapchain parameters ({comp}, {mode})"
const swapchain_tex_fmt* = swapchain_texture_format
const supports_comp*     = supports_swapchain_composition
const supports_mode*     = supports_present_mode
const supports_fmt*      = supports_format

proc block_size*(tex_fmt): uint32 = sdl_gpu_texture_format_texel_block_size tex_fmt
const block_sz* = block_size

proc create_device*(fmt_flags: ShaderFormatFlag; debug_mode: bool; name = ""): Device =
    result = sdl_create_gpu_device(fmt_flags, debug_mode, (if name == "": nil else: cstring name))
    sdl_assert result, &"Failed to create GPU device: '{get_error()}'"
proc create_device*(props: PropertyId): Device =
    result = sdl_create_gpu_device_with_properties props
    sdl_assert result, &"Failed to create GPU device: '{get_error()}'"

proc create_graphics_pipeline*(dev; vs, fs: Shader; vtx_input_state: VertexInputState;
                               prim_kind           = pkTriangleList;
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
    result = sdl_create_gpu_graphics_pipeline(dev, ci.addr)
    sdl_assert result, &"Failed to create graphics pipeline: '{get_error()}'"

proc create_compute_pipeline*(dev; code: string; thread_cnt: array[3, SomeInteger];
                              entry = "main";
                              fmt   = sffSpirV;
                              props = InvalidProperty;
                              sampler_cnt    : SomeInteger = 0;
                              r_tex_cnt      : SomeInteger = 0;
                              r_buf_cnt      : SomeInteger = 0;
                              rw_tex_cnt     : SomeInteger = 0;
                              rw_buf_cnt     : SomeInteger = 0;
                              uniform_buf_cnt: SomeInteger = 0;
                              ): ComputePipeline =
    let ci = ComputePipelineCreateInfo(
        code_sz                  : uint32 code.len,
        code                     : code[0].addr,
        entry_point              : cstring entry,
        fmt                      : fmt,
        sampler_cnt              : uint32 sampler_cnt,
        readonly_storage_tex_cnt : uint32 r_tex_cnt,
        readonly_storage_buf_cnt : uint32 r_buf_cnt,
        readwrite_storage_tex_cnt: uint32 rw_tex_cnt,
        readwrite_storage_buf_cnt: uint32 rw_buf_cnt,
        uniform_buf_cnt          : uint32 uniform_buf_cnt,
        thread_cnt_x             : uint32 thread_cnt[0],
        thread_cnt_y             : uint32 thread_cnt[1],
        thread_cnt_z             : uint32 thread_cnt[2],
        props                    : props,
    )
    result = sdl_create_gpu_compute_pipeline(dev, ci.addr)
    sdl_assert result, &"Failed to create compute pipeline ({repr ci})"

proc create_shader*(dev; stage: ShaderStage; code: string;
                    entry = "main";
                    fmt   = sffSpirV;
                    props = InvalidProperty;
                    sampler_cnt    : SomeInteger = 0;
                    storage_tex_cnt: SomeInteger = 0;
                    storage_buf_cnt: SomeInteger = 0;
                    uniform_buf_cnt: SomeInteger = 0;
                    ): Shader =
    let ci = ShaderCreateInfo(
        code_sz        : uint32 code.len,
        code           : code[0].addr,
        entry_point    : cstring entry,
        fmt            : fmt,
        stage          : stage,
        sampler_cnt    : uint32 sampler_cnt,
        storage_tex_cnt: uint32 storage_tex_cnt,
        storage_buf_cnt: uint32 storage_buf_cnt,
        uniform_buf_cnt: uint32 uniform_buf_cnt,
        props          : props,
    )
    result = sdl_create_gpu_shader(dev, ci.addr)
    sdl_assert result, &"Failed to create shader: '{get_error()}'"

# TODO: shader format and shader stage detection via file extension
proc create_shader_from_file*(dev; stage: ShaderStage; path: string;
                              entry = "main";
                              fmt   = sffSpirV;
                              props = InvalidProperty;
                              sampler_cnt    : SomeInteger = 0;
                              storage_tex_cnt: SomeInteger = 0;
                              storage_buf_cnt: SomeInteger = 0;
                              uniform_buf_cnt: SomeInteger = 0;
                              ): Shader =
    let code = read_file path
    create_shader dev, stage, code, entry, fmt, props, sampler_cnt, storage_tex_cnt, storage_buf_cnt, uniform_buf_cnt

proc create_buffer*(dev; usage: BufferUsageFlag; sz: SomeInteger; props = InvalidProperty): Buffer =
    let ci = BufferCreateInfo(
        usage: usage,
        sz   : uint32 sz,
        props: props,
    )
    result = sdl_create_gpu_buffer(dev, ci.addr)
    sdl_assert result, &"Failed to create buffer: '{get_error()}'"

proc create_buffer*(dev; usage: BufferUsageFlag; sz: SomeInteger; name: string; props = InvalidProperty): Buffer =
    result = create_buffer(dev, usage, sz, props)
    dev.set_buf_name result, name

proc create_sampler*(dev;
                     min_filter        = fNearest;
                     mag_filter        = fNearest;
                     mip_map_mode      = smmNearest;
                     addr_mode_u       = samRepeat;
                     addr_mode_v       = samRepeat;
                     addr_mode_w       = samRepeat;
                     compare_op        = coInvalid;
                     enable_anisotropy = false;
                     enable_compare    = false;
                     props             = InvalidProperty;
                     mip_lod_bias   = 0'f32;
                     max_anisotropy = 1'f32;
                     min_lod        = 1'f32;
                     max_lod        = 1'f32;
                     ): Sampler =
    let ci = SamplerCreateInfo(
        min_filter       : min_filter,
        mag_filter       : mag_filter,
        mip_map_mode     : mip_map_mode,
        addr_mode_u      : addr_mode_u,
        addr_mode_v      : addr_mode_v,
        addr_mode_w      : addr_mode_w,
        mip_lod_bias     : cfloat mip_lod_bias,
        max_anisotropy   : cfloat max_anisotropy,
        compare_op       : compare_op,
        min_lod          : cfloat min_lod,
        max_lod          : cfloat max_lod,
        enable_anisotropy: enable_anisotropy,
        enable_compare   : enable_compare,
        props            : props,
    )
    result = sdl_create_gpu_sampler(dev, ci.addr)
    sdl_assert result, &"Failed to create sampler: '{get_error()}'"

proc create_texture*(dev; w, h: uint32;
                     kind       = tk2D;
                     fmt        = tfR8G8B8A8Unorm;
                     usage      = tufSampler;
                     props      = InvalidProperty;
                     sample_cnt = sc1;
                     depth_or_layer_cnt = 1'u32;
                     lvl_cnt            = 1'u32;
                     ): Texture =
    let ci = TextureCreateInfo(
        kind              : kind,
        fmt               : fmt,
        usage             : usage,
        w                 : w,
        h                 : h,
        depth_or_layer_cnt: depth_or_layer_cnt,
        lvl_cnt           : lvl_cnt,
        sample_cnt        : sample_cnt,
        props             : props,
    )
    result = sdl_create_gpu_texture(dev, ci.addr)
    sdl_assert result, &"Failed to create texture: '{get_error()}'"

# TODO: have an option for a permanent multi-use transfer buffer
proc create_transfer_buffer*(dev; sz: SomeInteger;
                             usage = tbuUpload;
                             props = InvalidProperty;
                             ): TransferBuffer =
    let ci = TransferBufferCreateInfo(
        usage: usage,
        sz   : uint32 sz,
        props: props,
    )
    result = sdl_create_gpu_transfer_buffer(dev, ci.addr)
    sdl_assert result, &"Failed to create transfer buffer: '{get_error()}'"

proc map*(dev; buf: TransferBuffer; cycle = false): pointer = sdl_map_gpu_transfer_buffer   dev, buf, cycle
proc unmap*(dev; buf: TransferBuffer)                       = sdl_unmap_gpu_transfer_buffer dev, buf

proc begin_copy_pass*(cmd_buf): CopyPass =
    result = sdl_begin_gpu_copy_pass cmd_buf
    sdl_assert result, &"Failed to begin copy pass: '{get_error()}'"

proc upload*(copy_pass; trans_buf: TransferBuffer; tex; px_w: SomeInteger; px_h: SomeInteger;
             offset : SomeInteger = 0;
             mip_lvl: SomeInteger = 0;
             layer  : SomeInteger = 0;
             x: SomeInteger = 0   ; y: SomeInteger = 0   ; z: SomeInteger = 0;
             w: SomeInteger = px_w; h: SomeInteger = px_h; d: SomeInteger = 1;
             cycle = false;
             ) =
    let src = TextureTransferInfo(
        trans_buf     : trans_buf,
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

proc upload*(copy_pass; trans_buf: TransferBuffer; buf: Buffer; sz: SomeInteger;
             trans_buf_offset: SomeInteger = 0;
             buf_offset      : SomeInteger = 0;
             cycle = false;
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

proc copy*(copy_pass; dst, src: TextureLocation; w: SomeInteger; h: SomeInteger; d: SomeInteger; cycle = false) =
    sdl_copy_gpu_texture_to_texture copy_pass, src.addr, dst.addr, uint32 w, uint32 h, uint32 d, cycle
proc copy*(copy_pass; dst, src: BufferLocation; sz: SomeInteger; cycle = false) =
    sdl_copy_gpu_buffer_to_buffer copy_pass, src.addr, dst.addr, uint32 sz, cycle

proc download*(copy_pass; dst: TextureTransferInfo   ; src: TextureRegion) = sdl_download_from_gpu_texture copy_pass, src.addr, dst.addr
proc download*(copy_pass; dst: TransferBufferLocation; src: BufferRegion)  = sdl_download_from_gpu_buffer  copy_pass, src.addr, dst.addr

proc end_copy_pass*(copy_pass) = sdl_end_gpu_copy_pass copy_pass
proc `end`*(copy_pass)         = end_copy_pass copy_pass

proc claim*(dev; win): bool {.discardable.} =
    result = sdl_claim_window_for_gpu_device(dev, win)
    sdl_assert result, &"Failed to claim window for device: '{get_error()}'"

proc release*(dev; win) = sdl_release_window_from_gpu_device dev, win

proc acquire_command_buffer*(dev): CommandBuffer =
    result = sdl_acquire_gpu_command_buffer dev
    sdl_assert result, &"Failed to acquire command buffer: '{get_error()}'"
proc acquire_cmd_buf*(dev): CommandBuffer = acquire_command_buffer dev

proc cancel*(cmd_buf): bool {.discardable.} =
    result = sdl_cancel_gpu_command_buffer cmd_buf
    sdl_assert result, &"Failed to cancel GPU command buffer: '{get_error()}'"

proc acquire_swapchain_texture*(cmd_buf; win): tuple[tex: Texture; w, h: uint32] =
    let success = sdl_acquire_gpu_swapchain_texture(cmd_buf, win, result.tex.addr, result.w.addr, result.h.addr)
    sdl_assert success, &"Failed to acquire swapchain texture: '{get_error()}'"
proc swapchain_tex*(cmd_buf; win): tuple[tex: Texture; w, h: uint32] = cmd_buf.acquire_swapchain_texture win

proc wait_for_swapchain*(dev; win): bool {.discardable.} =
    result = dev.sdl_wait_for_gpu_swapchain win
    sdl_assert result, &"Failed to wait for GPU command buffer: '{get_error()}'"

proc wait_and_acquire_swapchain*(cmd_buf; win): tuple[tex: Texture; w, h: uint32] =
    let success = cmd_buf.sdl_wait_and_acquire_gpu_swapchain_texture(win, result.tex.addr, result.w.addr, result.h.addr)
    sdl_assert success, &"Failed to acquire swapchain texture: '{get_error()}'"
proc wait_swapchain_tex*(cmd_buf; win): tuple[tex: Texture; w, h: uint32] = cmd_buf.wait_and_acquire_swapchain win

proc push_vertex_uniform_data*[T](cmd_buf; slot: SomeInteger; data: T)   = sdl_push_gpu_vertex_uniform_data   cmd_buf, uint32 slot, data.addr, uint32 sizeof T
proc push_fragment_uniform_data*[T](cmd_buf; slot: SomeInteger; data: T) = sdl_push_gpu_fragment_uniform_data cmd_buf, uint32 slot, data.addr, uint32 sizeof T
proc push_compute_uniform_data*[T](cmd_buf; slot: SomeInteger; data: T)  = sdl_push_gpu_compute_uniform_data  cmd_buf, uint32 slot, data.addr, uint32 sizeof T
proc push_vtx_uniform*[T](cmd_buf; slot: SomeInteger; data: T)     = push_vertex_uniform_data   cmd_buf, slot, data
proc push_frag_uniform*[T](cmd_buf; slot: SomeInteger; data: T)    = push_fragment_uniform_data cmd_buf, slot, data
proc push_compute_uniform*[T](cmd_buf; slot: SomeInteger; data: T) = push_compute_uniform_data  cmd_buf, slot, data

proc gen_mip_maps*(cmd_buf; tex) = sdl_generate_mip_maps_for_gpu_texture cmd_buf, tex

proc blit*(cmd_buf; dst, src: BlitRegion;
           load_op      = loLoad;
           clear_colour = FBlack;
           flip_mode    = flipNone;
           filter       = fNearest;
           cycle        = false;
           ) =
    let blit_info = BlitInfo(
        src         : src,
        dst         : dst,
        load_op     : load_op,
        clear_colour: clear_colour,
        flip_mode   : flip_mode,
        filter      : filter,
        cycle       : cycle,
    )
    sdl_blit_gpu_texture cmd_buf, blit_info.addr

proc submit*(cmd_buf) =
    let success = sdl_submit_gpu_command_buffer cmd_buf
    sdl_assert success, &"Failed to submit command buffer: '{get_error()}'"

proc submit_with_fence*(cmd_buf): Fence =
    result = sdl_submit_gpu_command_buffer_and_acquire_fence cmd_buf
    sdl_assert result, &"Failed to submit command buffer with fence: '{get_error()}'"

proc begin_render_pass*(cmd_buf; cti: openArray[ColourTargetInfo]; dsti = none DepthStencilTargetInfo): RenderPass =
    let dsti = if dsti.is_some: (get dsti).addr else: nil
    result = sdl_begin_gpu_render_pass(cmd_buf, cti[0].addr, uint32 cti.len, dsti)
    sdl_assert result, &"Failed to begin render pass: '{get_error()}'"

proc `bind`*(ren_pass; gfx_pipeln)                                            = ren_pass.sdl_bind_gpu_graphics_pipeline gfx_pipeln
proc `bind`*(ren_pass; buf: BufferBinding; idx_elem_sz: IndexElementSize)     = ren_pass.sdl_bind_gpu_index_buffer buf.addr, idx_elem_sz
proc `bind`*(ren_pass; fst_slot: SomeInteger; bufs: openArray[BufferBinding]) = ren_pass.sdl_bind_gpu_vertex_buffer uint32 fst_slot, bufs[0].addr, uint32 bufs.len
proc `bind`*(ren_pass; fst_slot: SomeInteger; binds: openArray[TextureSamplerBinding]; stage = ssFragment) =
    case stage
    of ssVertex  :ren_pass.sdl_bind_gpu_vertex_samplers uint32 fst_slot, binds[0].addr, uint32 binds.len
    of ssFragment:ren_pass.sdl_bind_gpu_fragment_samplers uint32 fst_slot, binds[0].addr, uint32 binds.len
proc `bind`*(ren_pass; fst_slot: SomeInteger; texs: openArray[Texture]; stage = ssVertex) =
    case stage
    of ssVertex  : ren_pass.sdl_bind_gpu_vertex_storage_textures   uint32 fst_slot, texs[0].addr, uint32 texs.len
    of ssFragment: ren_pass.sdl_bind_gpu_fragment_storage_textures uint32 fst_slot, texs[0].addr, uint32 texs.len
proc `bind`*(ren_pass; fst_slot: SomeInteger; bufs: openArray[Buffer]; stage = ssVertex) =
    case stage
    of ssVertex  : ren_pass.sdl_bind_gpu_vertex_storage_buffers   uint32 fst_slot, bufs[0].addr, uint32 bufs.len
    of ssFragment: ren_pass.sdl_bind_gpu_fragment_storage_buffers uint32 fst_slot, bufs[0].addr, uint32 bufs.len

proc draw*(ren_pass; vtx_cnt: SomeInteger;
           inst_cnt: SomeInteger = 1;
           fst_vtx : SomeInteger = 0;
           fst_inst: SomeInteger = 0;
           ) =
    ren_pass.sdl_draw_gpu_primitives uint32 vtx_cnt, uint32 inst_cnt, uint32 fst_vtx, uint32 fst_inst
proc draw_indexed*(ren_pass; idx_cnt: SomeInteger;
                   inst_cnt  : SomeInteger = 1;
                   fst_idx   : SomeInteger = 0;
                   vtx_offset: SomeInteger = 0;
                   fst_inst  : SomeInteger = 0;
                   ) =
    ren_pass.sdl_draw_gpu_indexed_primitives uint32 idx_cnt, uint32 inst_cnt, uint32 fst_idx, int32 vtx_offset, uint32 fst_inst
proc draw_indirect*(ren_pass; buf: Buffer;
                    offset  : SomeInteger = 0;
                    draw_cnt: SomeInteger = 1;
                    ) =
    ren_pass.sdl_draw_gpu_primitives_indirect buf, uint32 offset, uint32 draw_cnt
proc draw_indirect_indexed*(ren_pass; buf: Buffer;
                            offset  : SomeInteger = 0;
                            draw_cnt: SomeInteger = 1;
                            ) =
    ren_pass.sdl_draw_gpu_indexed_primitives_indirect buf, uint32 offset, uint32 draw_cnt

proc `end`*(ren_pass) = sdl_end_gpu_render_pass ren_pass

proc begin_compute_pass*(cmd_buf;
                         tex_binds: openArray[StorageTextureReadWriteBinding];
                         buf_binds: openArray[StorageBufferReadWriteBinding];
                         ): ComputePass =
    result = sdl_begin_gpu_compute_pass(cmd_buf,
        (if tex_binds.len > 0: tex_binds[0].addr else: nil), uint32 tex_binds.len,
        (if buf_binds.len > 0: buf_binds[0].addr else: nil), uint32 buf_binds.len,
    )
    sdl_assert result, &"Failed to begin compute pass ({tex_binds.len} texture bindings and {buf_binds.len} buffer bindings)"

proc `bind`*(compute_pass; compute_pipeln)                                       = sdl_bind_gpu_compute_pipeline         compute_pass, compute_pipeln
proc `bind`*(compute_pass; fst_slot; samplers: openArray[TextureSamplerBinding]) = sdl_bind_gpu_compute_samplers         compute_pass, fst_slot, samplers[0].addr, uint32 samplers.len
proc `bind`*(compute_pass; fst_slot; texs: openArray[Texture])                   = sdl_bind_gpu_compute_storage_textures compute_pass, fst_slot, texs[0].addr, uint32 texs.len
proc `bind`*(compute_pass; fst_slot; bufs: openArray[Buffer])                    = sdl_bind_gpu_compute_storage_buffers  compute_pass, fst_slot, bufs[0].addr, uint32 bufs.len

proc dispatch*(compute_pass; group_cnts: array[3, SomeInteger])         = sdl_dispatch_gpu_compute compute_pass, uint32 group_cnts[0], uint32 group_cnts[1], uint32 group_cnts[2]
proc dispatch_indirect*(compute_pass; buf: Buffer; offset: SomeInteger) = sdl_dispatch_gpu_compute_indirect compute_pass, buf, uint32 offset

proc end_compute_pass*(compute_pass) = sdl_end_gpu_compute_pass compute_pass
proc `end`*(compute_pass) = end_compute_pass compute_pass

proc `viewport=`*(ren_pass; vp: Option[Viewport])  = ren_pass.sdl_set_gpu_viewport (if vp.is_some: (get vp).addr else: nil)
proc `scissor=`*(ren_pass; scissor: Option[Rect])  = ren_pass.sdl_set_gpu_scissor (if scissor.is_some: (get scissor).addr else: nil)
proc `blend_consts=`*(ren_pass; consts: FColour)   = ren_pass.sdl_set_gpu_blend_constants consts
proc `stencil_ref=`*(ren_pass; `ref`: SomeInteger) = ren_pass.sdl_set_gpu_stencil_reference uint8 `ref`

proc set_buf_name*(dev; buf; text: string) = sdl_set_gpu_buffer_name  dev, buf, cstring text
proc set_tex_name*(dev; tex; text: string) = sdl_set_gpu_texture_name dev, tex, cstring text

proc `debug_label=`*(cmd_buf; text: string)   = sdl_insert_gpu_debug_label cmd_buf, cstring text
proc push_debug_group*(cmd_buf; name: string) = sdl_push_gpu_debug_group cmd_buf, cstring name
proc pop_debug_group*(cmd_buf)                = sdl_pop_gpu_debug_group cmd_buf

proc destroy*(dev)                 = sdl_destroy_gpu_device dev
proc destroy*(dev; gfx_pipeln)     = sdl_release_gpu_graphics_pipeline dev, gfx_pipeln
proc destroy*(dev; compute_pipeln) = sdl_release_gpu_compute_pipeline dev, compute_pipeln
proc destroy*(dev; shader)         = sdl_release_gpu_shader dev, shader
proc destroy*(dev; tex)            = sdl_release_gpu_texture dev, tex
proc destroy*(dev; sampler)        = sdl_release_gpu_sampler dev, sampler
proc destroy*(dev; buf)            = sdl_release_gpu_buffer dev, buf
proc destroy*(dev; trans_buf)      = sdl_release_gpu_transfer_buffer dev, trans_buf
proc destroy*(dev; fence: Fence)   = sdl_release_gpu_fence dev, fence

proc wait_for_idle*(dev): bool {.discardable.} =
    result = sdl_wait_for_gpu_idle dev
    sdl_assert result, "Failed waiting for GPU to idle"
proc wait_for_fences*(dev; fences: openArray[Fence]; wait_all = true): bool {.discardable.} =
    result = sdl_wait_for_gpu_fences(dev, wait_all, fences[0].addr, uint32 fences.len)
    sdl_assert result, &"Failed waiting for {fences.len} fences"
proc is_signaled*(dev; fence: Fence): bool = sdl_query_gpu_fence dev, fence

proc copy_mem*(dev: Device; tbo: TransferBuffer; src: pointer; sz: Positive) =
    var dst = cast[pointer](dev.map tbo)
    dst.copy_mem src, sz
    dev.unmap tbo

proc copy_mem*(dev: Device; tbo: TransferBuffer; srcs: openArray[(pointer, int)]) =
    var dst = cast[pointer](dev.map tbo)
    for (src, sz) in srcs:
        dst.copy_mem src, sz
        dst = cast[pointer](cast[int](dst) + sz)
    dev.unmap tbo

{.pop.}

proc upload*[T](dev; usage: BufferUsageFlag; data: T; name = ""): Buffer =
    let sz = when not (T is seq or T is openArray): sizeof data else: data.len * sizeof data[0]
    result        = dev.create_buffer(usage, sz)
    let trans_buf = dev.create_transfer_buffer sz
    if name.len > 0:
        dev.set_buf_name result, name

    var buf_dst = cast[ptr T](dev.map trans_buf)
    when T is seq or T is openArray:
        copy_mem buf_dst, data[0].addr, sz
    else:
        buf_dst[] = data
    dev.unmap trans_buf

    let cmd_buf   = acquire_cmd_buf dev
    let copy_pass = begin_copy_pass cmd_buf
    copy_pass.upload trans_buf, result, sz
    `end` copy_pass

    submit cmd_buf
    dev.destroy trans_buf

proc upload*(dev; pxs: pointer; w, h: SomeInteger; fmt = tfR8G8B8A8Unorm; name = ""): Texture =
    let data_sz   = (uint32 w)*(uint32 h)*fmt.block_sz
    result        = dev.create_texture(w, h, fmt = fmt)
    let trans_buf = dev.create_transfer_buffer data_sz
    if name.len > 0:
        dev.set_tex_name result, name

    var tex_dst = dev.map trans_buf
    copy_mem tex_dst, pxs, data_sz
    dev.unmap trans_buf

    let cmd_buf   = acquire_cmd_buf dev
    let copy_pass = begin_copy_pass cmd_buf
    copy_pass.upload trans_buf, result, w, h
    `end` copy_pass

    submit cmd_buf
    dev.destroy trans_buf

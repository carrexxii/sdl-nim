import common, gpu

type
    ShaderStage* {.size: sizeof(cint).} = enum
        stageVertex
        stageFragment
        stageCompute

    ShaderModel* {.size: sizeof(cint).} = enum
        shaderModel5
        shaderModel6

#[ -------------------------------------------------------------------- ]#

using
    dev        : Device
    bytecode   : pointer
    bytecode_sz: uint
    entry      : cstring
    stage      : ShaderStage
    model      : ShaderModel

{.push dynlib: SdlShadercrossLib.}
proc sdl_shadercross_init*(): bool {.importc: "SDL_ShaderCross_Init".}
proc sdl_shadercross_quit*()       {.importc: "SDL_ShaderCross_Quit".}

proc sdl_shadercross_get_spirv_shader_formats*(): ShaderFormatFlag                                                 {.importc: "SDL_ShaderCross_GetSPIRVShaderFormats"          .}
proc sdl_shadercross_transpile_msl_from_spirv*(bytecode; bytecode_sz; entry; stage): pointer                       {.importc: "SDL_ShaderCross_TranspileMSLFromSPIRV"          .}
proc sdl_shadercross_transpile_hlsl_from_spirv*(bytecode; bytecode_sz; entry; stage; model): pointer               {.importc: "SDL_ShaderCross_TranspileHLSLFromSPIRV"         .}
proc sdl_shadercross_transpile_dxbc_from_spirv*(bytecode; bytecode_sz; entry; stage; sz: ptr uint): pointer        {.importc: "SDL_ShaderCross_CompileDXBCFromSPIRV"           .}
proc sdl_shadercross_transpile_dxil_from_spirv*(bytecode; bytecode_sz; entry; stage; sz: ptr uint): pointer        {.importc: "SDL_ShaderCross_CompileDXILFromSPIRV"           .}
proc sdl_shadercross_compile_graphics_shader_from_spirv*(dev; ci: ptr ShaderCreateInfo): Shader                    {.importc: "SDL_ShaderCross_CompileGraphicsShaderFromSPIRV" .}
proc sdl_shadercross_compile_compute_pipeline_from_spirv*(dev; ci: ptr ComputePipelineCreateInfo): ComputePipeline {.importc: "SDL_ShaderCross_CompileComputePipelineFromSPIRV".}

proc sdl_shadercross_get_hlsl_shader_formats*(): ShaderFormatFlag                                                               {.importc: "SDL_ShaderCross_GetHLSLShaderFormats"          .}
proc sdl_shadercross_compile_dxbc_from_hlsl*(src: cstring; entry; stage; sz: ptr uint): pointer                                 {.importc: "SDL_ShaderCross_CompileDXBCFromHLSL"           .}
proc sdl_shadercross_compile_dxil_from_hlsl*(src: cstring; entry; stage; sz: ptr uint): pointer                                 {.importc: "SDL_ShaderCross_CompileDXILFromHLSL"           .}
proc sdl_shadercross_compile_spirv_from_hlsl*(src: cstring; entry; stage; sz: ptr uint): pointer                                {.importc: "SDL_ShaderCross_CompileSPIRVFromHLSL"          .}
proc sdl_shadercross_compile_graphics_shader_from_hlsl*(dev; ci: ptr ShaderCreateInfo; src: cstring; stage): Shader             {.importc: "SDL_ShaderCross_CompileGraphicsShaderFromHLSL" .}
proc sdl_shadercross_compile_compute_pipeline_from_hlsl*(dev; ci: ptr ComputePipelineCreateInfo; src: cstring): ComputePipeline {.importc: "SDL_ShaderCross_CompileComputePipelineFromHLSL".}
{.pop.}

{.push inline.}

proc get_spirv_formats*(): ShaderFormatFlag = sdl_shadercross_get_spirv_shader_formats()

proc compile*(dev; ci: ShaderCreateInfo): Shader                   = sdl_shadercross_compile_graphics_shader_from_spirv  dev, ci.addr
proc compile*(dev; ci: ComputePipelineCreateInfo): ComputePipeline = sdl_shadercross_compile_compute_pipeline_from_spirv dev, ci.addr

{.pop.}

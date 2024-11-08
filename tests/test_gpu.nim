import std/with, sdl, sdl/gpu
from std/os        import `/`
from std/strformat import `&`

const
    ShaderDir   = "tests/shaders"
    ClearColour = fcolour(0.28, 0.12, 0.28, 1.0)
    TriVerts: array[21, float32] = [
        -0.5, -0.5, 0.0, 1.0, 0.0, 0.0, 1.0,
         0.0,  0.5, 0.0, 0.0, 1.0, 0.0, 1.0,
         0.5, -0.5, 0.0, 0.0, 0.0, 1.0, 1.0,
    ]

type Vertex = object
    pos   : array[3, float32]
    colour: array[4, float32]

var
    viewport = viewport(160, 120, 320, 240, 0.1, 1.0)
    scissor  = rect(320, 240, 320, 240)
    use_wireframe      = false
    use_small_viewport = false
    use_scissor        = false

assert sdl.init(initVideo or initEvents), &"Failed to initialize SDL: '{sdl.get_error()}'"
let device = create_device(shaderFmtSpirV, true)
assert device, &"Failed to create GPU device: '{sdl.get_error()}'"
let window = create_window("GPU Test", 640, 480, winNone)
assert window, &"Failed to create window: '{sdl.get_error()}'"
assert claim_window(device, window), &"Failed to claim window for device: '{sdl.get_error()}'"

let vtx_shader  = device.create_shader(shaderVertex, ShaderDir / "simple.vert.spv")
let frag_shader = device.create_shader(shaderVertex, ShaderDir / "simple.frag.spv")
assert vtx_shader and frag_shader, &"Failed to load shaders: vs = '{vtx_shader}'; fs = '{frag_shader}'"

var pipeln: GraphicsPipeline
let fill_pipeln = device.create_graphics_pipeline(vtx_shader, frag_shader,
    vertex_input_state(
        [vtx_descr(0, sizeof Vertex, inputVertex)],
        [vtx_attr(0, 0, vtxElemFloat3),
         vtx_attr(1, 0, vtxElemFloat4)],
    ),
)
let line_pipeln = device.create_graphics_pipeline(vtx_shader, frag_shader,
    vertex_input_state(
        [vtx_descr(0, sizeof Vertex, inputVertex)],
        [vtx_attr(0, 0, vtxElemFloat3),
         vtx_attr(1, 0, vtxElemFloat4)],
    ),
    raster_state = RasterizerState(
        fill_mode: fillLine,
    ),
)
assert fill_pipeln and line_pipeln, "Failed to create pipelines"

let verts_buf = device.create_buffer(bufUsageVertex, sizeof TriVerts)
let trans_buf = device.create_transfer_buffer(sizeof TriVerts)

var buf_dst = cast[array[21, float32]](device.map trans_buf)
buf_dst = TriVerts
device.unmap trans_buf

let cmd_buf   = device.acquire_cmd_buf
let copy_pass = begin_copy_pass cmd_buf
copy_pass.upload trans_buf, verts_buf, sizeof TriVerts
end_copy_pass copy_pass
submit cmd_buf
device.destroy trans_buf

proc draw() =
    let cmd_buf = device.acquire_cmd_buf
    assert cmd_buf, &"Failed to acquire command buffer: {sdl.get_error()}"

    let swapchain = cmd_buf.acquire_swapchain window
    let colour_target_info = ColourTargetInfo(
        tex         : swapchain.tex,
        clear_colour: ClearColour,
        load_op     : loadClear,
        store_op    : storeStore,
    )

    cmd_buf.render_pass [colour_target_info]:
        viewport = viewport
        `bind` fill_pipeln
        `bind` 0, [BufferBinding(buf: verts_buf)]
        draw 3

    submit cmd_buf

var running = true
while running:
    for event in events():
        case event.kind
        of eventQuit:
            running = false
        of eventKeyDown:
            case event.kb.key
            of kcEscape: running = false
            of kc1: pipeln = fill_pipeln
            of kc2: pipeln = line_pipeln
            else: discard
        else: discard

    draw()

with device:
    destroy fill_pipeln
    destroy line_pipeln
    destroy vtx_shader
    destroy frag_shader
    destroy
sdl.quit()

# static int Draw(Context* context)
# {
#     if (swapchainTexture != NULL)
#     {
#         SDL_GPURenderPass* renderPass = SDL_BeginGPURenderPass(cmdbuf, &colorTargetInfo, 1, NULL);
#         SDL_BindGPUGraphicsPipeline(renderPass, UseWireframeMode ? LinePipeline : FillPipeline);
#         if (UseSmallViewport)
#         {
#             SDL_SetGPUViewport(renderPass, &SmallViewport);
#         }
#         if (UseScissorRect)
#         {
#             SDL_SetGPUScissor(renderPass, &ScissorRect);
#         }
#         SDL_DrawGPUPrimitives(renderPass, 3, 1, 0, 0);
#         SDL_EndGPURenderPass(renderPass);
#     }

#     SDL_SubmitGPUCommandBuffer(cmdbuf);

#     return 0;
# }

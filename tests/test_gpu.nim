import std/[options, with], sdl, sdl/[gpu, pixels, rect]
from std/os        import `/`
from std/strformat import `&`

type Vertex = object
    pos   : array[3, float32]
    colour: array[4, float32]

const
    ShaderDir   = "tests/shaders"
    ClearColour = sdl_colour(0.28, 0.12, 0.28, 1.0)
    TriVerts = [
        Vertex(pos: [-0.5, -0.5, 0.0], colour: [1.0, 0.0, 0.0, 1.0]),
        Vertex(pos: [ 0.0,  0.5, 0.0], colour: [0.0, 1.0, 0.0, 1.0]),
        Vertex(pos: [ 0.5, -0.5, 0.0], colour: [0.0, 0.0, 1.0, 1.0]),
    ]

var
    viewport = none Viewport
    scissor  = none SdlRect
    small_viewport = viewport(160, 120, 320, 240, 0.1, 1.0)
    small_scissor  = sdl_rect(320, 240, 320, 240)

init(InitVideo or InitEvents)
let device = create_device(ShaderFmtSpirV, true)
let window = create_window("GPU Test", 640, 480, winNone)
device.claim window

let vtx_shader  = device.create_shader_from_file(ShaderStage.Vertex  , ShaderDir / "simple.vert.spv")
let frag_shader = device.create_shader_from_file(ShaderStage.Fragment, ShaderDir / "simple.frag.spv")

let
    ct_descr = ColourTargetDescription(fmt: swapchain_tex_fmt(device, window))
    fill_pipeln = device.create_graphics_pipeline(vtx_shader, frag_shader,
        vertex_input_state(
            [vtx_descr(0, sizeof Vertex, VertexInputRate.Vertex)],
            [vtx_attr(0, 0, Float3, 0),
             vtx_attr(1, 0, Float4, 12)],
        ),
        target_info = GraphicsPipelineTargetInfo(
            colour_target_descrs: ct_descr.addr,
            colour_target_cnt   : 1,
        ),
    )
    line_pipeln = device.create_graphics_pipeline(vtx_shader, frag_shader,
        vertex_input_state(
            [vtx_descr(0, sizeof Vertex, VertexInputRate.Vertex)],
            [vtx_attr(0, 0, Float3, 0),
             vtx_attr(1, 0, Float4, 12)],
        ),
        target_info = GraphicsPipelineTargetInfo(
            colour_target_descrs: ct_descr.addr,
            colour_target_cnt   : 1,
        ),
        raster_state = RasterizerState(
            fill_mode: Line,
        ),
    )
var pipeln = fill_pipeln

let verts_buf = device.upload(BufUsageVertex, TriVerts)

proc draw() =
    let cmd_buf   = acquire_cmd_buf device
    let swapchain = cmd_buf.wait_swapchain_tex window
    let colour_target_info = ColourTargetInfo(
        tex         : swapchain.tex,
        clear_colour: ClearColour,
        load_op     : Clear,
        store_op    : Store,
    )

    let ren_pass = begin_render_pass(cmd_buf, [colour_target_info])
    with ren_pass:
        viewport = viewport
        scissor  = scissor
        `bind` pipeln
        `bind` 0, [BufferBinding(buf: verts_buf)]
        draw 3
    `end` ren_pass
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
            of kcV: viewport = if viewport.is_some: none Viewport else: some small_viewport
            of kcS: scissor  = if scissor.is_some : none SdlRect  else: some small_scissor
            else: discard
        else: discard

    draw()

with device:
    destroy verts_buf
    destroy fill_pipeln
    destroy line_pipeln
    destroy vtx_shader
    destroy frag_shader
    destroy
sdl.quit()

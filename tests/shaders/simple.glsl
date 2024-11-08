#version 460

#ifdef VERTEX /////////////////////////////////////////////

layout(location = 0) in vec3 in_pos;
layout(location = 1) in vec4 in_colour;

layout(location = 0) out vec4 out_colour;

void main()
{
    out_colour  = in_colour;
    gl_Position = vec4(in_pos, 1);
}

#endif
///////////////////////////////////////////////////////////
#ifdef FRAGMENT

layout(location = 0) in vec4 in_colour;

layout(location = 0) out vec4 out_colour;

void main()
{
    out_colour = in_colour;
}

#endif ////////////////////////////////////////////////////

version     = "0.0.1"
author      = "carrexxii"
description = "SDL3 bindings and wrapper for Nim"
license     = "Apache2.0"

requires "nim >= 2.0.0"

#[ -------------------------------------------------------------------- ]#

import std/[os, strformat, strutils, sequtils]

const
    SdlTag            = "release-3.2.0"
    SdlTtfTag         = "7d62ee195e32180b874c97a07df4080712b467b6"
    SdlShaderCrossTag = "d3e304a9279c921bbba5b36c1f8b105825ca6333"

    SdlFlags            = "-DCMAKE_BUILD_TYPE=Release -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TEST_LIBRARY=OFF -DSDL_DISABLE_INSTALL=ON"
    SdlTtfFlags         = "-DSDL3_ROOT=../sdl/build"
    SdlShadercrossFlags = "-DSDLGPUSHADERCROSS_SHARED=ON -DSDL3_DIR=../sdl/build"

task build_lib, "Fetch and build SDL libraries":
    exec &"git submodule update --init --remote --merge --recursive -j 8"

    with_dir "lib/sdl":
        exec &"""cmake -S . -B ./build {SdlFlags};
                 cmake --build ./build -j8;
                 cp ./build/libSDL3.so* ../"""

    with_dir "lib/sdl_ttf":
        exec &"""cmake -S . -B ./build {SdlTtfFlags};
                 cmake --build ./build -j8;
                 mv ./build/libSDL3_ttf.so* ../"""

    with_dir "lib/sdl_gpu_shadercross":
        exec &"""cmake -S . -B ./build {SdlShadercrossFlags};
                 cmake --build ./build -j8;
                 mv ./build/libSDL3_gpu_shadercross.so.0.0.0 ../libSDL3_gpu_shadercross.so"""

before test:
    let shaders = list_files("tests/shaders").filter_it(not it.ends_with ".spv")
    for shader in shaders:
        exec &"""glslangValidator {shader} -V -S vert -o {shader.replace(".glsl", ".vert.spv")} --quiet -DVERTEX"""
        exec &"""glslangValidator {shader} -V -S frag -o {shader.replace(".glsl", ".frag.spv")} --quiet -DFRAGMENT"""

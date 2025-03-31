version     = "0.0.1"
author      = "carrexxii"
description = "SDL3 bindings and wrapper for Nim"
license     = "Apache2.0"

import std/[os, strformat, strutils, sequtils]

const
    SdlTag      = "release-3.2.8"
    SdlTtfTag   = "release-3.2.0"
    SdlImageTag = "release-3.2.4"

    SdlFlags      = "-DCMAKE_BUILD_TYPE=Release -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TEST_LIBRARY=OFF -DSDL_DISABLE_INSTALL=ON"
    SdlTtfFlags   = "-DSDL3_ROOT=../sdl/build"
    SdlImageFlags = "-DSDLIMAGE_VENDORED=OFF"

task restore, "Fetch and build SDL libraries":
    exec &"git submodule update --init --remote --merge --recursive -j 8"

    with_dir "lib/sdl":
        exec &"git checkout {SdlTag}"
        exec &"""cmake -S . -B ./build {SdlFlags};
                 cmake --build ./build -j8;
                 cp ./build/libSDL3.so* ../"""

    with_dir "lib/sdl_ttf":
        exec &"git checkout {SdlTtfTag}"
        exec &"""cmake -S . -B ./build {SdlTtfFlags};
                 cmake --build ./build -j8;
                 mv ./build/libSDL3_ttf.so* ../"""

    with_dir "lib/sdl_image":
        exec &"git checkout {SdlImageTag}"
        exec &"""cmake -S . -B ./build {SdlImageFlags};
                 cmake --build ./build -j8;
                 mv ./build/libSDL3_image.so* ../"""

before test:
    let shaders = list_files("tests/shaders").filter_it(not it.ends_with ".spv")
    for shader in shaders:
        exec &"""glslangValidator {shader} -V -S vert -o {shader.replace(".glsl", ".vert.spv")} --quiet -DVERTEX"""
        exec &"""glslangValidator {shader} -V -S frag -o {shader.replace(".glsl", ".frag.spv")} --quiet -DFRAGMENT"""

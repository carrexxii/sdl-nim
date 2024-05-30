--hints: off

import std/strformat

const
    SDLTag    = ""
    SDLTTFTag = ""

    TestDir = "./tests"
    LibDir  = "./lib"

    SDLFlags = "-DCMAKE_BUILD_TYPE=Release -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TEST_LIBRARY=OFF -DSDL_DISABLE_INSTALL=ON"
    SDLTTFFlags = "-DSDL3_ROOT=../sdl/build"

task build_libs, "Build dependencies":
    echo "Building SDL"
    with_dir &"{LibDir}/sdl":
        exec "git checkout " & SDLTag
        exec "cmake -S . -B ./build " & SDLFlags
        exec "cmake --build ./build -j8"
        exec "cp ./build/libSDL3.so* ../"

    echo "Building SDL_TTF"
    with_dir &"{LibDir}/sdl_ttf":
        exec "git checkout " & SDLTTFTag
        exec "cmake -S . -B ./build " & SDLTTFFlags
        exec "cmake --build ./build -j8"
        exec "cp ./build/libSDL3_ttf.so* ../"

task restore, "Fetch and build dependencies":
    echo "Fetching submodules..."
    exec "git submodule update --init --checkout --force --remote --recursive -j 8"
    build_libs_task()

task test, "Run tests":
    echo "Running tests..."
    exec &"nim c -r -p:. -o:test {TestDir}/test_ui.nim"

task clean, "Cleanup":
    echo "Cleaning..."
    rm_file "./test"

task docs, "Build and serve documentation":
    echo "Building documentation..."
    exec "nim doc --project --index:on -o:./docs nsdl.nim"

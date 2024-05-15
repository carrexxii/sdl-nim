--hints: off

const
    SDLTag    = "prerelease-3.1.2"
    SDLTTFTag = ""

const
    SDLFlags = "-DCMAKE_BUILD_TYPE=Release -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TEST_LIBRARY=OFF -DSDL_DISABLE_INSTALL=ON"
    SDLTTFFlags = "-DSDL3_ROOT=../sdl/build"

task builddeps, "Build SDL":
    echo "Fetching and building SDL libraries..."
    exec "git submodule update --init --checkout --force --remote --recursive -j 12"
    with_dir "lib/sdl":
        exec "git checkout " & SDLTag
        exec "cmake -S . -B ./build " & SDLFlags
        exec "cmake --build ./build -j12"
        exec "cp ./build/libSDL3.so* ../"

    with_dir "lib/sdl_ttf":
        exec "git checkout " & SDLTTFTag
        exec "cmake -S . -B ./build " & SDLTTFFlags
        exec "cmake --build ./build -j12"
        exec "cp ./build/libSDL3_ttf.so* ../"

task test, "Run tests":
    echo "Running tests..."
    exec "nim c -r -p:. -o:test tests/test.nim"

task clean, "Cleanup":
    echo "Cleaning..."
    rm_file "./test"

task docs, "Build and serve documentation":
    echo "Building documentation..."
    exec "nim doc --project --index:on -o:./docs nsdl.nim"

--hints: off

const SDLFlags = "-DCMAKE_BUILD_TYPE=Release -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TEST_LIBRARY=OFF -DSDL_DISABLE_INSTALL=ON"

task build, "Build SDL":
    echo "Fetching and building SDL..."
    exec "git submodule update --init --remote --merge --recursive -j 12"
    with_dir "lib/sdl":
        exec "cmake -S . -B ./build " & SDLFlags
        exec "cmake --build ./build -j12"
        exec "cp ./build/libSDL3.so* ../.."

task test, "Run tests":
    echo "Running tests..."
    exec "nim c -r -p:. -o:test tests/test.nim"

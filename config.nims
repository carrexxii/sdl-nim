import std/[os, strformat, strutils, sequtils, enumerate]

const
    SDLFlags    = "-DCMAKE_BUILD_TYPE=Release -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TEST_LIBRARY=OFF -DSDL_DISABLE_INSTALL=ON"
    SDLTTFFlags = "-DSDL3_ROOT=../sdl/build"

let
    src_dir   = "./src"
    lib_dir   = "./lib"
    build_dir = "./build"
    test_dir  = "./tests"
    docs_dir  = "./docs"
    entry     = src_dir / "main.nim"
    deps: seq[tuple[src, dst, tag: string; cmds: seq[string]]] = @[
        (src  : "https://github.com/libsdl-org/SDL/",
         dst  : lib_dir / "sdl",
         tag  : "bf03dee86609fbed159543446a39584a3cee2141",
         cmds : @[&"cmake -S . -B ./build {SDLFlags}",
                   "cmake --build ./build -j8",
                   "cp ./build/libSDL3.so* ../"]),
        (src  : "https://github.com/libsdl-org/SDL_ttf",
         dst  : lib_dir / "sdl_ttf",
         tag  : "a8582e6c4141b7236533f3fd1a1b4ac30f548f33",
         cmds : @[&"cmake -S . -B ./build {SDLTTFFlags}",
                   "cmake --build ./build -j8",
                   "mv ./build/libSDL3_ttf.so* ../"]),
    ]

#[ -------------------------------------------------------------------- ]#

proc red    (s: string): string = &"\e[31m{s}\e[0m"
proc green  (s: string): string = &"\e[32m{s}\e[0m"
proc yellow (s: string): string = &"\e[33m{s}\e[0m"
proc blue   (s: string): string = &"\e[34m{s}\e[0m"
proc magenta(s: string): string = &"\e[35m{s}\e[0m"
proc cyan   (s: string): string = &"\e[36m{s}\e[0m"

proc error(s: string)   = echo red    &"Error: {s}"
proc warning(s: string) = echo yellow &"Warning: {s}"

var cmd_count = 0
proc run(cmd: string) =
    if defined `dry-run`:
        echo blue &"[{cmd_count}] ", cmd
        cmd_count += 1
    else:
        exec cmd

func is_git_repo(url: string): bool =
    (gorge_ex &"git ls-remote -q {url}")[1] == 0

#[ -------------------------------------------------------------------- ]#

task restore, "Fetch and build dependencies":
    run &"rm -rf {lib_dir}/*"
    run &"git submodule update --init --remote --merge -j 8"
    for dep in deps:
        if is_git_repo dep.src:
            with_dir dep.dst:
                run &"git checkout {dep.tag}"
        else:
            run &"curl -o {lib_dir / (dep.src.split '/')[^1]} {dep.src}"

        with_dir dep.dst:
            for cmd in dep.cmds:
                run cmd

task test, "Run the project's tests":
    run &"nim c -r -p:. -d:NSDLPath=./ -o:test {test_dir}/test_ui.nim"

task docs, "Build and serve documentation":
    run &"nim doc --project --index:on -o:{docs_dir} nsdl.nim"

task info, "Print out information about the project":
    echo green &"NSDL - Nim bindings for SDL"
    if deps.len > 0:
        echo &"{deps.len} Dependencies:"
    for (i, dep) in enumerate deps:
        let is_git = is_git_repo dep.src
        let tag =
            if is_git and dep.tag != "":
                "@" & dep.tag
            elif is_git: "@HEAD"
            else       : ""
        echo &"    [{i + 1}] {dep.dst:<24}{cyan dep.src}{yellow tag}"

    echo ""
    run "cloc --vcs=git"


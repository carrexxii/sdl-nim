import std/unittest, sdl

suite "Timer":
    let
        x = 1'ms
        y = 1000'us
        z = 1000_000'ns

    check:
        1'ms == x
        1'ms == y
        1'ms == z

        1000'us == x
        1000'us == y
        1000'us == z

        1000_000'ns == x
        1000_000'ns == y
        1000_000'ns == z

    check:
        (x * 100)  == 100'ms
        (y * 10)   == 10'ms
        (z * 1000) == 1000'ms


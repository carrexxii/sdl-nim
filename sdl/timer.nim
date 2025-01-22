import std/strutils, common, util

type
    TimerId* = distinct uint32
    TimerCallback*   = proc(user_data: pointer; timer_id: TimerId; interval: Milliseconds): Milliseconds {.cdecl.}
    TimerCallbackNs* = proc(user_data: pointer; timer_id: TimerId; interval: Nanoseconds):  Nanoseconds  {.cdecl.}

    Milliseconds* = distinct uint32
    Microseconds* = distinct uint64
    Nanoseconds*  = distinct uint64

Milliseconds.borrow_numeric uint32
Microseconds.borrow_numeric uint64
Nanoseconds.borrow_numeric  uint64

func `$`*(x: Milliseconds): string = &"{x.ord}ms"
func `$`*(x: Microseconds): string = &"{x.ord}μs"
func `$`*(x: Nanoseconds) : string = &"{x.ord}ns"

proc `'ms`*(x: string): Milliseconds {.compileTime.} = Milliseconds parse_int x
proc `'us`*(x: string): Microseconds {.compileTime.} = Microseconds parse_int x
proc `'μs`*(x: string): Microseconds {.compileTime.} = `'us` x
proc `'ns`*(x: string): Nanoseconds  {.compileTime.} = Nanoseconds  parse_int x

converter ms_to_us*(x: Milliseconds): Microseconds = Microseconds ((uint32 x) * 1000)
converter ms_to_ns*(x: Milliseconds): Nanoseconds  = Nanoseconds  ((uint32 x) * 1000_000)
converter us_to_ns*(x: Microseconds): Nanoseconds  = Nanoseconds  ((uint64 x) * 1000)
converter us_to_ms*(x: Microseconds): Milliseconds = Milliseconds ((uint64 x) div 1000)
converter ns_to_ms*(x: Nanoseconds):  Milliseconds = Milliseconds ((uint64 x) div 1000_000)
converter ns_to_us*(x: Nanoseconds):  Microseconds = Microseconds ((uint64 x) div 1000)

func `==`*(a: Milliseconds; b: Microseconds): bool = b == ms_to_us a
func `==`*(a: Milliseconds; b: NanoSeconds):  bool = b == ms_to_ns a
func `==`*(a: Microseconds; b: Nanoseconds):  bool = b == us_to_ns a
func `==`*(a: Microseconds; b: Milliseconds): bool = a == ms_to_us b
func `==`*(a: Nanoseconds ; b: Milliseconds): bool = a == ms_to_ns b
func `==`*(a: Nanoseconds ; b: Microseconds): bool = a == us_to_ns b

{.push dynlib: SdlLib.}
proc sdl_get_ticks*(): Nanoseconds                 {.importc: "SDL_GetTicks"               .}
proc sdl_get_ticks_ns*(): Nanoseconds              {.importc: "SDL_GetTicksNS"             .}
proc sdl_get_performance_counter*(): Nanoseconds   {.importc: "SDL_GetPerformanceCounter"  .}
proc sdl_get_performance_frequency*(): Nanoseconds {.importc: "SDL_GetPerformanceFrequency".}
proc sdl_delay*(ms: Milliseconds)                  {.importc: "SDL_Delay"                  .}
proc sdl_delay_ns*(ns: Nanoseconds)                {.importc: "SDL_DelayNS"                .}

proc sdl_add_timer*(interval: Milliseconds; callback: TimerCallback; user_data: pointer): TimerId   {.importc: "SDL_AddTimer"   .}
proc sdl_add_timer_ns*(interval: Nanoseconds; callback: TimerCallback; user_data: pointer): TimerId {.importc: "SDL_AddTimerNS" .}
proc sdl_remove_timer*(timer: TimerId): bool                                                        {.importc: "SDL_RemoveTimer".}
{.pop.}

{.push inline.}

proc get_ticks*(): Nanoseconds = sdl_get_ticks_ns()

proc delay*(ns: Nanoseconds) = sdl_delay_ns ns
proc sleep*(ns: Nanoseconds) = sdl_delay_ns ns

proc create_timer*(interval: Nanoseconds; cb: TimerCallback; user_data: pointer = nil): TimerId =
    sdl_add_timer_ns interval, cb, user_data

proc remove*(timer: TimerId): bool {.discardable.} =
    result = sdl_remove_timer timer
    sdl_assert result, &"Failed to remove time {cast[int](timer)}"

func fps_to_ns*(fps: int): Nanoseconds  = Nanoseconds (1 / fps * 1000_000_000)
func ns_to_fps*(ns: Nanoseconds): float = 1 / ((float ns) / 1000_000_000)

{.pop.}

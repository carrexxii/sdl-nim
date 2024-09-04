import std/strutils, common, util
from std/strformat import `&`

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
func `$`*(x: Microseconds): string = &"{x.ord}us"
func `$`*(x: Nanoseconds) : string = &"{x.ord}ns"

proc `'ms`*(x: string): Milliseconds {.compileTime.} = Milliseconds parse_int x
proc `'us`*(x: string): Microseconds {.compileTime.} = Microseconds parse_int x
proc `'ns`*(x: string): Nanoseconds  {.compileTime.} = Nanoseconds  parse_int x

converter `ms -> us`*(x: Milliseconds): Microseconds = Microseconds ((uint32 x) * 1000)
converter `ms -> ns`*(x: Milliseconds): Nanoseconds  = Nanoseconds  ((uint32 x) * 1000_000)
converter `us -> ns`*(x: Microseconds): Nanoseconds  = Nanoseconds  ((uint64 x) * 1000)
converter `us -> ms`*(x: Microseconds): Milliseconds = Milliseconds ((uint64 x) div 1000)
converter `ns -> ms`*(x: Nanoseconds):  Milliseconds = Milliseconds ((uint64 x) div 1000_000)
converter `ns -> us`*(x: Nanoseconds):  Microseconds = Microseconds ((uint64 x) div 1000)

func `==`*(a: Milliseconds; b: Microseconds): bool = b == `ms -> us` a
func `==`*(a: Milliseconds; b: NanoSeconds):  bool = b == `ms -> ns` a
func `==`*(a: Microseconds; b: Nanoseconds):  bool = b == `us -> ns` a
func `==`*(a: Microseconds; b: Milliseconds): bool = a == `ms -> us` b
func `==`*(a: Nanoseconds ; b: Milliseconds): bool = a == `ms -> ns` b
func `==`*(a: Nanoseconds ; b: Microseconds): bool = a == `us -> ns` b

{.push dynlib: SdlLib.}
proc sdl_get_ticks*(): Nanoseconds                 {.importc: "SDL_GetTicks"               .}
proc sdl_get_ticks_ns*(): Nanoseconds              {.importc: "SDL_GetTicksNS"             .}
proc sdl_get_performance_counter*(): Nanoseconds   {.importc: "SDL_GetPerformanceCounter"  .}
proc sdl_get_performance_frequency*(): Nanoseconds {.importc: "SDL_GetPerformanceFrequency".}
proc sdl_delay*(ms: Milliseconds)                  {.importc: "SDL_Delay"                  .}
proc sdl_delay_ns*(ns: Nanoseconds)                {.importc: "SDL_DelayNS"                .}

proc sdl_add_timer*(interval: Milliseconds; callback: TimerCallback; user_data: pointer): TimerId   {.importc: "SDL_AddTimer"   .}
proc sdl_add_timer_ns*(interval: Nanoseconds; callback: TimerCallback; user_data: pointer): TimerId {.importc: "SDL_AddTimerNS" .}
proc sdl_remove_timer*(timer: TimerID): SdlBool                                                     {.importc: "SDL_RemoveTimer".}
{.pop.}

{.push inline.}

proc ticks*(): Nanoseconds = sdl_get_ticks_ns()

proc delay*(ns: Nanoseconds) = sdl_delay_ns ns
proc sleep*(ns: Nanoseconds) = sdl_delay_ns ns

proc create_timer*(interval: Nanoseconds; cb: TimerCallback; user_data: pointer = nil): TimerId =
    sdl_add_timer_ns interval, cb, user_data

# TODO: add error return
proc remove*(timer: TimerId): bool {.discardable.} =
    sdl_remove_timer timer

func fps_to_ns*(fps: int): Nanoseconds =
    Nanoseconds (1 / fps * 1000_000_000)

func ns_to_fps*(ns: Nanoseconds): float =
    1 / ((float ns) / 1000_000_000)

{.pop.} # inline

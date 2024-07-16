import std/strutils, common, util

type
    TimerID* = distinct uint32
    TimerCallback*   = ((user_data: pointer, timer_id: TimerID, interval: Milliseconds) {.cdecl.} -> Milliseconds)
    TimerCallbackNs* = ((user_data: pointer, timer_id: TimerID, interval: Nanoseconds)  {.cdecl.} -> Nanoseconds)

    Milliseconds* = distinct uint32
    Microseconds* = distinct uint64
    Nanoseconds*  = distinct uint64

Milliseconds.borrow_numeric uint32
Microseconds.borrow_numeric uint64
Nanoseconds.borrow_numeric  uint64

func `$`*(x: Milliseconds): string = $(uint32 x) & "ms"
func `$`*(x: Microseconds): string = $(uint64 x) & "us"
func `$`*(x: Nanoseconds) : string = $(uint64 x) & "ns"

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

{.push dynlib: SDLLib.}
proc sdl_get_ticks*(): Nanoseconds                 {.importc: "SDL_GetTicks"               .}
proc sdl_get_ticks_ns*(): Nanoseconds              {.importc: "SDL_GetTicksNS"             .}
proc sdl_get_performance_counter*(): Nanoseconds   {.importc: "SDL_GetPerformanceCounter"  .}
proc sdl_get_performance_frequency*(): Nanoseconds {.importc: "SDL_GetPerformanceFrequency".}
proc sdl_delay*(ms: Milliseconds)                  {.importc: "SDL_Delay"                  .}
proc sdl_delay_ns*(ns: Nanoseconds)                {.importc: "SDL_DelayNS"                .}

proc sdl_add_timer*(interval: Milliseconds; callback: TimerCallback; user_data: pointer): TimerID   {.importc: "SDL_AddTimer"   .}
proc sdl_add_timer_ns*(interval: Nanoseconds; callback: TimerCallback; user_data: pointer): TimerID {.importc: "SDL_AddTimerNS" .}
proc sdl_remove_timer*(timer: TimerID): cint                                                        {.importc: "SDL_RemoveTimer".}
{.pop.}

{.push inline.}

proc get_ticks*(): Nanoseconds = sdl_get_ticks_ns()

proc delay*(ns: Nanoseconds) = sdl_delay_ns ns
proc sleep*(ns: Nanoseconds) = sdl_delay_ns ns

proc create_timer*(interval: Nanoseconds; callback: TimerCallback; user_data: pointer = nil): TimerID =
    sdl_add_timer_ns interval, callback, user_data

# TODO: add error return
proc remove*(timer: TimerID) =
    let res = sdl_remove_timer timer
    if res != 0:
        echo red &"Error removing SDL timer: '{get_error()}'"

func fps_to_ns*(fps: int): Nanoseconds =
    Nanoseconds (1 / fps * 1000_000_000)

{.pop.}


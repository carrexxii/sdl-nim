import std/options, common

type
    SdlPoint* = object
        x*: int32
        y*: int32
    SdlPointF* = object
        x*: float32
        y*: float32

    SdlRect* = object
        x*, y*: int32
        w*, h*: int32
    SdlRectF* = object
        x*, y*: float32
        w*, h*: float32

converter to_sdl_rect*(r: SdlRectF): SdlRect  = SdlRect(x: int32 r.x, y: int32 r.y, w: int32 r.w, h: int32 r.h)
converter to_sdl_rectf*(r: SdlRect): SdlRectF = SdlRectF(x: float32 r.x, y: float32 r.y, w: float32 r.w, h: float32 r.h)

func `$`*(pt: SdlPoint | SdlPointF): string = &"({pt.x}, {pt.y})"
func `$`*(r: SdlRect | SdlRectF): string    = &"({r.x}, {r.y}, {r.w}, {r.h})"

func `==`*(pt1, pt2: SdlPoint | SdlPointF): bool = pt1.x == pt2.x and pt1.y == pt2.y
func `==`*(r1, r2: SdlRect | SdlRectF): bool     = r1.x == r2.x and r1.y == r2.y and r1.w == r2.w and r1.h == r2.h

func sdl_point*(x, y: distinct SomeNumber): SdlPoint   = SdlPoint(x: int32 x, y: int32 y)
func sdl_pointf*(x, y: distinct SomeNumber): SdlPointF = SdlPointF(x: float32 x, y: float32 y)

func sdl_rect*(x, y, w, h: distinct SomeNumber): SdlRect   = SdlRect(x: int32 x, y: int32 y, w: int32 w, h: int32 w)
func sdl_rectf*(x, y, w, h: distinct SomeNumber): SdlRectF = SdlRectF(x: float32 x, y: float32 y, w: float32 w, h: float32 h)

func contains*(r: SdlRect | SdlRectF; pt: SdlPoint | SdlPointF): bool =
    (pt.x >= r.x) and (pt.x < r.x + r.w) and
    (pt.y >= r.y) and (pt.y < r.y + r.h)
func contains*(r: SdlRect; pt: (SomeNumber, SomeNumber) | array[2, SomeNumber]): bool  = contains r, sdl_point(pt[0], pt[1])
func contains*(r: SdlRectF; pt: (SomeNumber, SomeNumber) | array[2, SomeNumber]): bool = contains r, sdl_pointf(pt[0], pt[1])

func is_empty*(r: SdlRect | SdlRectF): bool =
    r.w <= 0 or r.h <= 0

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_HasRectIntersection*(A, B: ptr SdlRect): bool
proc SDL_GetRectIntersection*(A, B, Sdlrect: ptr SdlRect): bool
proc SDL_GetRectUnion*(A, B, result: ptr SdlRect): bool
proc SDL_GetRectEnclosingPoints*(pts: ptr SdlPoint; cnt: cint; clip, result: ptr SdlRect): bool
proc SDL_GetRectAndLineIntersection*(rect: ptr SdlRect; X1, Y1, X2, Y2: ptr cint): bool

proc SDL_HasRectIntersectionFloat*(A, B: ptr SdlRectF): bool
proc SDL_GetRectIntersectionFloat*(A, B, result: ptr SdlRectF): bool
proc SDL_GetRectUnionFloat*(A, B, result: ptr SdlRectF): bool
proc SDL_GetRectEnclosingPointsFloat*(pts: ptr SdlPointF; cnt: cint; clip, result: ptr SdlRectF): bool
proc SDL_GetRectAndLineIntersectionFloat*(rect: ptr SdlRectF; X1, Y1, X2, Y2: ptr cfloat): bool
{.pop.}

{.push inline.}

proc has_intersection*[T: SdlRect | SdlRectF](a, b: T): bool =
    when T is SdlRect:
        SDL_HasRectIntersection a.addr, b.addr
    else:
        SDL_HasRectIntersectionFloat a.addr, b.addr

proc intersection*[T: SdlRect | SdlRectF](a, b: T): T =
    when T is SdlRect:
        SDL_GetRectIntersection a.addr, b.addr, result.addr
    else:
        SDL_GetRectIntersectionFloat a.addr, b.addr, result.addr

proc union*[T: SdlRect | SdlRectF](a, b: T): T =
    when T is SdlRect:
        SDL_GetRectUnion a.addr, b.addr, result.addr
    else:
        SDL_GetRectUnionFloat a.addr, b.addr, result.addr

proc rect_enclosing_points*(pts: openArray[SdlPoint]; clip: Option[SdlRect]): SdlRect =
    let clip = if clip.is_some: (get clip).addr else: nil
    let success = SDL_GetRectEnclosingPoints(pts[0].addr, cint pts.len, clip, result.addr)
    sdl_assert success, &"Failed to get Sdlrectangle enclosing Sdlpoints {pts}"

proc rect_enclosing_points*(pts: openArray[SdlPointF]; clip: Option[SdlRectF]): SdlRectF =
    let clip = if clip.is_some: (get clip).addr else: nil
    let success = SDL_GetRectEnclosingPointsFloat(pts[0].addr, cint pts.len, clip, result.addr)
    sdl_assert success, &"Failed to get Sdlrectangle enclosing Sdlpoints {pts}"

proc intersection*(r: SdlRect; line: tuple[p1, p2: SdlPoint]): bool =
    SDL_GetRectAndLineIntersection r.addr, line.p1.x.addr, line.p1.y.addr, line.p2.x.addr, line.p2.y.addr

proc intersection*(r: SdlRectF; line: tuple[p1, p2: SdlPointF]): bool =
    SDL_GetRectAndLineIntersectionFloat r.addr, line.p1.x.addr, line.p1.y.addr, line.p2.x.addr, line.p2.y.addr

{.pop.}

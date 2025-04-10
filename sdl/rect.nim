import std/options, common

type
    Point* = object
        x*: int32
        y*: int32
    PointF* = object
        x*: float32
        y*: float32

    Rect* = object
        x*, y*: int32
        w*, h*: int32
    RectF* = object
        x*, y*: float32
        w*, h*: float32

converter to_rect*(r: RectF): Rect  = Rect(x: int32 r.x, y: int32 r.y, w: int32 r.w, h: int32 r.h)
converter to_rectf*(r: Rect): RectF = RectF(x: float32 r.x, y: float32 r.y, w: float32 r.w, h: float32 r.h)

func `$`*(pt: Point | PointF): string = &"({pt.x}, {pt.y})"
func `$`*(r: Rect | RectF): string    = &"({r.x}, {r.y}, {r.w}, {r.h})"

func `==`*(pt1, pt2: Point | PointF): bool = pt1.x == pt2.x and pt1.y == pt2.y
func `==`*(r1, r2: Rect | RectF): bool     = r1.x == r2.x and r1.y == r2.y and r1.w == r2.w and r1.h == r2.h

func point*(x, y: distinct SomeNumber): Point   = Point(x: int32 x, y: int32 y)
func pointf*(x, y: distinct SomeNumber): PointF = PointF(x: float32 x, y: float32 y)

func rect*(x, y, w, h: distinct SomeNumber): Rect   = Rect(x: int32 x, y: int32 y, w: int32 w, h: int32 w)
func rectf*(x, y, w, h: distinct SomeNumber): RectF = RectF(x: float32 x, y: float32 y, w: float32 w, h: float32 h)

func contains*(r: Rect | RectF; pt: Point | PointF): bool =
    (pt.x >= r.x) and (pt.x < r.x + r.w) and
    (pt.y >= r.y) and (pt.y < r.y + r.h)
func contains*(r: Rect; pt: (SomeNumber, SomeNumber) | array[2, SomeNumber]): bool  = contains r, point(pt[0], pt[1])
func contains*(r: RectF; pt: (SomeNumber, SomeNumber) | array[2, SomeNumber]): bool = contains r, pointf(pt[0], pt[1])

func is_empty*(r: Rect | RectF): bool =
    r.w <= 0 or r.h <= 0

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_HasRectIntersection*(A, B: ptr Rect): bool
proc SDL_GetRectIntersection*(A, B, rect: ptr Rect): bool
proc SDL_GetRectUnion*(A, B, result: ptr Rect): bool
proc SDL_GetRectEnclosingPoints*(pts: ptr Point; cnt: cint; clip, result: ptr Rect): bool
proc SDL_GetRectAndLineIntersection*(rect: ptr Rect; X1, Y1, X2, Y2: ptr cint): bool

proc SDL_HasRectIntersectionFloat*(A, B: ptr RectF): bool
proc SDL_GetRectIntersectionFloat*(A, B, result: ptr RectF): bool
proc SDL_GetRectUnionFloat*(A, B, result: ptr RectF): bool
proc SDL_GetRectEnclosingPointsFloat*(pts: ptr PointF; cnt: cint; clip, result: ptr RectF): bool
proc SDL_GetRectAndLineIntersectionFloat*(rect: ptr RectF; X1, Y1, X2, Y2: ptr cfloat): bool
{.pop.}

{.push inline.}

proc has_intersection*[T: Rect | RectF](a, b: T): bool =
    when T is Rect:
        SDL_HasRectIntersection a.addr, b.addr
    else:
        SDL_HasRectIntersectionFloat a.addr, b.addr

proc intersection*[T: Rect | RectF](a, b: T): T =
    when T is Rect:
        SDL_GetRectIntersection a.addr, b.addr, result.addr
    else:
        SDL_GetRectIntersectionFloat a.addr, b.addr, result.addr

proc union*[T: Rect | RectF](a, b: T): T =
    when T is Rect:
        SDL_GetRectUnion a.addr, b.addr, result.addr
    else:
        SDL_GetRectUnionFloat a.addr, b.addr, result.addr

proc rect_enclosing_points*(pts: openArray[Point]; clip: Option[Rect]): Rect =
    let clip = if clip.is_some: (get clip).addr else: nil
    let success = SDL_GetRectEnclosingPoints(pts[0].addr, cint pts.len, clip, result.addr)
    sdl_assert success, &"Failed to get rectangle enclosing points {pts}"

proc rect_enclosing_points*(pts: openArray[PointF]; clip: Option[RectF]): RectF =
    let clip = if clip.is_some: (get clip).addr else: nil
    let success = SDL_GetRectEnclosingPointsFloat(pts[0].addr, cint pts.len, clip, result.addr)
    sdl_assert success, &"Failed to get rectangle enclosing points {pts}"

proc intersection*(r: Rect; line: tuple[p1, p2: Point]): bool =
    SDL_GetRectAndLineIntersection r.addr, line.p1.x.addr, line.p1.y.addr, line.p2.x.addr, line.p2.y.addr

proc intersection*(r: RectF; line: tuple[p1, p2: PointF]): bool =
    SDL_GetRectAndLineIntersectionFloat r.addr, line.p1.x.addr, line.p1.y.addr, line.p2.x.addr, line.p2.y.addr

{.pop.}

import common

type
    Point* = object
        x*, y*: int32 = 0
    FPoint* = object
        x*, y*: float32 = 0.0

    Rect* = object
        x*, y*, w*, h*: int32 = 0
    FRect* = object
        x*, y*, w*, h*: float32 = 0.0

{.push inline.}

func  point*(x, y: SomeNumber = 0): Point    =  Point(x: int32   x, y: int32   y)
func fpoint*(x, y: SomeNumber = 0.0): FPoint = FPoint(x: float32 x, y: float32 y)

func  rect*(x, y, w, h: SomeNumber = 0)  : Rect  =  Rect(x: int32   x, y: int32   y, w: int32   w, h: int32   h)
func frect*(x, y, w, h: SomeNumber = 0.0): FRect = FRect(x: float32 x, y: float32 y, w: float32 w, h: float32 h)
func  rect*(r: FRect): Rect  =  rect(r.x, r.y, r.w, r.h)
func frect*(r: Rect) : FRect = frect(r.x, r.y, r.w, r.h)
func  rect*(r: array[4, SomeNumber]): Rect  =  rect(int32 r[0], int32 r[1], int32 r[2], int32 r[3])
func frect*(r: array[4, SomeNumber]): FRect = frect(float32 r[0], float32 r[1], float32 r[2], float32 r[3])

func in_rect*(pt: Point | FPoint; r: Rect | FRect): bool =
    (pt.x >= r.x) and (pt.x < r.x + r.w) and
    (pt.y >= r.y) and (pt.y < r.y + r.h)
func `in`*(pt: Point | FPoint; r: Rect | FRect): bool    = pt.in_rect r
func `in`*(pt: (SomeNumber, SomeNumber); r: Rect): bool  =  point(pt[0], pt[1]).in_rect r
func `in`*(pt: (SomeNumber, SomeNumber); r: FRect): bool = fpoint(pt[0], pt[1]).in_rect r
func `notin`*(pt: (SomeNumber, SomeNumber) | Point | FPoint; r: Rect | FRect): bool = not (pt in r)

func empty*(r: Rect | FRect): bool = (r.w <= 0) or (r.h <= 0)

{.pop.}

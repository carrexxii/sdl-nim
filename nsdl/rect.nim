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

func point*(x, y: SomeNumber = 0): Point =
    result = Point(x: int32 x, y: int32 y)
func fpoint*(x, y: SomeNumber = 0.0): FPoint =
    result = FPoint(x: float32 x, y: float32 y)

func rect*(x, y, w, h: SomeNumber = 0): Rect =
    result = Rect(x: int32 x, y: int32 y, w: int32 w, h: int32 h)
func frect*(x, y, w, h: SomeNumber = 0.0): FRect =
    result = FRect(x: float32 x, y: float32 y, w: float32 w, h: float32 h)

# TODO

# SDL_FORCE_INLINE SDL_bool SDL_PointInRect(const SDL_Point *p, const SDL_Rect *r)
# {
#     return ( p && r && (p->x >= r->x) && (p->x < (r->x + r->w)) &&
#              (p->y >= r->y) && (p->y < (r->y + r->h)) ) ? SDL_TRUE : SDL_FALSE;
# }
# SDL_FORCE_INLINE SDL_bool SDL_RectEmpty(const SDL_Rect *r)
# {
#     return ((!r) || (r->w <= 0) || (r->h <= 0)) ? SDL_TRUE : SDL_FALSE;
# }
# SDL_FORCE_INLINE SDL_bool SDL_RectsEqual(const SDL_Rect *a, const SDL_Rect *b)
# {
#     return (a && b && (a->x == b->x) && (a->y == b->y) &&
#             (a->w == b->w) && (a->h == b->h)) ? SDL_TRUE : SDL_FALSE;
# }
# extern DECLSPEC SDL_bool SDLCALL SDL_HasRectIntersection(const SDL_Rect * A,
#                                                          const SDL_Rect * B);
# extern DECLSPEC SDL_bool SDLCALL SDL_GetRectIntersection(const SDL_Rect * A,
                                                #    const SDL_Rect * B,
                                                #    SDL_Rect * result);
# extern DECLSPEC int SDLCALL SDL_GetRectUnion(const SDL_Rect * A,
                                        #    const SDL_Rect * B,
                                        #    SDL_Rect * result);
# extern DECLSPEC SDL_bool SDLCALL SDL_GetRectEnclosingPoints(const SDL_Point * points,
#                                                    int count,
#                                                    const SDL_Rect * clip,
#                                                    SDL_Rect * result);
# extern DECLSPEC SDL_bool SDLCALL SDL_GetRectAndLineIntersection(const SDL_Rect *
                                                        #   rect, int *X1,
                                                        #   int *Y1, int *X2,
                                                        #   int *Y2);
# SDL_FORCE_INLINE SDL_bool SDL_PointInRectFloat(const SDL_FPoint *p, const SDL_FRect *r)
# {
#     return ( p && r && (p->x >= r->x) && (p->x < (r->x + r->w)) &&
#              (p->y >= r->y) && (p->y < (r->y + r->h)) ) ? SDL_TRUE : SDL_FALSE;
# }
# SDL_FORCE_INLINE SDL_bool SDL_RectEmptyFloat(const SDL_FRect *r)
# {
#     return ((!r) || (r->w <= 0.0f) || (r->h <= 0.0f)) ? SDL_TRUE : SDL_FALSE;
# }
# SDL_FORCE_INLINE SDL_bool SDL_RectsEqualEpsilon(const SDL_FRect *a, const SDL_FRect *b, const float epsilon)
# {
#     return (a && b && ((a == b) ||
#             ((SDL_fabsf(a->x - b->x) <= epsilon) &&
#             (SDL_fabsf(a->y - b->y) <= epsilon) &&
#             (SDL_fabsf(a->w - b->w) <= epsilon) &&
#             (SDL_fabsf(a->h - b->h) <= epsilon))))
#             ? SDL_TRUE : SDL_FALSE;
# }
# SDL_FORCE_INLINE SDL_bool SDL_RectsEqualFloat(const SDL_FRect *a, const SDL_FRect *b)
# {
#     return SDL_RectsEqualEpsilon(a, b, SDL_FLT_EPSILON);
# }
# extern DECLSPEC SDL_bool SDLCALL SDL_HasRectIntersectionFloat(const SDL_FRect * A,
#                                                       const SDL_FRect * B);
# extern DECLSPEC SDL_bool SDLCALL SDL_GetRectIntersectionFloat(const SDL_FRect * A,
                                                    # const SDL_FRect * B,
                                                    # SDL_FRect * result);
# extern DECLSPEC int SDLCALL SDL_GetRectUnionFloat(const SDL_FRect * A,
                                            # const SDL_FRect * B,
                                            # SDL_FRect * result);
# extern DECLSPEC SDL_bool SDLCALL SDL_GetRectEnclosingPointsFloat(const SDL_FPoint * points,
                                                    # int count,
                                                    # const SDL_FRect * clip,
                                                    # SDL_FRect * result);
# extern DECLSPEC SDL_bool SDLCALL SDL_GetRectAndLineIntersectionFloat(const SDL_FRect *
                                                        #    rect, float *X1,
                                                        #    float *Y1, float *X2,
                                                        #    float *Y2);

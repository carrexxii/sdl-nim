import common

const CachelineSize* = 128'i32

{.push importc, cdecl, dynlib: SdlLib.}
proc SDL_GetNumLogicalCPUCores*(): cint
proc SDL_GetCPUCacheLineSize*(): cint

proc SDL_HasAltiVec*(): bool
proc SDL_HasMMX*(): bool
proc SDL_HasSSE*(): bool
proc SDL_HasSSE2*(): bool
proc SDL_HasSSE3*(): bool
proc SDL_HasSSE41*(): bool
proc SDL_HasSSE42*(): bool
proc SDL_HasAVX*(): bool
proc SDL_HasAVX2*(): bool
proc SDL_HasAVX512F*(): bool
proc SDL_HasARMSIMD*(): bool
proc SDL_HasNEON*(): bool
proc SDL_HasLSX*(): bool
proc SDL_HasLASX*(): bool

proc SDL_GetSystemRAM*(): cint
proc SDL_GetSIMDAlignment*(): csize_t
{.pop.}

{.push inline.}

proc get_logical_cpu_core_count*(): int32 = int32 SDL_GetNumLogicalCPUCores()
proc get_cpu_cache_line_size*(): int32    = int32 SDL_GetCPUCacheLineSize()

proc cpu_has_alti_vec*(): bool = SDL_HasAltiVec()
proc cpu_has_mmx*(): bool      = SDL_HasMMX()
proc cpu_has_sse*(): bool      = SDL_HasSSE()
proc cpu_has_sse2*(): bool     = SDL_HasSSE2()
proc cpu_has_sse3*(): bool     = SDL_HasSSE3()
proc cpu_has_sse41*(): bool    = SDL_HasSSE41()
proc cpu_has_sse42*(): bool    = SDL_HasSSE42()
proc cpu_has_avx*(): bool      = SDL_HasAVX()
proc cpu_has_avx2*(): bool     = SDL_HasAVX2()
proc cpu_has_avx512f*(): bool  = SDL_HasAVX512F()
proc cpu_has_arm_simd*(): bool = SDL_HasARMSIMD()
proc cpu_has_neon*(): bool     = SDL_HasNEON()
proc cpu_has_lsx*(): bool      = SDL_HasLSX()
proc cpu_has_lasx*(): bool     = SDL_HasLASX()

proc get_system_ram*(): int32    = int32 SDL_GetSystemRAM()
proc get_simd_alignment*(): uint = uint SDL_GetSystemRAM()

{.pop.}

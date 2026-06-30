#pragma once
/*
 * GCC-ism polyfills for building cadical, symfpu, and bitwuzla with MSVC.
 * Force-included (/FI) before any project header.
 *
 * Implementation note: newer MSVC (19.5x / VS 2026 v18) recognizes some
 * __builtin_* names as intrinsic functions, and defining a function with such
 * a name is error C2169 ("intrinsic function, cannot be defined"). So we never
 * define a function named __builtin_*; we implement each under a bzla_* name and
 * #define the __builtin_* spelling to redirect. A macro preempts any intrinsic,
 * so this is correct on every MSVC version.
 */
#ifdef _MSC_VER

/* GCC's __PRETTY_FUNCTION__ -> MSVC's __FUNCSIG__ (full signature string). */
#ifndef __PRETTY_FUNCTION__
#define __PRETTY_FUNCTION__ __FUNCSIG__
#endif
/* cadical uses __attribute__ only for compile-time annotations
 * (format-string checking; a .preinit_array section in mobical which is not
 * built here). Dropping them is safe. */
#ifndef __attribute__
#define __attribute__(A)
#endif

#include <intrin.h>
#include <math.h>

#define __builtin_expect(c, v) (c)
#define __builtin_unreachable() __assume(0)
/* Prefetch is a perf hint; a no-op is correct (just slower). Variadic to accept
 * GCC's 1..3 argument forms. */
#define __builtin_prefetch(...) ((void)0)

/* Count leading zeros. */
static __forceinline int
bzla_clz(unsigned x)
{
  unsigned long r;
  _BitScanReverse(&r, x);
  return 31 - (int)r;
}
static __forceinline int
bzla_clzll(unsigned long long x)
{
  unsigned long r;
  _BitScanReverse64(&r, x);
  return 63 - (int)r;
}
/* Count trailing zeros. */
static __forceinline int
bzla_ctz(unsigned x)
{
  unsigned long r;
  _BitScanForward(&r, x);
  return (int)r;
}
static __forceinline int
bzla_ctzll(unsigned long long x)
{
  unsigned long r;
  _BitScanForward64(&r, x);
  return (int)r;
}
/* Population count. */
static __forceinline int
bzla_popcount(unsigned x)
{
  return (int)__popcnt(x);
}
static __forceinline int
bzla_popcountll(unsigned long long x)
{
  return (int)__popcnt64(x);
}

/* Redirect the GCC __builtin_* spellings to the bzla_* implementations above.
 * The macro preempts any MSVC intrinsic of the same name (no C2169, since we
 * never define a function named __builtin_*). Guarded so we don't redefine if
 * some other header already provided one. */
#ifndef __builtin_clz
#define __builtin_clz(x) bzla_clz(x)
#endif
#ifndef __builtin_clzll
#define __builtin_clzll(x) bzla_clzll(x)
#endif
#ifndef __builtin_ctz
#define __builtin_ctz(x) bzla_ctz(x)
#endif
#ifndef __builtin_ctzll
#define __builtin_ctzll(x) bzla_ctzll(x)
#endif
#ifndef __builtin_popcount
#define __builtin_popcount(x) bzla_popcount(x)
#endif
#ifndef __builtin_popcountll
#define __builtin_popcountll(x) bzla_popcountll(x)
#endif
/* symfpu uses __builtin_fmaf for fused multiply-add; MSVC has C99 fmaf. */
#ifndef __builtin_fmaf
#define __builtin_fmaf(a, b, c) fmaf((a), (b), (c))
#endif

#endif /* _MSC_VER */

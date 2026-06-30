# bitwuzla-msvc

**This is a fork of [bitwuzla/bitwuzla](https://github.com/bitwuzla/bitwuzla).**
It adds **only the glue needed to build Bitwuzla as a static MSVC library for
Windows** — `cl.exe` with the `x64-windows-static-md` triplet (static GMP/MPFR + dynamic `/MD` CRT).
There are no functional changes to Bitwuzla itself; the
rest tracks upstream `main` via regular rebases.

Upstream's Windows support is MSYS2/MinGW (GCC) only — it does not build with
MSVC, so this fork is the MSVC build path.

## What's added

All additions are **additive**: new files that don't touch upstream sources or
`meson.build`, so they survive upstream merges.

- `msvc_shim/{msvc_compat.h,unistd.h}` — `__builtin_*` / `__attribute__` / POSIX polyfills, force-included via `/FImsvc_compat.h`.
- `msvc_native.ini` — meson native file applying the shim to every TU (incl. subprojects cadical/symfpu).
- `msvc_env.bat`, `build_msvc.bat`, `test_msvc.bat`, `assemble_msvc_zip.bat` — env / build / test / package scripts.
- `ci/triplets/x64-windows-static-md.cmake` — vcpkg triplet (release-only static-md).
- `.github/workflows/build-msvc.yml` — `workflow_dispatch`-only CI: build, test, ship the release zip.

Three minimal upstream source fixes are required for MSVC — correct C++ hygiene
MSVC enforces but GCC/Clang don't (latent upstream):

- `src/util/integer.h` — `#include <string>` (gmpxx uses `std::string` without including it).
- `src/main/time_limit.cpp` — `#ifndef _MSC_VER` around the pthread / glibc-condvar workaround.
- `include/bitwuzla/cpp/sat_solver.h` + `src/api/cpp/bitwuzla.cpp` — out-of-line `SatSolver::register_propagator` so `unique_ptr<SatPropagator>` is destroyed where the type is complete.

## Getting the build

The release artifact — `Bitwuzla-Win64-x86_64-msvc-static.zip` (six bitwuzla
static archives + `gmp.lib` / `mpfr.lib`) — is produced by the manually
dispatched [**Build MSVC static**](.github/workflows/build-msvc.yml) workflow
(_Actions_ → _Build MSVC static_ → _Run workflow_). vcpkg deps are cached, so
re-runs skip the ~35 min dependency build.

---

_The remainder of this README is upstream Bitwuzla's, unchanged._

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![CI](https://github.com/bitwuzla/bitwuzla/actions/workflows/ci.yml/badge.svg?branch=main)

# Bitwuzla

Bitwuzla is a Satisfiability Modulo Theories (SMT) solver for the theories
of fixed-size bit-vectors, floating-point arithmetic, arrays, uninterpreted
functions and their combinations.

If you are using Bitwuzla in your work, or if you incorporate it into software
of your own, we invite you to send us a description and link to your
project/software, so that we can link it as third party
application on [bitwuzla.github.io](https://bitwuzla.github.io).

## Website

More information about Bitwuzla is available at: https://bitwuzla.github.io

## Documentation

Documentation for Bitwuzla is available at: https://bitwuzla.github.io/docs

## Download

The latest version of Bitwuzla is available on GitHub:
https://github.com/bitwuzla/bitwuzla

## Build and Installation Instructions

Bitwuzla can be built on Linux, macOS. For Windows, it can be built using
MSYS2 or cross-compiled via Mingw-w64.

For detailed build and installation instructions
see [docs/install.rst](docs/install.rst).

## Citing Bitwuzla

A [comprehensive system description](https://bitwuzla.github.io/data/NiemetzP-CAV23.pdf)
of Bitwuzla was presented and published at CAV 2023.
Please use the following Bibtex for citing Bitwuzla.

```
@inproceedings{DBLP:conf/cav/NiemetzP23,
  author       = {Aina Niemetz and
                  Mathias Preiner},
  editor       = {Constantin Enea and
                  Akash Lal},
  title        = {Bitwuzla},
  booktitle    = {Computer Aided Verification - 35th International Conference, {CAV}
                  2023, Paris, France, July 17-22, 2023, Proceedings, Part {II}},
  series       = {Lecture Notes in Computer Science},
  volume       = {13965},
  pages        = {3--17},
  publisher    = {Springer},
  year         = {2023},
  url          = {https://doi.org/10.1007/978-3-031-37703-7\_1},
  doi          = {10.1007/978-3-031-37703-7\_1},
  timestamp    = {Fri, 21 Jul 2023 17:55:59 +0200},
  biburl       = {https://dblp.org/rec/conf/cav/NiemetzP23.bib},
  bibsource    = {dblp computer science bibliography, https://dblp.org}
}
```

## Contributing

Please refer to our [contributing guidelines](CONTRIBUTING.md).

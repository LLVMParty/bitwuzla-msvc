# vcpkg triplet: static libraries + dynamic CRT (/MD).
# Matches the Rust smt-server consumer's /MD linkage -- no CRT mismatch, no
# GMP/MPFR DLL deps at runtime. The stock x64-windows-static triplet is /MT and
# would mismatch the /MD consumer at link time.
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

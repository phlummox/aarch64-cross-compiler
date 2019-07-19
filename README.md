# AArch64 cross-toolchain (from x86\_64) [![Docker Build Status](https://img.shields.io/travis/phlummox/docker-aarch64-cross-compiler.svg?label=Docker%20build)](https://travis-ci.org/phlummox/docker-aarch64-cross-compiler)

Build of a cross-compiler toolchain from x86\_64 to aarch64, using
[Crosstool-NG][ct-ng].

[ct-ng]: https://crosstool-ng.github.io/

## Re-building

Building the toolchain actually shouldn't take that long on a
decent desktop machine (say, 8 cores, 8GB RAM) -- well under an hour.
But on the Travis infrastructure, it seems to exceed their 50-minute
limit. Which means the build has to be done in stages (which is
fine, Crosstool-NG lets you save state between build steps, stop
and re-start), and saving and loading all the state from those stages
is slow, and all in all it's a bit unpleasant.

So the Dockerfile splits the main Crosstool-NG build process into four stages,
to avoid exceeding Travis's limits. But if you want to re-build locally,
you could just replace all the Dockerfile stages starting
"build\_aarch64\_ct..." with a single stage containing the instruction

```
RUN CT_DEBUG_CT_SAVE_STEPS=y ct-ng build.$(nproc) V=1
```

and that should build much, much quicker than the Dockerfile given
here.

The easiest way to get stages into Travis's cache
seems to be to do builds on a dedicated branch.
Check out a temporary git branch, we'll call it "build" (with
`git checkout -b build`), make some random change, push it
(with `git push -u origin build`), and then delete
it once Travis has run a build. The `.travis.yml` file 
saves the first few stages of the build into Travis's caches,
which is usually faster than pulling them from the Docker registry.

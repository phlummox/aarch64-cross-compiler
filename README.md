# AArch64 cross-toolchain (from x86\_64) [![Docker Build Status](https://img.shields.io/travis/phlummox/aarch64-cross-compiler.svg?label=Docker%20build)](https://travis-ci.org/phlummox/aarch64-cross-compiler)

Build of a cross-compiler toolchain from x86\_64 to aarch64, using
[Crosstool-NG][ct-ng], within an [Alpine Linux][alpine] Docker container.
Docker images containing the built toolchain are available from
[Docker Hub][docker-hub], and just the built toolchain from the
"[Releases][releases]" page.

[ct-ng]: https://crosstool-ng.github.io/
[alpine]: https://alpinelinux.org/ 
[docker-hub]: https://hub.docker.com/r/phlummox/aarch64-cross-compiler/
[releases]: https://github.com/phlummox/aarch64-cross-compiler/releases

## Running the cross-compiler

It would be nice to have linked all the executables in the toolchain
statically, but that led to build errors. So the tools must be run
in a system with the [musl libc][musl] shared libraries in the library
search path.

[musl]: https://www.musl-libc.org/

If you're on such a system, you can just untar the toolchain somewhere -
call it /path/to/ct - prepend /path/to/ct to your PATH, and:

```
$ echo 'int main(){return 42;}' > c_test.c
$ gcc -static -o c_test c_test.c
```

The toolchain is also available in a Docker image, so if you're not
on such a system, but have Docker installed, you could run:

```
$ docker run --rm -v $PWD:/work -w /work phlummox/aarch64-cross-compiler:latest gcc -static -o c_test c_test.c
```

(This mounts your current directory within a Docker container at the path
`/work`, and compiles `c_test.c` there using the latest version of the Docker image.)

To test the resulting binaries while still on an x86\_64 system, you can use
the `qemu-aarch64` program (on Ubuntu, this is available from the `qemu-user`
package):

```
$ sudo apt-get install qemu-user
$ qemu-aarch64 ./c_test
$ echo $?
42
```


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

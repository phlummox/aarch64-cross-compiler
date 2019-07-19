
# install CT_NG
FROM alpine:edge as base

ARG ct_prefix=/opt/ct
ENV ct_prefix=$ct_prefix


FROM base as build_base
MAINTAINER phlummox <phlummox2@gmail.com>

RUN \
  apk update && \
  apk add \
    alpine-sdk      \
    autoconf        \
    automake        \
    bash            \
    bison           \
    cmake           \
    flex            \
    gawk            \
    gettext-dev     \
    git             \
    gmp-dev         \
    help2man        \
    isl-dev         \
    libtool         \
    mpc1-dev        \
    mpfr-dev        \
    musl-dev        \
    ncurses-dev     \
    pkgconf         \
    python-dev      \
    sudo            \
    texinfo         \
    wget            \
    xz              \
    zlib-dev

# create a user
ARG user_uid=1000
ARG user_gid=1000

ENV user_uid=$user_uid
ENV user_gid=$user_gid

RUN : "adding user" && \
  addgroup -g $user_gid user && \
  adduser  -D -G user -u $user_uid -g '' user && \
  echo '%user ALL=(ALL) NOPASSWD:ALL' | tee -a /etc/sudoers

USER user
ENV HOME=/home/user
WORKDIR $HOME

# location of the ct-ng tool
ARG CTNG_PREFIX=/opt/ct-ng
ENV ctng_prefix=$CTNG_PREFIX

######################
# build the ct-ng tool
######################
FROM build_base as build_ct_ng

ARG crosstool_version=1.24.0
ENV crosstool_url=http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-${crosstool_version}.tar.xz

RUN \
  mkdir -p $HOME/work  && \
  cd $HOME/work && \
  wget $crosstool_url && \
  tar xf crosstool-ng-${crosstool_version}.tar.xz && \
  cd $HOME/work/crosstool-ng-${crosstool_version} && \
  ./configure --prefix="${ctng_prefix}" && \
  make -j$(nproc) && \
  sudo make install && \
  cd .. && \
  rm -rf cross*

##################################
# build the actual cross-toolchain
##################################
FROM build_base as build_aarch64_ct

COPY --from=build_ct_ng $ctng_prefix $ctng_prefix/
COPY defconfig $HOME/

ENV PATH="${ctng_prefix}/bin:${PATH}"


# prepare for build using the supplied
# defconfig configuration
RUN \
  mkdir -p $HOME/src $HOME/work/ct-build   && \
  mv defconfig $HOME/work/ct-build      && \
  cd $HOME/work/ct-build                && \
  ct-ng defconfig                       && \
  : "destination directory"             && \
  sudo mkdir $ct_prefix                 && \
  sudo chown user:user $ct_prefix

WORKDIR $HOME/work/ct-build

RUN : "show steps to be done - handy for debugging" && \
      ct-ng list-steps | tee steps                  && \
    : "fetch sources"                               && \
      ct-ng source                                  && \
      rm build.log

WORKDIR $HOME/work/ct-build

RUN CT_DEBUG_CT_SAVE_STEPS=y ct-ng build.$(nproc) V=1 STOP=companion_libs_for_host

##################################
# part 2
##################################
FROM build_aarch64_ct as build_aarch64_ct_pt2

RUN CT_DEBUG_CT_SAVE_STEPS=y ct-ng build.$(nproc) V=1 RESTART=binutils_for_host STOP=libc_start_files; tail -n 50 build.log; true

##################################
# part 3
##################################
FROM build_aarch64_ct_pt2 as build_aarch64_ct_pt3

RUN CT_DEBUG_CT_SAVE_STEPS=y ct-ng build.$(nproc) V=1 RESTART=cc_core_pass_2 STOP=libc_main; tail -n 50 build.log; true

##################################
# part 4
##################################
FROM build_aarch64_ct_pt3 as build_aarch64_ct_pt4

RUN CT_DEBUG_CT_SAVE_STEPS=y ct-ng build.$(nproc) V=1 RESTART=cc_for_build ; tail -n 50 build.log; true

#############
# "runtime"
#############

FROM base as ct_base

COPY --from=build_aarch64_ct_pt4 $ct_prefix $ct_prefix

FROM ct_base as ct

USER root
WORKDIR /work
ARG quad=aarch64-unknown-linux-musl
ENV PATH=/opt/ct/$quad/bin:$PATH
ENV HOME=/root

RUN \
  cd $ct_prefix/$quad/bin; for prog in *; do ln -s ${prog} ${prog#$quad-}; done
  

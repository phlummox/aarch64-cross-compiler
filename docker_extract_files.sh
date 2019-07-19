#!/usr/bin/env bash

set -euo pipefail

source util_funcs.sh

if [ "$#" -ne 2 ]; then
  echo 'expected 2 args: stage-to-use, path-to-extract' >&2
  exit 1
fi

set -x

col_msg "$0: extracting toolchain from image"

stage_to_use_idx=$(($1 - 1))
path_to_extract=$2
img=$IMG
stages=( $(cat stages.txt) );
stage_to_use=${stages[$stage_to_use_idx]}

ctr_id=$(docker run --detach $img:$stage_to_use)
set -x
tmpdir=$(mktemp -d --tmpdir=.)
docker cp $ctr_id:$path_to_extract $tmpdir/
#tar cvf aarch64-ct-${VERSION}.tar.xz --xz /opt/ct  
set +x



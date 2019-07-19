#!/usr/bin/env bash

set -euo pipefail

source util_funcs.sh

set -x

if [ "$#" -ne 2 ]; then
  echo 'expected 2 args: stage-to-use, path-to-extract' >&2
  exit 1
fi

col_msg "$0: extracting toolchain from image"

stage_to_use_idx=$(($1 - 1))
path_to_extract=$2
img=$IMG
stages=( $(cat stages.txt) );
stage_to_use=${stages[$stage_to_use_idx]}

# strip leading slash
stripped_path=$(echo $path_to_extract | sed 's|^/||')

ctr_id=$(docker run --name ct-extractor --detach $img:$stage_to_use)
tmpdir=$(mktemp -d --tmpdir=.)
set -x
mkdir -p $tmpdir/$(dirname $path_to_extract)
docker cp $ctr_id:$path_to_extract $tmpdir/$path_to_extract
# use pv to avoid lack of output on Travis
fakeroot tar cvf - --xz -C $tmpdir $stripped_path | pv > aarch64-ct-${VERSION}.tar.xz
docker stop $ctr_id
docker rm $ctr_id
set +x
rm -rf $tmpdir


#!/usr/bin/env bash

set -euo pipefail

source util_funcs.sh

if [ "$#" -ne 1 ]; then
  echo 'expected 1 arg, stage to run to' >&2
  exit 1
fi

num_stages_to_build=$1
img=$IMG
stages=( $(cat stages.txt) );

col_msg "$0: building docker stages"

for ((i=0; i < num_stages_to_build; i=i+1)); do
  curr_stage=${stages[$i]}
  caches_needed=""
  for ((j=0; j <= i; j=j+1)); do
    cache_stage=${stages[$j]}
    caches_needed="$caches_needed --cache-from=$img:${cache_stage}"
  done
  col_msg "- try building stage $curr_stage"
  target="--target $curr_stage"
  set -x
  docker build $target \
       $caches_needed \
       --tag $img:$curr_stage .
  set +x
done


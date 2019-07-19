#!/usr/bin/env bash

set -euo pipefail

source util_funcs.sh

if [ "$#" -ne 2 ]; then
  echo 'expected 2 args: from-stage, to-stage' >&2
  exit 1
fi

from_idx=$(($1 - 1))
to_idx=$2 # one-past-end
img=$IMG
stages=( $(cat stages.txt) );

col_msg "$0: building docker stages"

for ((i=from_idx; i < to_idx; i=i+1)); do
  curr_stage=${stages[$i]}
  caches_needed=""
  for ((j=from_idx; j <= i; j=j+1)); do
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


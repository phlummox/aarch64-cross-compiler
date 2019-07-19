#!/usr/bin/env bash

set -euo pipefail

source util_funcs.sh

if [ "$#" -ne 4 ]; then
  echo 'expected 4 args: cache dir, from-stage, to-stage, # stages to cache' >&2
  exit 1
fi

cache_dir=$1
from_idx=$(($2 - 1))
to_idx=$3 # one-past-end
num_stages_to_cache=$4
stages=( $(cat stages.txt) );
img=$IMG

col_msg "$0: loading docker images from travis cache"

for ((i=0; i < to_idx && i < num_stages_to_cache ; i=i+1)); do
  curr_stage=${stages[$i]}
  stage_cache_file="$cache_dir/${curr_stage}.tar.gz"
  if [ -f "${stage_cache_file}" ]; then
    col_msg "- loading stage $curr_stage from travis cache"
    set -x
    gunzip -c ${stage_cache_file} | docker load;
    set +x
    docker inspect --format="{{.ID}}" $img:$curr_stage > "${curr_stage}.id.txt"
  fi
done


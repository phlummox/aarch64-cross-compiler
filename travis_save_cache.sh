#!/usr/bin/env bash

set -euo pipefail

source util_funcs.sh

if [ "$#" -ne 4 ]; then
  echo 'expected 4 args: cache dir, from-stage, to-stage, stages to cache' >&2
  exit 1
fi

cache_dir=$1
from_idx=$(($2 - 1))
to_idx=$3 # one-past-end
num_stages_to_cache=$4
img=$IMG
stages=( $(cat stages.txt) );

col_msg "$0: saving docker images to travis cache"

mkdir -p $cache_dir

for ((i=from_idx; i < to_idx && i < num_stages_to_cache; i=i+1)); do
  curr_stage=${stages[$i]}

  cached_id=""
  if [[ -f ${curr_stage}.id.txt ]] ; then
    cached_id=$(cat $curr_stage.id.txt)
  fi

  built_id=$(docker inspect --format="{{.ID}}" $img:$curr_stage)

  if [[ "$cached_id" != "$built_id" ]] ; then
    cache_file="$cache_dir/${curr_stage}.tar.gz"
    col_msg "- saving stage $curr_stage to file $cache_file"
    set -x
    docker save $img:$curr_stage | gzip > ${cache_file};
    set +x
  else
    col_msg "- no change in stage $curr_stage, not saving to cache"
  fi
done

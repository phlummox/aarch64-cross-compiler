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

col_msg "$0: pulling docker images from registry"

for ((i=from_idx ; i < to_idx; i=i+1)); do
  curr_stage=${stages[$i]}
  col_msg "- try fetching stage $curr_stage"
  set -x
  docker pull $img:$curr_stage || true
  set +x
done


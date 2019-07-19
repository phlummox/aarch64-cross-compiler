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

col_msg "$0: pulling docker images from registry"

for ((i=0; i < num_stages_to_build; i=i+1)); do
  curr_stage=${stages[$i]}
  col_msg "- try fetching stage $curr_stage"
  set -x
  docker pull $img:$curr_stage || true
  set +x
done


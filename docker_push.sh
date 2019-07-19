#!/usr/bin/env bash

set -euo pipefail

source util_funcs.sh

if [ "$#" -ne 3 ]; then
  echo 'expected 3 args: from-stage, to-stage, version-tag' >&2
  exit 1
fi

from_idx=$(($1-1))
to_idx=$2 # one-past-end
ct_version=$3
img=$IMG
stages=( $(cat stages.txt) );

col_msg "$0: pushing docker images to registry"

col_msg "- logging in"
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin
col_msg "- result of login: $?"

for ((i=from_idx; i < to_idx; i=i+1)); do
  curr_stage=${stages[$i]}

  cached_id=""
  if [[ -f "${curr_stage}.id.txt" ]] ; then
    cached_id=$(cat "$curr_stage.id.txt")
  fi

  built_id=$(docker inspect --format="{{.ID}}" $img:$curr_stage)

  if [[ "$cached_id" != "$built_id" ]] ; then
    col_msg "- pushing stage $curr_stage"
    set -x
    docker push $img:$curr_stage
    set +x
  else
    col_msg "- no change in $img:$curr_stage, not pushing"
  fi
done

s=$((to_idx - 1))
last_stage_run=${stages[$s]}

if [[ "${last_stage_run}" == "ct" ]] ; then
  col_msg "- tagging stage 'ct' as 'latest' and '${ct_version}'"
  docker tag $img:ct $img:latest
  docker push $img:latest
  docker tag $img:ct $img:${ct_version}
  docker push $img:${ct_version}
fi

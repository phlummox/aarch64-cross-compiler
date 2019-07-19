#!/usr/bin/env bash

set -euo pipefail

source util_funcs.sh

if [ "$#" -ne 2 ]; then
  echo 'expected 2 args: num stages to run, current version to tag' >&2
  exit 1
fi

run_to_stage=$1
ct_version=$2
img=$IMG
stages=( $(cat stages.txt) );

col_msg "$0: pushing docker images to registry"

col_msg "- logging in"
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin
col_msg "- result of login: $?"

  
for ((i=0; i < run_to_stage; i=i+1)); do
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

s=$((run_to_stage - 1))
last_stage_run=${stages[$s]}

if [[ "${last_stage_run}" == "ct" ]] ; then
  col_msg "- tagging stage 'ct' as 'latest' and '${ct_version}'"
  docker tag $img:ct $img:latest
  docker push $img:latest
  docker tag $img:ct $img:${ct_version}
  docker push $img:${ct_version}
fi
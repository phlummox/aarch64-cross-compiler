#!/usr/bin/env bash

source util_funcs.sh

final_stage=$(tail -n 1 stages.txt)

col_msg "$0: call toolchain"

set -x
echo 'int main(){return 42;}' > c_test.c
docker run --rm  -v ${PWD}:/work -w /work phlummox/aarch64-cross-compiler:$final_stage aarch64-unknown-linux-musl-gcc -static -o c_test c_test.c
./c_test
result=$?
set +x

echo $result

  
#for ((i=0; i < run_to_stage; i=i+1)); do
#  curr_stage=${stages[$i]}
#
#  cached_id=""
#  if [[ -f "${curr_stage}.id.txt" ]] ; then
#    cached_id=$(cat "$curr_stage.id.txt")
#  fi
#
#  built_id=$(docker inspect --format="{{.ID}}" $img:$curr_stage)
#
#  if [[ "$cached_id" != "$built_id" ]] ; then
#    col_msg "- pushing stage $curr_stage"
#    set -x
#    docker push $img:$curr_stage
#    set +x
#  else
#    col_msg "- no change in $img:$curr_stage, not pushing"
#  fi
#done
#
#s=$((run_to_stage - 1))
#last_stage_run=${stages[$s]}
#
#if [[ "${last_stage_run}" == "ct" ]] ; then
#  col_msg "- tagging stage 'ct' as 'latest' and '${ct_version}'"
#  docker tag $img:ct $img:latest
#  docker push $img:latest
#  docker tag $img:ct $img:${ct_version}
#  docker push $img:${ct_version}
#fi

#!/usr/bin/env bash

source util_funcs.sh

final_stage=$(tail -n 1 stages.txt)

col_msg "$0: call toolchain"

set -x
echo 'int main(){return 42;}' > c_test.c
docker run --rm  -v ${PWD}:/work -w /work phlummox/aarch64-cross-compiler:$final_stage gcc -static -o c_test c_test.c
qemu-aarch64 ./c_test
result=$?
set +x

echo $result
if ((result != 42)) ; then
  echo "failed!"
  exit 1
fi


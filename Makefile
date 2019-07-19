
.PHONY: build

IMG=phlummox/aarch64-cross-compiler
NUM_STAGES_TO_BUILD=8

PULL_FIRST=1

build:
	if [ $(PULL_FIRST) ]; IMG=$(IMG) ./docker_pull.sh $(NUM_STAGES_TO_BUILD); fi
	IMG=$(IMG) ./docker_build.sh $(NUM_STAGES_TO_BUILD)



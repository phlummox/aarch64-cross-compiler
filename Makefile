
.PHONY: build

IMG=phlummox/aarch64-cross-compiler
FROM_STAGE=9
TO_STAGE=9
PULL_FIRST=1

build:
	if [ $(PULL_FIRST) -eq 1 ] ; then \
	  IMG=$(IMG) ./docker_pull.sh 1 $(TO_STAGE) ;\
	fi
	IMG=$(IMG) ./docker_build.sh $(FROM_STAGE) $(TO_STAGE)



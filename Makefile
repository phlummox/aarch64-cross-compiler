
.PHONY: build

IMG=phlummox/aarch64-cross-compiler
FROM_STAGE=1
TO_STAGE=9
DO_PULL=1
DO_BUILD=1

build:
	if [ $(DO_PULL) -eq 1 ] ; then \
	  IMG=$(IMG) ./docker_pull.sh $(FROM_STAGE) $(TO_STAGE) ;\
	fi
	if [ $(DO_BUILD) -eq 1 ] ; then \
		IMG=$(IMG) ./docker_build.sh $(FROM_STAGE) $(TO_STAGE) ;\
	fi



###========================================================================
### An extendible Makefile for Docker
###
### The goal is to provide a set of common targets for Docker based
### projects, that can easily be overriden.
###
### Targets:
###
###   - init:    install/update dock.mk accordingly
###
###   - exec:    execute a given command in a given container
###
###   - run:     run a container of the current image
###
###   - build:   create an image for the current Dockerfile
###              automatically tagged
###
###   - publish: publish the current tag of the image to
###              the internal docker hub
###
###   - clean:   removes all local images
###
###========================================================================
.PHONY: all init build publish clean exec
.PHONY: dockmk_build dockmk_publish dockmk_clean dockmk_exec
.PHONY: dockmk_build-latest dockmk_publish-latest

## Checks
###========================================================================
ifndef PROJECT
  $(error PROJECT should be defined)
endif

ifndef TEAM
  $(error TEAM should be defined)
endif

ifndef REGISTRY
  $(error REGISTRY should be defined)
endif

## Settings
## ========================================================================
DOCKERFILE ?= .

RUN_OPTS   ?= --rm -ti
EXEC_OPTS  ?= -ti
BUILD_OPTS ?=
CMD        ?= /bin/sh
ARGS       ?=

## Internal Definitions
## ========================================================================
DOCKMK          := dock.mk
DOCKER          := $(shell docker info >/dev/null 2>&1 && echo "docker" || echo "sudo docker")
GIT_BRANCH      := $(shell git rev-parse --abbrev-ref HEAD 2> /dev/null)
GIT_COMMIT      := $(shell git rev-parse --short HEAD 2> /dev/null)
TAG             := $(GIT_BRANCH).$(GIT_COMMIT)
IMAGE_NAME      := $(REGISTRY)/$(TEAM)/$(PROJECT):$(TAG)

## Targets
## ========================================================================

# This target is required by all Make files including dock.mk. It allows
# those Make files to override it and define which targets will be executed
# when running Make without explicit targets (i.e. make).
all::

init: ; @true

exec:: | dockmk_exec
dockmk_exec::
	$(DOCKER) exec $(EXEC_OPTS) $(NAME) $(CMD)

run:: | dockmk_run
dockmk_run::
	$(DOCKER) run $(RUN_OPTS) $(IMAGE_TAG) $(ARGS)

kill:: | dockmk_kill
dockmk_kill::
	$(DOCKER) kill $(NAME)

build:: | dockmk_build
dockmk_build::
	$(DOCKER) build $(BUILD_OPTS) -t $(IMAGE_TAG) $(DOCKERFILE)

publish:: | dockmk_publish
dockmk_publish::
	$(DOCKER) push $(ENDPOINT_TAG)

clean:: | dockmk_clean
dockmk_clean::
	rm -f dock.mk
	rm -f .dockmk-vsn-*
	$(DOCKER) rmi -f $(IMAGE_TAG) $(IMAGE_LATEST)

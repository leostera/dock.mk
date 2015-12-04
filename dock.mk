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
###   - build:   create an image for the current Dockerfile
###              automatically tagged
###
###   - publish: publish the current tag of the image to
###              the internal docker hub
###
###   - clean:   removes all local images
###
###
### Author(s):  Fred DevOps    <devops.fred.e@klarna.com>
###             Leandro Ostera <leandro.ostera@klarna.com>
###
### Based on base.mk
###
### Copyright (c) 2015 Klarna
###========================================================================
.PHONY: all init build publish clean exec
.PHONY: dockmk_build dockmk_publish dockmk_clean dockmk_exec
.PHONY: dockmk_build-latest dockmk_publish-latest

ifndef PROJECT
  $(error PROJECT should be defined)
endif

ifndef REGISTRY
  $(error REGISTRY should be defined)
endif

## Settings
## ========================================================================
DOCKERFILE ?= .

EXEC_OPTS  ?= --rm -ti
CMD				 ?= /bin/sh

## Internal Definitions
## ========================================================================
DOCKMK          := dock.mk
DOCKER          := $(shell docker info >/dev/null 2>&1 && echo "docker" || echo "sudo docker")
GIT_BRANCH      := $(shell git rev-parse --abbrev-ref HEAD 2> /dev/null)
GIT_COMMIT      := $(shell git rev-parse --short HEAD 2> /dev/null)
TAG             := $(GIT_BRANCH)-git$(GIT_COMMIT)
IMAGE_TAG       := $(PROJECT):$(TAG)
IMAGE_LATEST    := $(PROJECT):latest
ENDPOINT_TAG    := $(REGISTRY)/$(IMAGE_TAG)
ENDPOINT_LATEST := $(REGISTRY)/$(IMAGE_LATEST)

## Targets
## ========================================================================

# This target is required by all Make files including dock.mk. It allows
# those Make files to override it and define which targets will be executed
# when running Make without explicit targets (i.e. make).
all::

init: ; @okay

exec:: | dockmk_exec
dockmk_exec::
	$(DOCKER) exec $(EXEC_OPTS) $(NAME) $(CMD)

build:: | dockmk_build
dockmk_build::
	$(DOCKER) build -t $(IMAGE_TAG) $(DOCKERFILE)

build-latest:: | dockmk_build-latest
dockmk_build-latest::
	$(DOCKER) build -t $(IMAGE_LATEST) $(DOCKERFILE)

publish:: | dockmk_publish
dockmk_publish::
	$(DOCKER) push $(ENDPOINT_TAG)

publish-latest:: | dockmk_publish-latest
dockmk_publish-latest::
	$(DOCKER) push $(ENDPOINT_LATEST)

clean:: | dockmk_clean
dockmk_clean::
	rm -f dock.mk
	rm -f .dockmk-vsn-*
	$(DOCKER) rmi -f $(IMAGE_TAG) $(IMAGE_LATEST)

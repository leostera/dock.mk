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
###   - build:	 create an image for the current Dockerfile
###							 automatically tagged
###
###		- publish: publish the current tag of the image to
###							 the internal docker hub
###
###   - clean:   removes all local images
###
###
### Author(s): DevOps FRED 		<devops.fred.e@klarna.com>
###						 Leandro Ostera <leandro.ostera@klarna.com>
###
### Based on dock.mk
###
### Copyright (c) 2015 Klarna
###========================================================================
.PHONY: all init build publish clean
.PHONY: dockme_build dockme_publish dockme_clean

## Settings
## ========================================================================
DOCKMK     := dock.mk

REGISTRY   := hub.int.klarna.net

DOCKER_CMD  = docker
DOCKER      = $(shell docker info >/dev/null 2>&1 && echo "${DOCKER_CMD}" || echo "sudo ${DOCKER_CMD}")

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2> /dev/null)
GIT_COMMIT := $(shell git rev-parse --short HEAD 2> /dev/null)

VERSION     := $(GIT_BRANCH)-git$(GIT_COMMIT)
TAG         := $(REGISTRY)/$(PROJECT):$(VERSION)
LATEST_TAG  := $(REGISTRY)/$(PROJECT):latest

## Targets
## ========================================================================

# This target is required by all Make files including dock.mk. It allows
# those Make files to override it and define which targets will be executed
# when running Make without explicit targets (i.e. make).
all::

init: ; @okay

build:: | dockmk_build
dockmk_build::
	$(DOCKER) build -t $(TAG) .

build-latest:: | dockmk_build-latest
dockmk_build-latest::
	$(DOCKER) build -t $(LATEST_TAG) .

publish:: | dockmk_publish
dockmk_publish::
	$(DOCKER) push $(TAG)

publish-latest:: | dockmk_publish-latest
dockmk_publish-latest::
	$(DOCKER) push $(LATEST_TAG)

clean:: | dockmk_clean
dockmk_clean:: ; @okay

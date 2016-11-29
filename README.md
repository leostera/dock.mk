# A Makefile for Dockerfiles

### Instant Gratification Setup

Just include this Makefile (the one in this repo) in your projects Makefile, like this:

```makefile
.PHONY: dock.mk ALWAYS

## Settings
##=========================================================================
export

PROJECT     := <your-project-name-here>
TEAM        := <your-dockerhub-team-namespace-here>
REGISTRY    := hub.docker.org

CONTAINER_NAME := $(PROJECT)

DOCKMK_VSN  := master

## Targets
##=========================================================================
all:: build

## Bootstrap targets
## ========================================================================
-include dock.mk

# bootstrap dock.mk (implicitly called by 'include dock.mk')
DOCKMK_VSN_FILE=.dockmk-vsn-$(DOCKMK_VSN)
dock.mk: $(DOCKMK_VSN_FILE)
$(DOCKMK_VSN_FILE):
	git archive --remote=https://github.com/ostera/dock.mk.git $(DOCKMK_VSN) dock.mk | tar x
	rm -f .dockmk-vsn-* && touch $(DOCKMK_VSN_FILE)

# match any target not defined nor included in this Make file
%: ALWAYS ; @$(MAKE) -s -f dock.mk $*
ALWAYS:
```

And you'll be pretty much ready to go! (sort of)

## The Long Version

The way this works is by including a Makefile with a set of common targets that
depend on pre-defined variables to work.

First things first, let's talk bootstrap.

### Bootstrapping Step

```makefile
## Bootstrap targets
## ========================================================================
-include dock.mk

# bootstrap dock.mk (implicitly called by 'include dock.mk')
DOCKMK_VSN_FILE=.dockmk-vsn-$(DOCKMK_VSN)
dock.mk: $(DOCKMK_VSN_FILE)
$(DOCKMK_VSN_FILE):
	git archive --remote=https://github.com/ostera/dock.mk.git $(DOCKMK_VSN) dock.mk | tar x
	rm -f .dockmk-vsn-* && touch $(DOCKMK_VSN_FILE)

# match any target not defined nor included in this Make file
%: ALWAYS ; @$(MAKE) -s -f dock.mk $*
ALWAYS:
```

It is indeed very straightforward, although slightly hardcoded (yup, stash url,
yukk). It will download the `dock.mk` file the first time you run `make` and it
will create a version file using the `DOCKMK_VSN` variable (typically it's set
to master, but we tag the repo so you can pin it down to a specific release if
you really want to).

Then the `ALWAYS` target will pass on every target that hasn't been executed yet
to the `dock.mk` makefile.

### Mandatory Configuration

If you take a look at the actual makefile you'll be including, it only really
wants a few things defined:

```makefile
## Checks
###========================================================================
ifndef CONTAINER_NAME
  $(error CONTAINER_NAME should be defined)
endif

ifndef PROJECT
  $(error PROJECT should be defined)
endif

ifndef TEAM
  $(error TEAM should be defined)
endif

ifndef REGISTRY
  $(error REGISTRY should be defined)
endif
```

With these 4 variables you'll already be able to build and publish.
The rest is optional. So as long as you have those defined, you'll be able to
run things.

### The Fun Bits of Configuring

There's some other options that are quite useful and let you do nifty things
with the makefile, these are:

```makefile
## Settings
## ========================================================================
DOCKERFILE ?= .

RUN_OPTS   ?= --rm -ti
EXEC_OPTS  ?= -ti
BUILD_OPTS ?=
CMD        ?= /bin/sh
ARGS       ?=
```

They let you specify the default options for `make exec`, `make run`, and `make
build`. I know, you already are thinking of cool ways of using it and how much
time and pain it'll save you. We did too. (And if you don't believe us take a
look at the `dockme-*` repos in the `TL` stash project).

## Extras

Naturally, we included some commands that we found useful over time, some of
those are:

* `make stats`, typically used as `watch make stats`, that will give you the
  `docker stats` for the `CONTAINER_NAME` you've specified in your makefile
* `make tag`, typically used to build and publish an image with a specific tag
  (great for one-offs!)

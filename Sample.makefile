.PHONY: dock.mk ALWAYS

## Settings
##=========================================================================
export

PROJECT     := dock.mk
TEAM        := ostera
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

f_lazy_dirname = $(patsubst %/,%,$(dir $(1:/=)))

__MAIN_MK_FILE := $(realpath $(lastword $(MAKEFILE_LIST)))
__MAIN_MK_DIR  := $(call f_lazy_dirname,$(__MAIN_MK_FILE))

S := $(CURDIR)
O := $(CURDIR)/obj

PHONY =

PHONY += default
default: all

include $(__MAIN_MK_DIR)/mk/env.mk
include $(__MAIN_MK_DIR)/mk/config.mk
include $(__MAIN_MK_DIR)/mk/config_gnu.mk
include $(__MAIN_MK_DIR)/mk/sed_edit.mk
include $(__MAIN_MK_DIR)/mk/file_targets.mk
include $(__MAIN_MK_DIR)/mk/bindir_targets.mk

FORCE:

.PHONY: $(PHONY)

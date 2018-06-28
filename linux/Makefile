# Example of a top Makefile for an integration setup
#

default: help

ifneq ($(OEROOT),)
$(error "You can't use this makefile from within a bitbake shell")
endif

# Default settings
HOSTNAME 	?= $(shell hostname)
USER		?= $(shell whoami)
HOST_ARCH	?= $(shell uname -m)

# Don't inherit path from environment any extra PATH:s needs to go into one of the *config-*.mk
export PATH	:= /bin:/usr/bin
export SHELL	:= /bin/bash

# Optional configuration
-include hostconfig-$(HOSTNAME).mk
-include userconfig-$(USER).mk

TOP	:= $(shell pwd)

#
# These are variables you might want to override in either of the three
# configuration files above or on the command line
#
# Product definitions (where wrtools are installed for example)
WIND_VER		?= wrlinux_800
WIND_MAJOR_VER		?= $(shell WIND_VER=$(WIND_VER); echo $${WIND_VER:8:1})
RCPL			?= 14
WIND_INSTALL_BASE	?= /wr/installs
WIND_LX_HOME		?= $(WIND_INSTALL_BASE)/$(WIND_VER)

ifeq ($(RCPL),auto)
WIND_NAME		= $(WIND_VER).auto
RCPL_CONFIG		= $(RCPL)
else
WIND_NAME		= $(shell WIND_VER=$(WIND_VER); echo $${WIND_VER:0:12}).$(RCPL)
RCPL_CONFIG		= $(shell printf "%04d" $(RCPL))
endif

# Platform definitions
BSP		?= riu6608
ROOTFS		?= glibc_small
KERNEL		?= standard
BUILD_TYPE	?= production
PKGBUILDS	?= 8
PKGJOBS		?= 16

GITROOT         = $(shell git rev-parse --show-toplevel)
OUTDIR		?= $(TOP)/out
BUILDDIR	?= $(OUTDIR)/build_$(BSP)_$(KERNEL)_$(ROOTFS)_$(WIND_NAME)

BSP_GIT		?= git@github.com:DUSg2/meta-wr-zynqmp-bsp.git
BSP_BRANCH	?= topic/awallin/riu6608
BSP_REPO	?= $(LAYER_DIR)/meta-wr-zynqmp-bsp

LAYER_DIR	+= $(TOP)/../layers
LAYERS		= $(BSP_REPO)
LAYERS		+= wr-kernel/kernel-dev


# There should be no need to change any lines below
comma		:= ,
space		:= $(empty) $(empty)

ifneq ("$(LAYERS)","")
        W_LAYERS	= $(subst $(space),$(comma),$(LAYERS))
endif

CCACHE		?= no
SSTATEDIR 	?= $(OUTDIR)/.sstate
PRSERVER	?= local

SDK_FILE ?= $(BUILDDIR)/bitbake_build/tmp/deploy/sdk/wrlinux*-$(WIND_MAJOR_VER).0.0.*-glibc-$(HOST_ARCH)-$(BSP2)-wrlinux-image-$(ROOTFS2)-sdk.sh
SDK_BASE ?= $(OUTDIR)/sdk
SDK_DIR	 ?= $(SDK_BASE)/$(BSP)

# Tools used
# Define V=1 to echo everything
ifeq ($(V),)
	Q=@
endif

# Check for and generate stamps (NOTE: no ':') and a generic make target to
# force re-execution of target (eg make fs.force)
vpath % $(BUILDDIR)/stamps
MKSTAMP	= $(Q)mkdir -p $(BUILDDIR)/stamps ; touch $(BUILDDIR)/stamps/$@
%.force:
	$(RM) $(BUILDDIR)/stamps/$*
	$(MAKE) $*

ECHO	:= $(Q)echo
MKDIR	:= $(Q)mkdir -p
RM	:= $(Q)rm -f
MAKE	:= $(Q)make

WRL_CONFIGURE := $(WIND_LX_HOME)/wrlinux-$(WIND_MAJOR_VER)/wrlinux/configure

EXTRA_CONFIG_OPTS += --enable-buildstats=yes
EXTRA_CONFIG_OPTS += --with-init=sysvinit

help::
	$(ECHO) -e "WIND_VER=$(WIND_VER) RCPL=$(RCPL) BSP=$(BSP) ROOTFS=$(ROOTFS)\n"
	$(ECHO) "all		- Build everything"
	$(ECHO) "kernel		- Build the kernel"
	$(ECHO) "bbs     	- Start a subshell from which you can use bitbake"
	$(ECHO) "clean		- Remove everything (except installations)"
	$(ECHO) "distclean	- clean + remove sstate"
	$(ECHO)	"fs		- Build a filesystem (root image)"
	$(ECHO)	"sdk		- Build the SDK"
	$(ECHO)	"sdk.install	- Install the SDK"

.PHONY: all fs sdk sdk.install kernel clean distclean bbs
.FORCE:

all: fs sdk

fs: configure
	$(MAKE) -C $(BUILDDIR) $@

kernel: configure
	$(MAKE) -C $(BUILDDIR) virtual/kernel

sdk: configure
	$(MAKE) -C $(BUILDDIR) export-sdk

sdk.install: $(SDK_DIR)
$(SDK_DIR): $(SDK_FILE)
	$(Q)$< -y -d $@

sdk.devshell: sdk.install
	$(Q)bash -c "source $(SDK_DIR)/env.sh; unset command_not_found_handle; cd $(SDK_DIR); exec bash --norc"

bbs: configure
	$(MAKE) -C $(BUILDDIR) $@



$(BUILDDIR):
	$(MKDIR) $@

update: bsp.update
bsp.update: $(BSP_REPO)
	$(Q)(cd $<; git pull; git gc --auto)

$(BSP_REPO):
	$(ECHO) "bsp git repository not found at:"
	$(ECHO)
	$(ECHO) "  " $@
	$(ECHO)
	git clone $(BSP_GIT) -b $(BSP_BRANCH) $@


configure: $(WIND_LX_HOME) $(BSP_REPO) | $(BUILDDIR)
	cd $(BUILDDIR) ; $(WRL_CONFIGURE)		\
	  --with-layer=$(W_LAYERS) 			\
	  --enable-build=$(BUILD_TYPE)			\
	  --enable-rootfs=$(ROOTFS)			\
	  --enable-kernel=$(KERNEL)			\
	  --enable-board=$(BSP)				\
	  --enable-prserver=$(PRSERVER)			\
	  --enable-ccache=$(CCACHE)			\
	  --with-sstate-dir=$(SSTATEDIR)		\
	  --enable-reconfig				\
	  --enable-parallel-pkgbuilds=$(PKGBUILDS)	\
	  --enable-jobs=$(PKGJOBS)			\
	  --with-rcpl-version=$(RCPL_CONFIG)		\
	  $(EXTRA_CONFIG_OPTS)
	$(MKSTAMP)

configure.help:
	$(WRL_CONFIGURE) --help | less

sdk.clean:
	$(RM) -r $(SDK_DIR)

clean:
	$(RM) -r $(BUILDDIR)

distclean: sdk.clean clean
	$(RM) -r $(OUTDIR)
	$(RM) -r $(BSP_REPO)

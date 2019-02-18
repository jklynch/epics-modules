# Set the SUPPORT Directory (from this makefile)
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR:= $(dir $(MKFILE_PATH))

#
## Version Definitions
#

EPICS_BASE_VERSION    := $(or $(EPICS_BASE_VERSION), 7.0)
ASYN_VERSION          := $(or $(ASYN_VERSION), master)
AUTOSAVE_VERSION      := $(or $(AUTOSAVE_VERSION), master)
BUSY_VERSION          := $(or $(BUSY_VERSION), master)
CALC_VERSION          := $(or $(CALC_VERSION), master)
SSCAN_VERSION         := $(or $(SSCAN_VERSION), master)
DEVIOCSTATS_VERSION   := $(or $(DEVIOCSTATS_VERSION), master)
SNCSEQ_VERSION        := $(or $(SNCSEQ_VERSION), master)
AREA_DETECTOR_VERSION := $(or $(AREA_DETECTOR_VERSION), master)
ADCORE_VERSION        := $(or $(ADCORE_VERSION), master)
MOTOR_VERSION         := $(or $(MOTOR_VERSION), master)
MODBUS_VERSION        := $(or $(MODBUS_VERSION), master)
STREAM_VERSION        := $(or $(STREAM_VERSION), master)
QUADEM_VERSION        := $(or $(QUADEM_VERSION), master)
IPAC_VERSION          := $(or $(IPAC_VERSION), master)
IPUNIDIG_VERSION      := $(or $(IPUNIDIG_VERSION), master)

#
## Function to get all release files
#

define set_release
  $(wildcard $(1)/configure/RELEASE) \
  $(wildcard $(1)/configure/RELEASE_BASE.local) \
  $(wildcard $(1)/configure/RELEASE_BASE.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_BASE.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_SUPPORT.local) \
  $(wildcard $(1)/configure/RELEASE_SUPPORT.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_SUPPORT.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_PATHS.local) \
  $(wildcard $(1)/configure/RELEASE_PATHS.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_PATHS.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_LIBS.local) \
  $(wildcard $(1)/configure/RELEASE_LIBS.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_LIBS.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_PRODS.local) \
  $(wildcard $(1)/configure/RELEASE_PRODS.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_PRODS.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE.local) \
  $(wildcard $(1)/configure/RELEASE.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE.$(EPICS_HOST_ARCH)) 
endef

MODULE_DIRS = areaDetector asyn autosave busy calc epics-base iocStats \
			  ipUnidig ipac modbus motor sscan stream quadEM

MODULE_DIRS_CLEAN = $(addsuffix clean,$(MODULE_DIRS))

.PHONY: all
all: $(MODULE_DIRS)

asyn: epics-base ipac

calc: epics-base sscan

sscan: epics-base

busy: epics-base asyn autosave

autosave: epics-base

iocStats: epics-base

motor: epics-base asyn ipac

modbus: epics-base asyn

stream: epics-base asyn ipac

quadEM: epics-base ipac areaDetector 

ipac: epics-base 

ipUnidig: epics-base ipac

areaDetector: epics-base asyn calc sscan busy autosave iocStats

.PHONY: $(MODULE_DIRS)
$(MODULE_DIRS):
	$(MAKE) -C $@

.PHONY: .release_areadetector
.release_areadetector:
	cp -nv areaDetector/configure/EXAMPLE_CONFIG_SITE.local \
		      areaDetector/configure/CONFIG_SITE.local
	cp -nv areaDetector/configure/EXAMPLE_RELEASE.local \
		      areaDetector/configure/RELEASE.local
	cp -nv areaDetector/configure/EXAMPLE_RELEASE.local \
		      areaDetector/configure/RELEASE.local
	cp -nv areaDetector/configure/EXAMPLE_RELEASE_SUPPORT.local \
		      areaDetector/configure/RELEASE_SUPPORT.local
	cp -nv areaDetector/configure/EXAMPLE_RELEASE_LIBS.local \
		      areaDetector/configure/RELEASE_LIBS.local
	cp -nv areaDetector/configure/EXAMPLE_RELEASE_PRODS.local \
		      areaDetector/configure/RELEASE_PRODS.local

.PHONY: release
release: .release_areadetector
	$(eval RELEASE_FILES := $(foreach mod, $(MODULE_DIRS), $(call set_release,$(mod)) ))
	echo "SUPPORT=${MKFILE_DIR}" > "$(MKFILE_DIR)/configure/RELEASE"
	echo "EPICS_BASE=${MKFILE_DIR}/epics-base" >> "$(MKFILE_DIR)/configure/RELEASE"
	cat "${MKFILE_DIR}/configure/RELEASE.template" >> "$(MKFILE_DIR)/configure/RELEASE"
	configure/modify_release.py SNCSEQ UNSET $(RELEASE_FILES)
	configure/make_release.py "configure/RELEASE" $(RELEASE_FILES)
	configure/modify_release.py MAKE_TEST_IOC_APP UNSET "iocStats/configure/RELEASE"

#
## Update all git repos to their master (or equivalent)
#

.PHONY: update
update:
	# Initialize submodules
	git submodule foreach --recursive "git stash"
	git submodule update --init --recursive
	cd asyn && git fetch --all --tags --prune && git checkout $(ASYN_VERSION)
	cd autosave && git fetch --all --tags --prune && git checkout $(AUTOSAVE_VERSION)
	cd busy && git fetch --all --tags --prune && git checkout $(BUSY_VERSION)
	cd calc && git fetch --all --tags --prune && git checkout $(CALC_VERSION)
	cd epics-base && git fetch --all --tags --prune && git checkout $(EPICS_BASE_VERSION)
	cd iocStats && git fetch --all --tags --prune && git checkout $(DEVIOCSTATS_VERSION)
	cd ipac && git fetch --all --tags --prune && git checkout $(IPAC_VERSION)
	cd ipUnidig && git fetch --all --tags --prune && git checkout $(IPUNIDIG_VERSION)
	cd modbus && git fetch --all --tags --prune && git checkout $(MODBUS_VERSION)
	cd motor && git fetch --all --tags --prune && git checkout $(MOTOR_VERSION)
	cd quadEM && git fetch --all --tags --prune && git checkout $(QUADEM_VERSION)
	cd sscan && git fetch --all --tags --prune && git checkout $(SSCAN_VERSION)
	cd stream && git fetch --all --tags --prune && git checkout $(STREAM_VERSION)
	cd stream/StreamDevice && git fetch --all --tags --prune && git checkout $(STREAM_VERSION)
	cd areaDetector && git fetch --all --tags --prune && git checkout $(AREA_DETECTOR_VERSION)
	cd areaDetector && git submodule foreach "git fetch --all --tags --prune && git checkout master"
	git submodule foreach --recursive "git stash pop || true"

#
## Clean up by running "make clean" in all modules and deleting the areadetector
## local files
#

.PHONY: clean
clean: clean_release

.PHONY: clean_modules
clean_modules: $(MODULE_DIRS_CLEAN)

%clean: 
	$(MAKE) -C $(patsubst %clean,%,$@) clean

.PHONY: clean_release
clean_release: clean_modules
	rm -rf configure/RELEASE
	rm -rf areaDetector/configure/CONFIG_SITE.local
	rm -rf areaDetector/configure/RELEASE.local
	rm -rf areaDetector/configure/RELEASE.local
	rm -rf areaDetector/configure/RELEASE_SUPPORT.local
	rm -rf areaDetector/configure/RELEASE_LIBS.local
	rm -rf areaDetector/configure/RELEASE_PRODS.local

.PHONY: show_versions
show_versions:
	@echo "Versions:"
	@echo ""
	@echo "EPICS_BASE Version           = $(EPICS_BASE_VERSION)"
	@echo "ASYN Version                 = $(ASYN_VERSION)"
	@echo "AUTOSAVE Version             = $(AUTOSAVE_VERSION)"
	@echo "BUSY Version                 = $(BUSY_VERSION)"
	@echo "CALC Version                 = $(CALC_VERSION)"
	@echo "SSCAN Version                = $(SSCAN_VERSION)"
	@echo "DEVIOCSTATS Version          = $(DEVIOCSTATS_VERSION)"
	@echo "SNCSEQ Version               = $(SNCSEQ_VERSION)"
	@echo "AREA_DETECTOR Version        = $(AREA_DETECTOR_VERSION)"
	@echo "ADCORE Version               = $(ADCORE_VERSION)"
	@echo "MOTOR Version                = $(MOTOR_VERSION)"
	@echo "MODBUS Version               = $(MODBUS_VERSION)"
	@echo "STREAM Version               = $(STREAM_VERSION)"
	@echo "QUADEM Version               = $(QUADEM_VERSION)"
	@echo "IPAC Version                 = $(IPAC_VERSION)"
	@echo "IPUNIDIG Version             = $(IPUNIDIG_VERSION)"


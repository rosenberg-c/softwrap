REPO_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
CONFIG_DIR ?= $(HOME)/.config

.PHONY: install
install:
	mkdir -p "$(CONFIG_DIR)"
	@if [ -e "$(CONFIG_DIR)/softwrap" ] || [ -L "$(CONFIG_DIR)/softwrap" ]; then \
		echo "$(CONFIG_DIR)/softwrap already exists" >&2; exit 1; \
	fi
	ln -s "$(REPO_DIR)" "$(CONFIG_DIR)/softwrap"

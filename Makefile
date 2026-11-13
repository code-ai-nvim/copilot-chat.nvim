NVIM ?= nvim

# Sandbox so tests never touch the personal nvim config, data, state or cache
TEST_HOME ?= $(CURDIR)/.tests

export XDG_CONFIG_HOME := $(TEST_HOME)/config
export XDG_DATA_HOME := $(TEST_HOME)/data
export XDG_STATE_HOME := $(TEST_HOME)/state
export XDG_CACHE_HOME := $(TEST_HOME)/cache
export NVIM_APPNAME := copilot-chat-tests
export PLENARY_MINIMAL_INIT := scripts/minimal.lua

.PHONY: test clean-test

test:
	mkdir -p $(XDG_CONFIG_HOME) $(XDG_DATA_HOME) $(XDG_STATE_HOME) $(XDG_CACHE_HOME)
	$(NVIM) --headless -i NONE -u scripts/minimal.lua -c "luafile scripts/test.lua"

clean-test:
	rm -rf $(TEST_HOME)


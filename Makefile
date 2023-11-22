# Pekka Kana 2 by Janne Kivilahti from Piste Gamez (2003-2007)
# https://pistegamez.net/game_pk2.html
#
# Makefile command:
# "make" - Creates Pekka Kana 2 binary
# "make clean" - Removes all objects, executables and dependencies

# Compiler:
CXX ?= g++

# Optimization:
#CXXFLAGS += -g
CXXFLAGS += -O3
LDFLAGS += -O3

# Further optimization:
#CXXFLAGS += -march=native -fno-exceptions -fno-rtti -flto 
#LDFLAGS += -march=native -s -Wl,--gc-sections -flto

# Warnings:
CXXFLAGS += -Wall -Wextra

# Standard:
CXXFLAGS += --std=c++11

ifdef EMSCRIPTEN
# Emscripten-specific settings
SHAREDFLAGS = -sUSE_SDL=2 -sUSE_SDL_MIXER=2 -sSDL2_MIXER_FORMATS='["wav","mod"]' \
              -sUSE_SDL_IMAGE=2 -sSDL2_IMAGE_FORMATS='["bmp","png"]'
CXXFLAGS += $(SHAREDFLAGS)
LDFLAGS += $(SHAREDFLAGS) -sASYNCIFY -sASYNCIFY_IGNORE_INDIRECT -sINITIAL_MEMORY=32MB -sTOTAL_STACK=1MB \
           -sALLOW_MEMORY_GROWTH --shell-file wasm/shell.html -sEXIT_RUNTIME=1 -lidbfs.js \
           --preload-file=res/episodes --preload-file=res/gfx/scenery --preload-file=res/gfx/tiles \
           --preload-file=res/gfx/ending.bmp --preload-file=res/gfx/intro.bmp --preload-file=res/gfx/map.bmp \
           --preload-file=res/gfx/menu.bmp --preload-file=res/gfx/pk2stuff.bmp --preload-file=res/gfx/pk2stuff2.png \
           --preload-file=res/language --preload-file=res/music --preload-file=res/sfx --preload-file=res/sprites \
           --preload-file=res/mobile
else
# SDL2:
CXXFLAGS += $(shell pkg-config sdl2 --cflags)
LDFLAGS += $(shell pkg-config sdl2 --libs) -lSDL2_mixer -lSDL2_image

# LibZip (read episodes on zip files):
CXXFLAGS += -DPK2_USE_ZIP $(shell pkg-config libzip --cflags)
LDFLAGS += $(shell pkg-config libzip --libs)

# Lua:
CXXFLAGS += $(shell pkg-config lua5.4 --cflags)
LDFLAGS += $(shell pkg-config lua5.4 --libs)

# Commit hash:
CXXFLAGS += -DCOMMIT_HASH='"$(shell git rev-parse --short HEAD)"'
endif

# Portable (data is stored with resources):
CXXFLAGS += -DPK2_PORTABLE

# Directories:
SRC_DIR = src/
BIN_DIR = bin/
BUILD_DIR = build/

# Source files:
PK2_SRC  = *.cpp */*.cpp */*/*.cpp
PK2_SRC := $(addprefix $(SRC_DIR), $(PK2_SRC))
PK2_SRC := $(wildcard $(PK2_SRC))
ifdef EMSCRIPTEN
PK2_SRC := $(filter-out src/screens/lua_screen.cpp src/engine/PLua.cpp src/engine/render/PGl.cpp \
                        src/engine/render/PGlFuncs.cpp, $(PK2_SRC))
endif

# Object files:
PK2_OBJ := $(basename $(PK2_SRC))
PK2_OBJ := $(subst $(SRC_DIR), ,$(PK2_OBJ))
PK2_OBJ := $(addsuffix .o, $(PK2_OBJ))
PK2_OBJ := $(addprefix $(BUILD_DIR), $(PK2_OBJ))

# Dependency files:
DEPENDENCIES := $(PK2_OBJ)
DEPENDENCIES := $(basename $(DEPENDENCIES))
DEPENDENCIES := $(addsuffix .d, $(DEPENDENCIES))

# Binary output:
ifdef EMSCRIPTEN
	PK2_BIN = $(BIN_DIR)index.html
else
	PK2_BIN = $(BIN_DIR)pekka-kana-2
endif

pk2: $(PK2_BIN)

###########################
$(PK2_BIN): $(PK2_OBJ)
	@mkdir -p $(dir $@) >/dev/null
	$(CXX) $^ $(LDFLAGS) -o $@
###########################

###########################
-include $(DEPENDENCIES)

$(BUILD_DIR)%.o: $(SRC_DIR)%.cpp
	@mkdir -p $(dir $@) >/dev/null
	$(CXX) $(CXXFLAGS) -I$(SRC_DIR) -o $@ -c $<

ifndef EMSCRIPTEN
	$(CXX) -MM -MT $@ -I$(SRC_DIR) $< > $(BUILD_DIR)$*.d
endif
###########################

clean:
	@rm -rf $(BIN_DIR)
	@rm -rf $(BUILD_DIR)

.PHONY: pk2 clean

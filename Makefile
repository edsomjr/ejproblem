PROJECT=cp-tools

# Compiler setup
CC=g++-8
GCC=gcc
CFLAGS=-W -Wall -Werror -std=c++17

RELEASE_CFLAGS=-O2
DEBUG_CFLAGS=-g -O0

ifeq ($(MAKECMDGOALS),release)
    CFLAGS+=$(RELEASE_CFLAGS)
else
    CFLAGS+=$(DEBUG_CFLAGS)
endif

LDFLAGS=
INCLUDES=-Iinclude -Ilibs

# Tools
AR=ar
AR_FLAGS=rcs
LINKER=$(CC)

# Environment variables
INCLUDES_FLAG=-I
LIBPATH_FLAG=-L
EXT_LIBPATH_FLAG=-L
LIBS_FLAG=-l
EXT_LIBS_FLAG=-l
OBJ_OUTPUT_FLAG=-o 
AR_OUTPUT_FLAG=
OUTPUT_FLAG=-o 
GEN_OBJECT_FLAG=-c
STATIC_LIB_SUFFIX=.a
STATIC_LIB_PREFIX=lib
OBJ_EXTENSION=.o

# Directories
SRC_DIR=src
LIBS_DIR=libs
TESTS_DIR=tests
CLASSES_DIR=classes
SCRIPTS_DIR=scripts
TEMPLATE_DIR=templates

INSTALL_BIN_DIR=/usr/local/bin
INSTALL_CLASSES_DIR=/usr/local/lib
INSTALL_TEMPLATE_DIR=/usr/local/lib
INSTALL_COMPLETION_DIR=/etc/bash_completion.d

# Project targets
LIBRARY=$(STATIC_LIB_PREFIX)$(PROJECT)$(STATIC_LIB_SUFFIX)
MD4C_LIBRARY=$(STATIC_LIB_PREFIX)md4c$(STATIC_LIB_SUFFIX)
TEST_SUIT=cp-run_tests

# External libraries
LIBS=$(MD4C_LIBRARY) -lstdc++fs

.PHONY: all clean

# Project source files
SOURCES=${wildcard $(SRC_DIR)/*.cpp}
SOURCES:=${filter-out $(SRC_DIR)/main.cpp, $(SOURCES)}

OBJECTS=$(SOURCES:.cpp=$(OBJ_EXTENSION))
COMPLETION_SCRIPT=$(PROJECT)-completion.sh

PROJECT_MAIN=$(SRC_DIR)/main.cpp
PROJECT_OBJECT=$(PROJECT_MAIN:.cpp=$(OBJ_EXTENSION))

TEST_MAIN=$(TESTS_DIR)/main.cc
TEST_OBJECT=$(TEST_MAIN:.cc=$(OBJ_EXTENSION))

TEST_SOURCES=${wildcard $(TESTS_DIR)/*.cpp}


# Rules
.SUFFIXES: .cpp .$(OBJ_EXTENSION) 


.cpp$(OBJ_EXTENSION):
	$(CC) $(GEN_OBJECT_FLAG) $< $(OBJ_OUTPUT_FLAG) $@ $(CFLAGS) $(INCLUDES)


all: $(MD4C_LIBRARY) $(LIBRARY) $(PROJECT) $(TEST_SUIT)


$(LIBRARY): $(OBJECTS)
	$(AR) $(AR_FLAGS) $(AR_OUTPUT_FLAG) $@ $(OBJECTS) 


$(MD4C_LIBRARY): $(LIBS_DIR)/md4c.h $(LIBS_DIR)/md4c.c
	$(GCC) -c $(LIBS_DIR)/md4c.c
	$(AR) $(AR_FLAGS) $(AR_OUTPUT_FLAG) $@ md4c.o


$(PROJECT): $(OBJECTS) $(PROJECT_OBJECT)
	$(LINKER) $(OUTPUT_FLAG)$@ $(LDFLAGS) $(PROJECT_OBJECT) $(LIBRARY) $(LIBS) $(EXTRA_LIBS)


$(TEST_OBJECT): $(TEST_MAIN) $(TEST_SOURCES)
	$(CC) $(GEN_OBJECT_FLAG) $(TEST_MAIN) $(OBJ_OUTPUT_FLAG) $@ $(CFLAGS) $(INCLUDES)


$(TEST_SUIT): $(LIBRARY) $(TEST_OBJECT)
	$(CC) $(OUTPUT_FLAG)$@ $(TEST_OBJECT) $(LDFLAGS) $(LIBRARY) $(LIBS) $(EXTRA_LIBS)


update_release:
	@./scripts/gen_defs.sh


release: update_release $(LIBRARY) $(PROJECT)


install: $(PROJECT)
	@cp $(PROJECT) $(INSTALL_BIN_DIR)
	@mkdir -p $(INSTALL_TEMPLATE_DIR)/$(PROJECT)
	@cp -r $(TEMPLATE_DIR) $(INSTALL_TEMPLATE_DIR)/$(PROJECT)/
	@mkdir -p $(INSTALL_CLASSES_DIR)/$(PROJECT)
	@cp -r $(CLASSES_DIR) $(INSTALL_CLASSES_DIR)/$(PROJECT)/
	@cp $(SCRIPTS_DIR)/$(COMPLETION_SCRIPT) $(INSTALL_COMPLETION_DIR)


uninstall:
	@rm -f $(INSTALL_COMPLETION_DIR)/$(COMPLETION_SCRIPT)
	@rm -rf $(INSTALL_TEMPLATE_DIR)/$(PROJECT)
	@rm -f $(INSTALL_BIN_DIR)/$(PROJECT)


clean:
	@rm -f *~ $(MD4C_LIBRARY) $(LIBRARY) $(PROJECT)
	@find . -name '*.o' -exec rm -f {}  \;

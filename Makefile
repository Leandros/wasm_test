mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
current_dir := $(dir current_dir)

CC			:= $(current_dir)bin/clang
LLC			:= $(current_dir)bin/llc
S2WASM		:= $(current_dir)bin/binaryen/s2wasm
AS			:= $(current_dir)bin/binaryen/wasm-as
OPT			:= $(current_dir)bin/binaryen/wasm-opt

ALL_CFLAGS	 := $(CFLAGS)
ALL_CFLAGS 	 += -nostdlib -O3 --target=wasm32
ALL_LLCFLAGS := $(LLCFLAGS)
ALL_LLCFLAGS += -O3 -asm-verbose=false

SRCDIR		:= src
OBJDIR		:= obj
OUTDIR 		:= out
SRC			:= $(shell find $(SRCDIR) -type f -name '*.c')
OBJ			:= $(patsubst $(SRCDIR)/%,$(OBJDIR)/%,$(SRC:.c=.wast))
DEP			:= $(OBJ:.wast=.d)
BIN			:= out.wasm
-include $(DEP)

all: dir $(BIN)

dir:
	@mkdir -p $(OBJDIR)
	@mkdir -p $(OUTDIR)

$(BIN): $(OBJ)
	$(AS) -o $(OBJDIR)/$*.wasm $^
	$(OPT) -O3 -o $(BIN) $(OBJDIR)/$*.wasm

$(OBJDIR)/%.wast: $(SRCDIR)/%.c
	$(CC) $(ALL_CFLAGS) -emit-llvm -c -MMD -MP -o $(OBJDIR)/$*.bc $<
	$(LLC) $(ALL_LLCFLAGS) -o $(OBJDIR)/$*.s $(OBJDIR)/$*.bc
	$(S2WASM) -o $(OBJDIR)/$*.wast $(OBJDIR)/$*.s

.PHONY: clean
clean:
	rm -rf $(OBJDIR) $(OUTDIR)


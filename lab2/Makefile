source_files=testing.v double_multiplier.cpp
OUTPUT_FILE = test_suit.exe
CC=VERILATOR_ROOT=C:/Users/danilov_ns/msys2/mingw64/share/verilator verilator
CFLAGS=--binary -Wno-lint --vpi --runtime-debug

.PHONY: all clean

all:
	${CC} ${CFLAGS} ${source_files} -o ${OUTPUT_FILE}

clean:
	rm -rf obj_dir

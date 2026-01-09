source_files=testing.v double_multiplier.cpp
OUTPUT_FILE = test_suit
CC=verilator
CFLAGS=--binary -Wno-lint --vpi

.PHONY: all clean

all:
	${CC} ${CFLAGS} ${source_files} -o ${OUTPUT_FILE}

clean:
	rm -rf obj_dir

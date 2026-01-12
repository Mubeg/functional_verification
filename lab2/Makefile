source_files=testing.v double_multiplier.cpp
OUTPUT_FILE = test_suit
CC=verilator
CFLAGS=--binary -Wno-lint --vpi

COVERAGE_RUNNER = verilator_coverage
COVERANGE_REPORTS_DIRECTORY = coverage_reports
COVERAGE_DATA = coverage.dat

.PHONY: all clean coverage annotate

all:
	${CC} ${CFLAGS} ${source_files} -o ${OUTPUT_FILE}

coverage:
	${CC} ${CFLAGS} --coverage ${source_files} -o ${OUTPUT_FILE}

annotate:
	${COVERAGE_RUNNER} ${COVERAGE_DATA} --annotate ${COVERANGE_REPORTS_DIRECTORY}

clean:
	rm -rf obj_dir
	rm -f ${COVERAGE_DATA}

#!/usr/bin/env bash

TESTCASE_ROOT="${TESTCASE_ROOT:-$HOME/testcases_hw2}"
TESTCASE_NAME="${1:-test_small_uniform_50}"

echo "Running spmv_openmp with test case: $TESTCASE_NAME"

OMP_NUM_THREADS=16 ./spmv_openmp \
    "$TESTCASE_ROOT/$TESTCASE_NAME.mtx" \
    "$TESTCASE_ROOT/$TESTCASE_NAME.vec"
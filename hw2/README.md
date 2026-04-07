# HW2

## Project Layout

- `src/spmv_not_csr.c`: naive COO-scan baseline
- `src/spmv_serial.c`: CSR serial implementation
- `src/spmv_openmp.c`: CSR parallel implementation with OpenMP
- `Makefile`: build and clean targets
- `test_not_csr.sh`: helper script to run `spmv_not_csr` with testcase files

## Build

From the `hw2` directory:

```bash
make
```

This builds:

- `spmv_not_csr`
- `spmv_serial`
- `spmv_openmp`

The Makefile uses these compile commands:

```bash
gcc -fopenmp -O3 -o spmv_openmp src/spmv_openmp.c
gcc -O3 -o spmv_serial src/spmv_serial.c
gcc -O3 -o spmv_not_csr src/spmv_not_csr.c
```

You can also build a single target:

```bash
make spmv_not_csr
make spmv_serial
make spmv_openmp
```

## Run

From the `hw2` directory:

```bash
# naive COO-scan baseline
./spmv_not_csr input_matrix.mtx [input_vector.txt]

# CSR serial implementation
./spmv_serial input_matrix.mtx [input_vector.txt]

# CSR parallel (OpenMP)
OMP_NUM_THREADS=16 ./spmv_openmp input_matrix.mtx [input_vector.txt]
```

## Run With Test Script

The helper script runs `spmv_not_csr` using testcase files under `$HOME/testcases_hw2` by default.

Default testcase:

```bash
# usage: bash test_not_csr.sh [testcase_name (optional)]
bash test_not_csr.sh
```

Pass testcase name via bash parameter:

```bash
bash test_not_csr.sh test_small_uniform_50
```

Override testcase root path:

```bash
TESTCASE_ROOT=$HOME/testcases_hw2 bash test_not_csr.sh test_small_uniform_50
```

## Clean

Remove compiled artifacts:

```bash
make clean
```

## Testcase

Expected extracted testcase directory:

```bash
$HOME/testcases_hw2
```

Each testcase should provide:

- `<name>.mtx`
- `<name>.vec`

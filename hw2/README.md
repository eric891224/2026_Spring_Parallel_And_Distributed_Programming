# HW2

## Project Layout

- `src/spmv_not_csr.c`: naive COO-scan baseline
- `src/spmv_serial.c`: CSR serial implementation
- `src/spmv_openmp.c`: CSR parallel implementation with OpenMP
- `Makefile`: build and clean targets
- `test_not_csr.sh`: helper script to run `spmv_not_csr` with testcase files
- `test_serial.sh`: helper script to run `spmv_serial` with testcase files
- `test_openmp.sh`: helper script to run `spmv_openmp` with fixed `OMP_NUM_THREADS=16`
- `benchmark_openmp.sh`: benchmark OpenMP schedules/chunks on one or all testcases with configurable thread count

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

The helper scripts use testcase files under `$HOME/testcases_hw2` by default.

### not_csr

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

### serial

```bash
# usage: bash test_serial.sh [testcase_name (optional)]
bash test_serial.sh
bash test_serial.sh huge_200k_100
```

### openmp

`test_openmp.sh` keeps `OMP_NUM_THREADS=16` fixed.

```bash
# usage: bash test_openmp.sh [testcase_name (optional)]
bash test_openmp.sh
bash test_openmp.sh huge_200k_100
```

## Benchmark OpenMP

`benchmark_openmp.sh` benchmarks `spmv_openmp` using `OMP_SCHEDULE`.

Script arguments:

```bash
bash benchmark_openmp.sh [testcase_or_all] [repeats]
```

- `testcase_or_all`: testcase name, or `all` (default: `all`)
- `repeats`: number of runs per config (default: `1`)

Thread sweep is controlled like schedules/chunks via environment variable:

```bash
THREADS="1 2 4 8 16 32 64 128"
```

Default thread sweep is `1 2 4 8 16 32 64 128`.

`benchmark_openmp.sh` applies each value as `OMP_NUM_THREADS` and adds an outer loop over thread counts.

Run all testcases (all `*.mtx` in testcase root), 1 repeat:

```bash
bash benchmark_openmp.sh
```

Run one testcase with repeats:

```bash
bash benchmark_openmp.sh huge_200k_100 3
```

Run one testcase with custom thread sweep:

```bash
THREADS="1 2 4 8 16" bash benchmark_openmp.sh huge_200k_100 3
```

Run all testcases with thread sweep from env var:

```bash
THREADS="8 16 32 64" bash benchmark_openmp.sh all 2
```

Run all testcases with custom schedule/chunk sweep:

```bash
SCHEDULES="static dynamic guided" \
CHUNKS="1 8 32 128 512" \
bash benchmark_openmp.sh all 2
```

CSV outputs are written to:

```bash
benchmark_logs/openmp_benchmark_<testcase_or_all_testcases>_<timestamp>.csv
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

Current testcase names in the provided dataset:

- `test_small_uniform_50`
- `test_med_uniform_500`
- `test_med_skew_500`
- `test_sparse_1000`
- `large_sparse_2000`
- `large_sparse_5000`
- `large_10000_sparse_100`
- `large_denserows_2000`
- `huge_denserows_5000`
- `huge_200k_100`

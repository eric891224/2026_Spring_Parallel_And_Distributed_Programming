# HW2

## Project Layout

- `src/spmv_not_csr.c`: naive COO-scan baseline
- `src/spmv_serial.c`: CSR serial implementation
- `src/spmv_openmp.c`: CSR parallel implementation with OpenMP
- `Makefile`: build and clean targets

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

## Clean

Remove compiled artifacts:

```bash
make clean
```

## Testcase

The testcase package is located at `~/testcase_hw2.zip`.

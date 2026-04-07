SRC_DIR = src

all: spmv_openmp spmv_serial spmv_not_csr

spmv_openmp: $(SRC_DIR)/spmv_openmp.c
	gcc -fopenmp -O3 -o spmv_openmp $(SRC_DIR)/spmv_openmp.c

spmv_serial: $(SRC_DIR)/spmv_serial.c
	gcc -O3 -o spmv_serial $(SRC_DIR)/spmv_serial.c

spmv_not_csr: $(SRC_DIR)/spmv_not_csr.c
	gcc -O3 -o spmv_not_csr $(SRC_DIR)/spmv_not_csr.c

clean:
	rm -f spmv_openmp spmv_serial spmv_not_csr

.PHONY: all clean

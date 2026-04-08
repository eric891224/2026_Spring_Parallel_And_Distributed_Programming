#!/usr/bin/env bash

set -uo pipefail

TESTCASE_ROOT="/home/Team43/testcases_hw2"
TESTCASE_SELECT="${1:-all}"
REPEATS="${2:-1}"
THREADS_FIXED=16

# Override these from env when you want a custom sweep.
# Example: SCHEDULES="static dynamic" CHUNKS="1 8 64" bash benchmark_openmp.sh huge_200k_100 3
SCHEDULES="${SCHEDULES:-static dynamic guided}"
CHUNKS="${CHUNKS:-1 2 4 8 16 32 64 128 256 512 1024 2048 4096}"
LOG_DIR="${LOG_DIR:-benchmark_logs}"

if ! [[ "$REPEATS" =~ ^[0-9]+$ ]] || [[ "$REPEATS" -lt 1 ]]; then
    echo "Error: repeats must be a positive integer (got: $REPEATS)"
    exit 1
fi

if [[ "$TESTCASE_SELECT" == "all" ]]; then
    mapfile -t TESTCASE_ARR < <(find "$TESTCASE_ROOT" -maxdepth 1 -type f -name "*.mtx" -printf "%f\n" | sed 's/\.mtx$//' | sort)
    if [[ "${#TESTCASE_ARR[@]}" -eq 0 ]]; then
        echo "Error: no .mtx files found under $TESTCASE_ROOT"
        exit 1
    fi
else
    TESTCASE_ARR=("$TESTCASE_SELECT")
fi

VALID_TESTCASE_ARR=()
for testcase_name in "${TESTCASE_ARR[@]}"; do
    mtx_path="$TESTCASE_ROOT/$testcase_name.mtx"
    vec_path="$TESTCASE_ROOT/$testcase_name.vec"
    if [[ ! -f "$mtx_path" ]]; then
        echo "Warning: skip $testcase_name (missing matrix: $mtx_path)"
        continue
    fi
    if [[ ! -f "$vec_path" ]]; then
        echo "Warning: skip $testcase_name (missing vector: $vec_path)"
        continue
    fi
    VALID_TESTCASE_ARR+=("$testcase_name")
done

if [[ "${#VALID_TESTCASE_ARR[@]}" -eq 0 ]]; then
    echo "Error: no valid testcases found under $TESTCASE_ROOT"
    exit 1
fi

if [[ ! -x ./spmv_openmp ]]; then
    echo "spmv_openmp not found. Building with make spmv_openmp..."
    if ! make spmv_openmp; then
        echo "Error: failed to build spmv_openmp"
        exit 1
    fi
fi

read -r -a SCHEDULE_ARR <<< "$SCHEDULES"
read -r -a CHUNK_ARR <<< "$CHUNKS"

W_TESTCASE=20
W_SCHEDULE=8
W_CHUNK=5
W_RUN=3
W_TIME=12
W_CHECK=5

for testcase_name in "${VALID_TESTCASE_ARR[@]}"; do
    if (( ${#testcase_name} > W_TESTCASE )); then
        W_TESTCASE=${#testcase_name}
    fi
done

for sched in "${SCHEDULE_ARR[@]}"; do
    if (( ${#sched} > W_SCHEDULE )); then
        W_SCHEDULE=${#sched}
    fi
done

for chunk in "${CHUNK_ARR[@]}"; do
    if (( ${#chunk} > W_CHUNK )); then
        W_CHUNK=${#chunk}
    fi
done

if (( ${#REPEATS} > W_RUN )); then
    W_RUN=${#REPEATS}
fi

repeat_char() {
    local ch="$1"
    local n="$2"
    printf '%*s' "$n" '' | tr ' ' "$ch"
}

mkdir -p "$LOG_DIR"
TS="$(date +%Y%m%d_%H%M%S)"
CSV_TAG="$TESTCASE_SELECT"
if [[ "$TESTCASE_SELECT" == "all" ]]; then
    CSV_TAG="all_testcases"
fi
CSV_PATH="$LOG_DIR/openmp_benchmark_${CSV_TAG}_${TS}.csv"

echo "testcase,threads,schedule,chunk,run,time_ms,verify,exit_code" > "$CSV_PATH"

echo "Running OpenMP benchmark"
echo "  testcase select: $TESTCASE_SELECT"
echo "  testcase root:   $TESTCASE_ROOT"
echo "  testcase count:  ${#VALID_TESTCASE_ARR[@]}"
echo "  threads:  $THREADS_FIXED"
echo "  repeats:  $REPEATS"
echo "  schedules: ${SCHEDULE_ARR[*]}"
echo "  chunks:    ${CHUNK_ARR[*]}"
echo "  csv:      $CSV_PATH"
echo

SEP_LINE="+-$(repeat_char '-' "$W_TESTCASE")-+-$(repeat_char '-' "$W_SCHEDULE")-+-$(repeat_char '-' "$W_CHUNK")-+-$(repeat_char '-' "$W_RUN")-+-$(repeat_char '-' "$W_TIME")-+-$(repeat_char '-' "$W_CHECK")-+"

echo "$SEP_LINE"
printf "| %-*s | %-*s | %*s | %*s | %*s | %-*s |\n" \
    "$W_TESTCASE" "testcase" \
    "$W_SCHEDULE" "schedule" \
    "$W_CHUNK" "chunk" \
    "$W_RUN" "run" \
    "$W_TIME" "time_ms" \
    "$W_CHECK" "check"
echo "$SEP_LINE"

for testcase_name in "${VALID_TESTCASE_ARR[@]}"; do
    mtx_path="$TESTCASE_ROOT/$testcase_name.mtx"
    vec_path="$TESTCASE_ROOT/$testcase_name.vec"
    for sched in "${SCHEDULE_ARR[@]}"; do
        for chunk in "${CHUNK_ARR[@]}"; do
            for ((run=1; run<=REPEATS; run++)); do
                output=""
                if output=$(OMP_NUM_THREADS="$THREADS_FIXED" OMP_SCHEDULE="${sched},${chunk}" \
                    ./spmv_openmp "$mtx_path" "$vec_path" 2>&1); then
                    exit_code=0
                else
                    exit_code=$?
                fi

                time_ms=$(echo "$output" | sed -n 's/.*spmv_openmp_time_ms=\([0-9.]*\).*/\1/p' | tail -n1)
                verify=$(echo "$output" | grep -Eo 'OK|WRONG' | tail -n1)

                if [[ -z "$time_ms" ]]; then
                    time_ms="NA"
                fi
                if [[ -z "$verify" ]]; then
                    verify="NA"
                fi

                echo "$testcase_name,$THREADS_FIXED,$sched,$chunk,$run,$time_ms,$verify,$exit_code" >> "$CSV_PATH"
                printf "| %-*s | %-*s | %*s | %*s | %*s | %-*s |\n" \
                    "$W_TESTCASE" "$testcase_name" \
                    "$W_SCHEDULE" "$sched" \
                    "$W_CHUNK" "$chunk" \
                    "$W_RUN" "$run" \
                    "$W_TIME" "$time_ms" \
                    "$W_CHECK" "$verify"
            done
        done
    done
done

echo "$SEP_LINE"
echo
echo "Benchmark finished. Results saved to: $CSV_PATH"

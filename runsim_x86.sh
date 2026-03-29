#!/usr/bin/env bash

set -euo pipefail

# Default number of runs
RUNS="${1:-10}"

BIN="./pre-built/Vibex_simple_system_Ubuntu2204_x86_64"
ARGS="--meminit=ram,./pre-built/coremark.elf +ibex_tracer_enable=0"

max_speed=0
max_run=0

echo "Running simulation $RUNS times..."
echo

for ((i=1; i<=RUNS; i++)); do
    echo "Run $i/$RUNS..."

    output="$($BIN $ARGS)"

    speed=$(echo "$output" | grep -oP 'Simulation speed:.*\(\K[0-9.]+(?= kHz)')

    if [[ -z "$speed" ]]; then
        echo "Warning: Could not extract speed for run $i"
        continue
    fi

    echo "  Speed: $speed kHz"

    if awk -v a="$speed" -v b="$max_speed" 'BEGIN {exit !(a > b)}'; then
        max_speed="$speed"
        max_run="$i"
    fi
done

echo
echo "=============================="
echo "Max simulation speed: $max_speed kHz (run $max_run)"
echo "=============================="

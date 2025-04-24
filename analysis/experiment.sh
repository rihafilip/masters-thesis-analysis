#!/bin/bash

set -e

if [[ -z "$1" ]]; then
  echo "Error: No Rsh folder supplied"
  exit 1
fi

BENCHMARKS=$(realpath ./Benchmarks)
RSH=$(realpath "$1")
export BENCHMARKS RSH

cmake --build $RSH -j

#---------------------

RESULT_FOLDER=results
rm -rf "$RESULT_FOLDER"
mkdir -p "$RESULT_FOLDER"

LOG=$(realpath "$RESULT_FOLDER/log")
STATS=$(realpath "$RESULT_FOLDER/stats.csv")
STATS_ALL=$(realpath "$RESULT_FOLDER/stats_all.csv")
export LOG STATS STATS_ALL

function run {
  read folder benchmark arg <<< "$1"

  cd "$BENCHMARKS/$folder"

  STATS_CSV="$STATS" STATS_ALL_CSV="$STATS_ALL" \
    PIR_OSR=0 PIR_WARMUP=10 \
    "$RSH/bin/Rscript" harness.r "$benchmark" 15 "$arg" \
    2>&1 1>/dev/null
}

export -f run

parallel -j 48 --bar run ::: \
  "areWeFast Mandelbrot 500" \
  "areWeFast Bounce_nonames_simple 35" \
  "shootout binarytrees/binarytrees_naive 9" \
  "shootout fannkuch/fannkuchredux 9" \
  "shootout fannkuch/fannkuchredux_naive 9" \
  "shootout fasta/fasta_naive_2 80000" \
  "shootout knucleotide/knucleotide 2000" \
  "shootout pidigits/pidigits 30" \
  "RealThing volcano 1" \
  "RealThing flexclust_no_s4 5" \
  > "$LOG"


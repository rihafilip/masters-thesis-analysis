#!/bin/bash

set -e

if [[ -z "$1" ]]; then
  echo "Error: No Rsh folder supplied"
  exit 1
fi

export RSH=$(realpath "$1")

export BENCHMARKS=$(realpath ./Benchmarks)
export TITANIC=$(realpath ./titanic/code)

cmake --build $RSH -j

#---------------------

RESULT_FOLDER=results
rm -rf "$RESULT_FOLDER"
mkdir -p "$RESULT_FOLDER"

export LOG=$(realpath "$RESULT_FOLDER/log")
export STATS_CSV=$(realpath "$RESULT_FOLDER/stats.csv")
export STATS_ALL_CSV=$(realpath "$RESULT_FOLDER/stats_all.csv")
export STATS_BY_SLOTS=$(realpath "$RESULT_FOLDER/stats_by_slots.csv")

#---------------------

function run {
  export PIR_OSR=0
  export PIR_WARMUP=10

  if [[ "$1" = "titanic" ]]; then
    cd "$TITANIC"

    STATS_NAME=kaggle:titanic "$RSH/bin/R" -q -f titanic.R 2>&1 1> /dev/null
  else
    read folder benchmark arg <<< "$1"

    cd "$BENCHMARKS/$folder"

    "$RSH/bin/Rscript" harness.r "$benchmark" 15 "$arg" 2>&1 1>/dev/null
  fi
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
  "titanic" \
  > "$LOG"


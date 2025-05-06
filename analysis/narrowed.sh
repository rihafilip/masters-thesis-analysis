#!/bin/bash

set -e

rg "narrowed with static type: yes" results/log --context 3 > results/narrowed_full

# Print only the usage,
# remove required,
# print the unique values and their count
# each on their own line
# and strip leading spaces
awk 'NR % 8 == 6' results/narrowed_full | \
  rg '(.*),[^,]' --only-matching --replace ', $1' | \
  sort | uniq --count | \
  awk -F', ' '{for (i=1; i<=NF;i++) { print $i }; printf "\n" }' | \
  sed -E 's/^ +//' \
    > results/narrowed

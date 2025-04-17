#!/usr/bin/env bash

set -e

ROOT=$(realpath $(dirname "$0"))

REBENCH="$ROOT/rebench.conf"
BENCHMARKS="$ROOT/Benchmarks"

RSH=""

ENVIR=""
DATAFILE_ARG=""

function usage {
  echo "Usage: $0 [--help] --rsh <RIR-ROOT> [--rebench <rebench-file>] [--benchmarks <benchmarks-folder>] [--env <ENV>] [--data-file <FILE>]"
  echo 'ENV is in format KEY: "VALUE", values needs to be quoted, separated by comma (,)'
}

function needs_arg {
  echo "Error: $1 needs an argument"
  usage
  exit 1
}

while true; do
  case "$1" in
    --help)
      usage
      exit 0
      ;;

    --rsh)
      [[ -z "$2" ]] && needs_arg "$1"
      RSH=$(realpath "$2")
      shift 2
      ;;

    --rebench)
      [[ -z "$2" ]] && needs_arg "$1"
      REBENCH=$(realpath "$2")
      shift 2
      ;;

    --benchmarks)
      [[ -z "$2" ]] && needs_arg "$1"
      BENCHMARKS=$(realpath "$2")
      shift 2
      ;;

    --env)
      [[ -z "$2" ]] && needs_arg "$1"
      ENVIR="$2"
      shift 2
      ;;

    --data-file)
      [[ -z "$2" ]] && needs_arg "$1"
      DATAFILE_ARG="--data-file $(realpath "$2")"
      shift 2
      ;;

    *)
      break
      ;;
  esac
done

if [[ -z "$RSH" ]]; then
  echo "Error: RSH not set"
  exit 1
fi

if [[ ! -d "$RSH" ]]; then
  echo "Error: folder $RSH (rsh) does not exist"
  exit 1
fi

if [[ ! -f "$REBENCH" ]]; then
  echo "Error: file $REBENCH (rebench) does not exist"
  exit 1
fi

if [[ ! -d "$BENCHMARKS" ]]; then
  echo "Error: folder $BENCHMARKS (benchmarks) does not exist"
  exit 1
fi

TMPDIR=$(mktemp -d /tmp/rbench.XXXXXX)
pushd "$TMPDIR" > /dev/null

LOCAL_REBENCH="./rebench.conf"

cp "$REBENCH" "$LOCAL_REBENCH"

sed -i "s+%%BENCHMARKS_PATH%%+$BENCHMARKS+" "$LOCAL_REBENCH"
sed -i "s+%%RSH_VM%%+$RSH+" "$LOCAL_REBENCH"
sed -i "s+%%ENV%%+$ENVIR+" "$LOCAL_REBENCH"

rebench "$LOCAL_REBENCH" e:RSH -R $DATAFILE_ARG

popd > /dev/null
rm -rf "$TMPDIR"

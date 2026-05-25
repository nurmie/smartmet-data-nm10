#!/bin/sh

if [ -s /smartmet/cnf/data/aws-ukraine.cnf ]; then
    . /smartmet/cnf/data/aws-ukraine.cnf
fi

if [ -d /smartmet ]; then
    BASE=/smartmet
else
    BASE=$HOME
fi
LOGFILE=$BASE/logs/data/aws.log

# Truncate log and capture stderr when running non-interactively (cron).
# Stdout is left alone — it feeds the CSV accumulator file.
# convert-to-sqd.sh appends to the same file afterward.
if [ "${TERM:-}" = "dumb" ]; then
    mkdir -p "$(dirname "$LOGFILE")"
    : > "$LOGFILE"
    exec 2>> "$LOGFILE"
fi

# Fetch data from ftp server
wget --mirror \
    --no-host-directories \
    --directory-prefix=$MODEL_RAW_ROOT \
    --ftp-user=$USER \
    --ftp-password=$PASS \
    --accept="aws*.csv" \
    $HOST/

# Parse data into csv2qd input format
set -euo pipefail
mkdir -p $OUTDIR

OUT=$OUTDIR/csv2qd_input_tmp.csv
: > "$OUT"

for dir in $MODEL_RAW_ROOT/aws810/aws*; do
  echo "Processing $dir" >&2

  find "$dir" -maxdepth 1 -type f -name 'aws*obs_csv_*.csv' -print0 \
    | sort -z \
    | xargs -0 --no-run-if-empty -n 1000 bash ./parse-nm10-csvtoqd.sh "$PARAMS" \
    >> "$OUT"
done

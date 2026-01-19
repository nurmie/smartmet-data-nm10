#!/bin/sh

if [ -s /smartmet/cnf/data/aws-ukraine.cnf ]; then
    . /smartmet/cnf/data/aws-ukraine.cnf
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
    | xargs -0 -n 1000 bash ./parse-nm10-csvtoqd.sh "$PARAMS" \
    >> "$OUT"
done

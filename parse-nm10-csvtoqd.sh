#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./parse-nm10-csvtoqd.sh params.txt aws*obs_csv_*.csv > csv2qd_input.csv

PARAMS_FILE="${1:?params file required}"
shift
[[ $# -ge 1 ]] || { echo "No input files given" >&2; exit 2; }
[[ -r "$PARAMS_FILE" ]] || { echo "Cannot read $PARAMS_FILE" >&2; exit 1; }

for f in "$@"; do
  base="$(basename "$f")"

  # Extract station id and timestamp from filename
  if [[ "$base" =~ ^aws([0-9]+)obs_csv_([0-9]{8}T[0-9]{6})\.csv$ ]]; then
    station="${BASH_REMATCH[1]}"
    ts="${BASH_REMATCH[2]}"
  else
    echo "Skipping (bad name): $base" >&2
    continue
  fi

  # Validate station ID is non-empty
  [[ -n "$station" ]] || { echo "Empty station in $base" >&2; continue; }

  # Convert timestamp → "YYYY-MM-DD HH:MM:SS"
  yyyy="${ts:0:4}"; mm="${ts:4:2}"; dd="${ts:6:2}"
  HH="${ts:9:2}"; MI="${ts:11:2}"; SS="${ts:13:2}"
  timestamp="${yyyy}-${mm}-${dd} ${HH}:${MI}:${SS}"

  # Validate timestamp components are numeric
  [[ "$yyyy$mm$dd$HH$MI$SS" =~ ^[0-9]{14}$ ]] || { echo "Invalid timestamp in $base" >&2; continue; }

  # Read first line, strip CR, remove leading "$," and drop checksum "*...."
  line="$(head -n 1 "$f" | tr -d '\r')"
  line="${line#\$,}"
  line="${line%%\**}"

  awk -v station="$station" -v timestamp="$timestamp" \
      -v params_file="$PARAMS_FILE" -v line="$line" '
    BEGIN {
      FS=","
      # load params in order
      n=0
      while ((getline p < params_file) > 0) {
        gsub(/\r/, "", p)
        sub(/^[ \t]+/, "", p); sub(/[ \t]+$/, "", p)
        if (p == "" || p ~ /^#/) continue
        n++; want[n]=p
      }
      close(params_file)
      if (n == 0) exit(1)

      # parse key,value pairs from line
      m = split(line, a, ",")
      for (i=1; i+1<=m; i+=2) {
        k=a[i]; v=a[i+1]
        gsub(/^[ \t]+|[ \t]+$/, "", k)
        gsub(/^[ \t]+|[ \t]+$/, "", v)
        if (k != "" && v != "/") kv[k]=v
      }

      # emit row (NO HEADER)
      printf "%s,%s", station, timestamp
      for (i=1; i<=n; i++) {
        k=want[i]
        if (k in kv) printf ",%s", kv[k]
        else         printf ","
      }
      printf "\n"
    }
  '
done
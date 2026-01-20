# smartmet-data-nm10

Scripts for fetching, parsing, and converting Vaisala NM10 AWS (Automatic Weather Station) observation data into SmartMet querydata format.

## Overview

This repository contains tools to:

1. **Fetch** raw AWS observation data from an FTP server
2. **Parse** CSV files into csv2qd-compatible format
3. **Convert** the parsed data into SmartMet querydata (SQD) format

## Scripts

### update.sh

**This needs to customized modified per installation location**

Main entry point script that:
- Fetches AWS observation data from a configured FTP server using `wget --mirror`
- Processes downloaded files through the parsing pipeline
- Requires configuration file in `/smartmet/cnf/data/{name}.cnf`

### parse-nm10-csvtoqd.sh

Parses raw NM10 AWS CSV observation files into csv2qd input format.

**Usage:**
```bash
./parse-nm10-csvtoqd.sh params.txt aws*obs_csv_*.csv > csv2qd_input.csv
```

**Input filename format:** `aws<station_id>obs_csv_<YYYYMMDD>T<HHMMSS>.csv`

**Features:**
- Extracts station ID and timestamp from filenames
- Reads parameter values from key-value pairs in CSV
- Outputs data in csv2qd-compatible format

### convert-to-sqd.sh

Converts parsed CSV observation data to SmartMet querydata format.

**Features:**
- Uses `csv2qd` tool for conversion
- Compresses output with `pbzip2`
- Delivers files to querydata directory and editor inbox

## Configuration Files

### nm10-params.txt

Parameter mapping file containing NM10 sensor parameter names:

| Parameter | Description |
|-----------|-------------|
| TAAVG1M | Temperature (1-minute average) |
| RHAVG1M | Relative Humidity (1-minute average) |
| QFEAVG1M | Pressure (1-minute average) |
| TDAVG1M | Dew Point (1-minute average) |
| WS1 | Wind Speed |
| WD1 | Wind Direction |
| WGD1VALUE10M | Wind Gust (10-minute) |
| PRSUM1H | Precipitation (1-hour sum) |

## Directory Structure

The scripts expect the following directory structure:

```
/smartmet/
├── cnf/data/{name}.cnf    # Configuration file
├── data/aws/{area}/querydata/ # Output querydata files
├── editor/in/                  # Compressed files for editor
├── logs/data/                  # Log files
├── run/data/aws/cnf/
│   ├── stations.csv            # Station metadata
│   └── parameters.csv          # Parameter definitions
└── tmp/data/aws/               # Temporary processing directory
```

## Dependencies

- `csv2qd` - SmartMet tool for CSV to querydata conversion
- `wget` - For FTP data fetching
- `pbzip2` - For parallel bzip2 compression
- Bash 4.0+ (for regex matching in parse script)

## Configuration

Create `/smartmet/cnf/data/{name}.cnf` 


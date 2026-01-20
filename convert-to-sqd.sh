#!/bin/bash
# Convert CSV obs files from local AWS data feed.

if [ -d /smartmet ]; then
    BASE=/smartmet
else
    BASE=$HOME
fi

IN=$BASE/tmp/data/aws/
OUT=$BASE/data/aws/ukraine/querydata
EDITOR=$BASE/editor/in
TMP=$BASE/tmp/data/aws
TIMESTAMP=`date +%Y%m%d%H%M`
LOGFILE=$BASE/logs/data/aws.log

STATIONFILE=$BASE/run/data/aws/cnf/stations.csv
OBSFILE=$TMP/${TIMESTAMP}_aws_ukraine.sqd
PARAMFILE=/smartmet/run/data/aws/cnf/parameters.csv
PARAMORDER=idtime
PARAMS=Temperature,Humidity,Pressure,DewPoint,WindSpeedMS,WindDirection,WindGust,Precipitation1h

mkdir -p $TMP
mkdir -p $OUT

# Use log file if not run interactively
if [ $TERM = "dumb" ]; then
    exec &> $LOGFILE
fi

echo "IN:  $IN"
echo "OUT: $OUT"
echo "TMP: $TMP"
echo "OBS File: $OBSFILE"

# convert csv to qd
csv2qd -v --prodnum 1001 --prodname SYNOP -S $STATIONFILE -O $PARAMORDER -P $PARAMFILE -p $PARAMS $IN/*csv $OBSFILE 

# compres and deliver sqd
if [ -s $OBSFILE ]; then
    pbzip2 -k $OBSFILE
    mv -f $OBSFILE $OUT
    mv -f ${OBSFILE}.bz2 $EDITOR
fi

# Clean temp
cd $TMP
rm -fr $TMP/*_aws*sqd

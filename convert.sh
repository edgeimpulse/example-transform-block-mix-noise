#!/bin/bash
set -e

# Downsample and mix files (for Arribada)
# Example usage:
# /bin/bash convert.sh --in-file source.wav --out-directory out/
#                      --frequency 16000 --out-count 10
# ^ Turns 1 file into 10 files with mixed background noise (from /app/segments directory)
#   Background noise section & loudness is randomly changed.

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --in-file)
    IN_FILE="$2"
    shift # past argument
    shift # past value
    ;;
    --out-directory)
    OUT_DIRECTORY="$2"
    shift # past argument
    shift # past value
    ;;
    --out-count)
    OUT_COUNT="$2"
    shift # past argument
    shift # past value
    ;;
    --frequency)
    FREQUENCY="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ ! "$IN_FILE" ]; then
    echo "Missing --in-file"
    exit 1
fi

if [ ! "$OUT_DIRECTORY" ]; then
    echo "Missing --out-directory"
    exit 1
fi

if [ ! "$FREQUENCY" ]; then
    echo "Missing --frequency"
    exit 1
fi

if [ ! "$OUT_COUNT" ]; then
    echo "Missing --out-count"
    exit 1
fi

mkdir -p $OUT_DIRECTORY
FILENAME=$(basename -- "$IN_FILE")
EXTENSION="${FILENAME##*.}"
FILENAME="${FILENAME%.*}"

# copy the current file (not mixed) in as well
OUT_FILE_NOT_MIXED="$OUT_DIRECTORY/$FILENAME.$EXTENSION"
sox "$IN_FILE" -c 1 -r $FREQUENCY "$OUT_FILE_NOT_MIXED"

# then loop from 1..OUT_COUNT and create mixed files
i=1
while [[ $i -lt $OUT_COUNT ]] ; do
    MIX_FILE_IN=/app/segments/$(ls /app/segments/ | shuf -n 1)
    OUT_FILE="$OUT_DIRECTORY/$FILENAME.m$i.$EXTENSION"
    MIX_FILE=/tmp/mix.wav
    IN_FILE_TMP=/tmp/in.wav

    # convert the mix file to right frequency
    sox "$MIX_FILE_IN" -c 1 -r $FREQUENCY "$MIX_FILE"
    # convert in file to right frequency
    sox "$IN_FILE" -c 1 -r $FREQUENCY "$IN_FILE_TMP"

    # merge two files
    sox -m -v 1 "$IN_FILE_TMP" -v 0.$((RANDOM%4+1)) "$MIX_FILE" "$OUT_FILE" trim 0 `soxi -D "$IN_FILE_TMP"`

    (( i += 1 ))
done

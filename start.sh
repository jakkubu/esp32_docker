#!/bin/bash

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
esp32_port=$(realpath /dev/ttyESP32)
dry_run=false

while getopts "p:d" opt; do
    case "$opt" in
    p)  esp32_port=$OPTARG
        ;;
    d)  dry_run=true
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# get current script directory regardless of folder you are calling it from
# via https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo $esp32_port

if [ "$dry_run" = true ] ; then
    docker run -it --rm \
        --mount type=bind,source="$(pwd)",target=/project \
        esp32 \
        /bin/bash
else
    docker run -it --rm \
        --device=$esp32_port:/dev/ttyUSB0 \
        --mount type=bind,source="$(pwd)",target=/project \
        esp32 \
        /bin/bash
fi


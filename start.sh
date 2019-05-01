#!/bin/bash

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
esp32_port=$(realpath /dev/ttyESP32)

while getopts "p:" opt; do
    case "$opt" in
    p)  esp32_port=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# get current script directory regardless of folder you are calling it from
# via https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo $esp32_port

docker run -it --rm \
	--device=$esp32_port:/dev/ttyESP32_docker \
	--mount type=bind,source="$(pwd)",target=/project \
	esp32 \
	/bin/bash

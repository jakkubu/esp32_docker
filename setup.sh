#!/bin/bash

# directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

rebuild=false

touch docker_bash_history

if [ ! -d $(pwd)/esp-idf ]; then
	touch $DIR/requirements.txt
	# In order to avoid pip  "at least one to install" error message
	echo "setuptools" >> $DIR/requirements.txt
	rebuild=true
else
	cp "$(pwd)/esp-idf/requirements.txt" "$DIR"
fi

echo -e "\e[36mBuilding esp32 docker image \e[0m"
docker build -t=esp32 --build-arg IDF_REBUILD="$RANDOM" "$DIR"

if [ "$rebuild" = true ] ; then
    # There is no esp-idf in project path - download it from docker container
    # We use for it entrypoint script
    echo -e "\e[36mRunning docker to download esp-idf\e[0m"
    docker run --rm \
		--mount type=bind,source="$(pwd)",target=/project \
		esp32 \
		/bin/bash -c exit

	cp "$(pwd)/esp-idf/requirements.txt" "$DIR"

    echo -e "\e[36mRebuilding docker image with proper esp-idf requirements.txt\e[0m"
	docker build -t=esp32 --build-arg IDF_REBUILD="rebuild" "$DIR"
else
	echo -e "
\e[33mATTENTION\e[0m
\e[36mUsing pre-downloaded esp-idf located in $(pwd)/esp-idf.\e[0m
Make sure esp-idf is downloaded from esp32 docker container. ESP_IDF repo contains git submodules and therefore clone command:

	git clone --recursive https://github.com/espressif/esp-idf.git

has to be run from build environment (in this case - esp32 docker container). If esp-idf was downloaded during previously called esp32_docker setup.sh it should be OK"
fi

rm $DIR/requirements.txt

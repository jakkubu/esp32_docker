#!/usr/bin/env bash

echo "checking if \$IDF_PATH: $IDF_PATH exists"

if [ ! -d $IDF_PATH ]; then
	echo "$IDF_PATH - doesn't exists - creating"
	cd $IDF_PATH/..
	echo $IDF_PATH "cloning esp-idf repository to $IDF_PATH"
	git clone --recursive https://github.com/espressif/esp-idf.git
	cp -f $IDF_PATH/requirements.txt /config
	echo "After copying esp-idf to working dir you should rebuild docker file with build argument IDF_REBUILD e.g.:
		docker build -t=esp32 --build-arg IDF_REBUILD=$RANDOM ."
	chmod -R o=u /project
	exit
fi

chmod -R o=u /project

# EXECUTE COMMAND
exec "$@"

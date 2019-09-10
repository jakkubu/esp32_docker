FROM debian:stable

RUN apt-get -qq update && apt-get install -y \
	gcc \
	git \
	wget \
	make \
	libncurses-dev \
	flex \
	bison \
	gperf \
	python \
	python-pip \
	python-setuptools \
	python-serial \
	python-cryptography \
	python-future \
	python-pyparsing

WORKDIR /esp32
RUN wget "https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz" \
	&& tar -xzf "xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz" \
	&& rm "xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz"

ENV PATH "$PATH:/esp32/xtensa-esp32-elf/bin"
ENV IDF_PATH "/project/esp-idf"
ENV HISTFILE "/project/docker_bash_history"
ENV INPUTRC "/config/inputrc"

# use this argument as point of rebuild
ARG IDF_REBUILD

# config setting up entryponint file + shell config files
COPY config /config
RUN echo ". /config/.bashrc_usr" >> ~/.bashrc

COPY requirements.txt /esp32/
RUN python -m pip install --user -r requirements.txt

WORKDIR /project

ENTRYPOINT ["/config/entrypoint.sh"]

CMD ["/bin/bash"]

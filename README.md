# esp32_docker
Docker developer environment for building and flashing esp32 applications.

This project provide easy setup and run commands for building and flashing code to esp32 device.

Features list:
* ./esp32_docker/setup.sh command to create and setup docker image
* ./esp32_docker/start.sh to start container
* save bash history to docker_bash_history file within your project
* provides nice colored shell that gives you clear indication that you are in container
* provides PageUp and PageDown for bash history lookup

Tested only in Linux. It should work for other systems (except for configuring static device name, but it's not necessary for building and uploading code). Contributions for Windows and Mac are welcome.

## Setup guide

### Install docker

[https://docs.docker.com/install/overview/](https://docs.docker.com/install/overview/)

### Build esp32_docker image

The esp32_docker folder can live in any place in your device. I recommend to put it inside your project folder, as you can use different toolchain versions for each project.

    mkdir project
    cd project/
    git clone https://github.com/jakkubu/esp32_docker.git
    ./esp32_docker/setup.sh

ESP-IDF git repository uses git submodules and therefore it need to be downloaded from build environment (in our case from esp32 docker container). It could live only in docker container, but I use it for function lookup and I like to have it in the same folder as my project. Because of this during setup docker will build 2 times.

During first build we download and build xtensa toolchain (it may take long time).

After first build setup script will run docker container. Then `entrypoint.sh` script clone esp-idf repository project folder. Then we need to build docker image again with proper esp-idf `requirements.txt` file. It uses cache so second build is much faster.

### Start container and check build & upload

To connect to USB device you may need to execute `start.sh` as root or administrator. Alternatively in Linux you can also add current user to dialout group - it will ensure that user will have permissions to connect to USB serial device

    sudo usermod -a -G dialout $USER

From your project folder plug in esp32 and start docker container:

    ./esp32_docker/start.sh -p <esp32_usb_port>

This will start docker container and move you to it's shell and move you to `/project` directory. The folder you run the above command is mounted in dockers `/project` folder.


To check if everything works copy esp-idf `get-started/hello_world` to your project dir (from docker container):

    cp -r $IDF_PATH/examples/get-started/hello_world .

Then set serial port to `/dev/ttyESP32_docker` for hello_world project. To do this follow [get-start guide step: Configure from esp-idf doc](https://docs.espressif.com/projects/esp-idf/en/latest/get-started/index.html#step-7-configure)

After setting proper serial and saving configuration make flash and monitor the code:

    make flash monitor

This should build your code, upload it to esp32 device and show you startup sequence and counting down to device restart. Turn off monitoring using `ctrl+]`.

To leave container press `ctrl+d` or type `exit`. Docker container will be cleaned up (but image will still be there).

### Set static USB device name (only for Linux)

USB ports may change and it's inconvenient to check every time proper usb device. If you setup static symlink to `/dev/ttyESP32` you may execute `start.sh` without -p attribute.

Connect esp32 device and find exact ttyUSB number:

    dmesg | grep ttyUSB

Find device attributes:

    udevadm info -a -p  $(udevadm info -q path -n /dev/ttyUSB0)

Create file in `/etc/udev/rules.d/` folder with *.rules extension e.g.: `20-ESP32.rules` and add some udev rules to it:

    # ESP-WROOM-32
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="ttyESP32"
    # ESP32-WROOVER
    SUBSYSTEM=="tty", ATTRS{bInterfaceNumber}=="01", ATTRS{interface}=="Dual RS232-HS", SYMLINK+="ttyESP32"
    SUBSYSTEM=="tty", ATTRS{bInterfaceNumber}=="00", ATTRS{interface}=="Dual RS232-HS", SYMLINK+="ttyESP32_JTAG"


reload udev rules

    sudo udevadm control --reload-rules && udevadm trigger

Plug out and in esp device and check if it worked:

    ls -l /dev/ | grep ESP

Now you can start docker with:

    ./esp32_docker/start.sh


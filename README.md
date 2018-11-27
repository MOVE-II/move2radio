# Move2Radio
Software to receive MOVE-II frames using sdr sticks. The hardware supported by this project is all hardware supported by [gr-osmosdr](https://github.com/osmocom/gr-osmosdr).
Move2Radio is supported on Linux using the AppImage format. The software will decode the nanolink frames sent by the satellite and send it to the MOVE server via HTTP.

## Download
You can download the newest version of move2radio here: TODO

## Install
The AppImage itself can simply be started like a executable. On most linux systems you will have to mark the file as executable after download:
 1. right click on file
 2. properties
 3. permission
 4. mark as executable

### SDR stick driver
To run this software you will need a SDR-stick compatible with [gr-osmosdr](https://github.com/osmocom/gr-osmosdr).
The stick needs to be installed in your operating system for SDR usage. This means a udev rule will have to be installed and the kernel driver deactivated.
#### Example for rtl_sdr devices
The following is an example, you will have to find the exact udev rules needed for your device using google.


First create a file `/etc/udev/rules.d/50-rtlsdr.rules` with the following content:
```
SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="adm", MODE="0666", SYMLINK+="rtl_sdr"
```
Then reload the udev rules:
```
sudo udevadm control --reload
sudo udevadm trigger
```
As final step remove the kernel driver (Note, see next if this does not work on your system):
```
sudo rmmod dvb_usb_rtl28xxu
```
To make this permanent, add the module to the module blacklist. Create a file `/etc/modprobe.d/sdr.conf` with the following content:
```
blacklist dvb_usb_rtl28xxu
```
and reboot!

Now start move2radio and it should detect the sdr stick!

## Usage
Just start move2radio.AppImage and wait until it launches. The terminal that opens will tell you if there are any errors.
When the program started, your session-id will be printed in the terminal. To later see which data you provided to the MOVE-II project, write this session-id down.
Use the frequency slider to receive the correct frequency of the satellite.

## Build
This repository provides the build script used to build move2radio. It downloads all needed sources as compiles them as needed.
### AppImage
You can build the whole software package with the following commands:
```
mkdir build && cd build
cmake ..
make appimage
```
### Components
Each component of the software can be built by itself. For example to build only the gr-ccsds gnuradio blocks:
```
make build_gr_ccsds
```
Similarily, to only build the exact gnuradio version used in move2radio:
```
make build_gnuradio
```

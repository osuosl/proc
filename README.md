# proc
Source code for proc_v1


The IDE is arduino; for the model select  arduino uno  
Connect the board's serial port to the computer and you can compile and download.

Compiling from the command line:  
Run build.sh, which uses arduino-cli to compile and download. If arduino-cli is missing it downloads arduino-cli automatically; if a library is missing the script downloads the library automatically. Once the build finishes, the rom is at prc.hex in the directory containing build.sh

Upgrading from the command line:
Connect the device to a usb serial port. If you are upgrading from the controlled machine, edit the script according to the serial device number, and under linux the serial login program must first release its hold on the serial port.   
Run update.sh, then apply power to the device as the countdown reaches 1, and the upgrade process starts.
If the upgrade fails, adjust the timing of when you power the device and try again. 

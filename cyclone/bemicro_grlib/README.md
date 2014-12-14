Compile Leon design for BeMicro SDK. Including LPDDR controller. Issue

 make all

and use grlib-gpl-1.3.7-b4144/designs/leon3-arrow-bemicro-sdk/*.sof to program BeMicro SDK. You can issue

 cd grlib-gpl-1.3.7-b4144/designs/leon3-arrow-bemicro-sdk
 make quartus-prog-fpga

to program from commandline. Tested with Quartus 13.0.

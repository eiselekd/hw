all:

ice-compile:
	sudo apt-get install build-essential clang bison flex libreadline-dev \
                     gawk tcl-dev libffi-dev git mercurial graphviz   \
                     xdot pkg-config python python3 libftdi-dev
	cd icestorm; make

restore-blink:
	icestorm/iceprog/iceprog -S LED_VHDL_bitmap.bin

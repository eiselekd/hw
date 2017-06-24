
mxoprog: mxoprog.c libxsvf.h play.c scan.c svf.c tap.c statename.c
	gcc -o mxoprog -Wall -Os mxoprog.c play.c scan.c svf.c tap.c statename.c -lwiringPi -lrt

install: mxoprog
	sudo install mxoprog /usr/local/bin/
	sudo chmod u+s /usr/local/bin/mxoprog

uninstall:
	sudo rm -f /usr/local/bin/mxoprog

clean:
	rm -f mxoprog

.PHONY: install clean


all:
	tar xvf grlib-gpl-1.3.7-b4144.tar.gz
	cat grlib.patch | patch -p1 -d grlib-gpl-1.3.7-b4144
	cd grlib-gpl-1.3.7-b4144/designs/leon3-arrow-bemicro-sdk; \
		make quartus


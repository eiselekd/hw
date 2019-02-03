all:

uni:
	gcc uni.c -o uni.exe -I../../unicorn/include ../../unicorn/libunicorn.a -lm -lpthread


prepare:
	apt-get install verilator cmake

keystone-build:
	mkdir -p keystone-src/build keystone-lib/
	cd keystone-src/build; ../make-share.sh
	cp -d keystone-src/build/llvm/lib/libkeystone.so* keystone-lib/
	cp -d keystone-src/build/llvm/lib/libkeystone.so* keystone/

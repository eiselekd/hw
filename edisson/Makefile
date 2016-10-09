SDK=/mnt/btfs0/git/edisson/poky-edison
P=$(SDK)/1.7.3

sdk:
	#https://software.intel.com/en-us/iot/hardware/edison/downloads
	wget http://iotdk.intel.com/sdk/3.5/edison/iot-devkit-toolchain-linux-64bit-edison-20160606.sh
	bash iot-devkit-toolchain-linux-64bit-edison-20160606.sh -y -d $(SDK)

json:
	apt-get source libjson-c-dev
	source /mnt/btfs0/git/edisson/poky-edison/1.7.3/environment-setup-core2-32-poky-linux; \
	cd json-c-0.11; bash autogen.sh; ./configure --host=i586-poky-linux --prefix=/usr; \
	 make ; DESTDIR=$(P)/sysroots/core2-32-poky-linux make install -i

mraa: json
	git clone https://github.com/intel-iot-devkit/mraa.git
	cd mraa; mkdir -p build; \
	cmake -DCMAKE_LIBRARY_PATH=$(P)/sysroots/core2-32-poky-linux/usr/lib \
		-DCMAKE_C_COMPILER=$(P)/sysroots/x86_64-pokysdk-linux/usr/bin/i586-poky-linux/i586-poky-linux-gcc \
		-DCMAKE_CXX_COMPILER=$(P)/sysroots/x86_64-pokysdk-linux/usr/bin/i586-poky-linux/i586-poky-linux-g++ ..; \
	make ; 

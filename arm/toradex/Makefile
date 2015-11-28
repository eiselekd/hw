SHELL=bash
all: toradex-prepare-v-repo toradex-oe-core-switch-v25 toradex-oe-core-compile-v uboot

#sudo apt-get install diffstat chrpath sdl-config

toradex-prepare-v-repo:
	mkdir -p $(CURDIR)/bin; \
	export PATH=$(CURDIR)/bin:$$PATH; \
	  curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > $(CURDIR)/bin/repo; \
	chmod a+x $(CURDIR)/bin/repo

toradex-oe-core-switch-v24: toradex-prepare-v-repo
	mkdir -p $(CURDIR)/oe-core; \
	export PATH=$(CURDIR)/bin:$$PATH; \
	cd oe-core; \
        repo init -u http://git.toradex.com/toradex-bsp-platform.git -b LinuxImageV2.4; \
	repo sync

toradex-oe-core-switch-v25: toradex-prepare-v-repo
	export PATH=$(CURDIR)/bin:$$PATH; \
	cd oe-core; \
        repo init -u http://git.toradex.com/toradex-bsp-platform.git -b LinuxImageV2.5; \
	repo sync

# sudo apt-get install libusb-1.0-0-dev:i386
#cd oe-core;
# cross compiler at $(CURDIR)/hw/arm/toradex/build/out-glibc/sysroots/x86_64-linux/usr/bin/arm-angstrom-linux-gnueabi/*
toradex-oe-core-compile-v:
	# export from stuff/meta-toradex/buildconf/export
	source export; \
	if  cat build/conf/local.conf | grep ACCEPT_FSL_EULA; then \
		echo "Already present"; \
	else \
		sed -i  's/colibri-t20/apalis-imx6/g' build/conf/local.conf; \
		echo "ACCEPT_FSL_EULA = \"1\"" >> build/conf/local.conf; \
	fi; \
	MACHINE=apalis-imx6 bitbake -k angstrom-lxde-image

#angstrom-qt-x11-image

uboot: toradex-toolchain toradex-uboot-clone toradex-uboot

toradex-uboot:
	export ARCH=arm; \
	export CROSS_COMPILE=arm-linux-gnueabihf- \
	export PATH=$(CURDIR)/gcc-linaro/bin:$$PATH; cd u-boot-toradex; make apalis_imx6_defconfig; \
	make -j3 V=1  2>&1 | tee build.log

toradex-uboot-clone:
	git clone -b 2015.04-toradex git://git.toradex.com/u-boot-toradex.git

toradex-toolchain:
	wget http://releases.linaro.org/14.11/components/toolchain/binaries/arm-linux-gnueabihf/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf.tar.xz
	tar xvf gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf.tar.xz
	ln -s gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf gcc-linaro


####### v2.0 build :

toradex-prepare: toradex-repo
	export PATH=$$PATH:$(CURDIR)/bin; \
	mkdir -p apalis-imx6; cd apalis-imx6; \
	repo init -u http://git.toradex.com/toradex-bsp-platform.git -b LinuxImageV2.2; \
	repo sync

toradex-repo:
	mkdir -p bin
	curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > bin/repo; chmod a+x bin/repo

toradex-compile:
	cd apalis-imx6; source export
	cp apalis-imx6.conf apalis-imx6/build/conf/local.conf
	cd apalis-imx6; source export; bitbake -k angstrom-lxde-image
	cd apalis-imx6; \
	source export; bitbake -c cleanall gcc-cross-initial; \
	bitbake gcc-cross-initial; \
	bitbake -c cleanall gcc-cross-initial; \
	cd apalis-imx6; source export; bitbake -k angstrom-lxde-image

toradex-clean:
	rm -rf apalis-imx6

###### usb loader

loader:
	git clone https://github.com/boundarydevices/imx_usb_loader.git

##### openocd:
ocd:
	git clone git://git.code.sf.net/p/openocd/code openocd-code
	cd openocd-code; ./bootstrap;

ocd-build:
	cd openocd-code; \
	./configure --enable-ftdi --enable-legacy-ft2232_libftdi --prefix=$(CURDIR)/bin; make clean; make; make install

SHELL=bash
all: toradex-prepare toradex-compile

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
	. export; bitbake -c cleanall gcc-cross-initial; \
	bitbake gcc-cross-initial; \
	bitbake -c cleanall gcc-cross-initial; \
	cd apalis-imx6; source export; bitbake -k angstrom-lxde-image

toradex-clean:
	rm -rf apalis-imx6


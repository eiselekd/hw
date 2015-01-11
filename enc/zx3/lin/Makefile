get:
	git clone https://GitHub.com/enclustra/binaries.git
	sudo chmod –R 777 binaries
	#cp binaries/MarsZX3_on_MarsPM3/* /tftpboot/

build:
	git clone git://git.yoctoproject.org/poky; \
		cd poky; \
		git checkout -b daisy remotes/origin/daisy
	git clone git://git.openembedded.org/meta-openembedded; \
		cd meta-openembedded; \
	 	git checkout -b daisy remotes/origin/daisy
	git clone git://git.yoctoproject.org/meta-xilinx ; \
		cd meta-xilinx; \
		git checkout –b daisy remotes/origin/daisy; \
		cd..; \
		 git clone git://git.yoctoproject.org/meta-xilinx-community
	git clone https://github.com/enclustra/meta-enclustra.git

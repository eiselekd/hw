get:
	git clone https://GitHub.com/enclustra/binaries.git
	sudo chmod –R 777 binaries
	#cp binaries/MarsZX3_on_MarsPM3/* /tftpboot/

build-new:
	git clone https://github.com/enclustra-bsp/bsp-xilinx;
	cd bsp-xilinx; bash build.sh

build:
	git clone git://git.yoctoproject.org/poky; \
		cd poky; \
		git checkout -b daisy remotes/origin/daisy
	cd poky;git clone git://git.openembedded.org/meta-openembedded; \
		cd meta-openembedded; \
	 	git checkout -b daisy remotes/origin/daisy
	cd poky;git clone git://git.yoctoproject.org/meta-xilinx ; \
		cd meta-xilinx; \
		git checkout –b daisy remotes/origin/daisy; \
		cd ..; \
		git clone git://git.yoctoproject.org/meta-xilinx-community
	cd poky;git clone https://github.com/enclustra/meta-enclustra.git
	cd poky;git clone git://github.com/netmodule/uboot-ze7000.git;protocol=https



#sudo apt-get install xinetd tftpd tftp
# /etc/xinetd.d/tftp
#service tftp
#{
#protocol = udp
#port = 69
#socket_type = dgram
#wait = yes
#user = nobody
#server = /usr/sbin/in.tftpd
#server_args = /tftpboot
#disable = no
#}

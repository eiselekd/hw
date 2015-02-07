RISCV_VAR=$(CURDIR)/bin/
P=source riscv.sh

all:

env:
	echo "export RISCV=$(RISCV_VAR)"             >riscv.sh
	echo "export PATH=$(RISCV_VAR)/bin/:$$PATH" >>riscv.sh


git-preapre: env
	rm -rf rocket-chip
	git clone https://github.com/ucb-bar/rocket-chip.git
	cd rocket-chip; git submodule update --init --recursive;
	cd rocket-chip/riscv-tools; git submodule update --init --recursive riscv-tests

toolchain: env
	cd rocket-chip/riscv-tools; $(P); ./build.sh

# note: 4.8 gcc needed
toolchain-ubuntu:
	sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf

scala-ubuntu:
	sudo sh scala.sh


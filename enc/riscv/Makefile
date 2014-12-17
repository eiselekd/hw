RISCV_VAR=$(CURDIR)/bin/
P=export RISCV=$(RISCV_VAR); export PATH=$(RISCV_VAR)/bin/:$$PATH

all:

git-preapre:
	rm -rf rocket-chip
	git clone https://github.com/ucb-bar/rocket-chip.git
	cd rocket-chip; git submodule update --init --recursive;
	cd rocket-chip/riscv-tools; git submodule update --init --recursive riscv-tests

toolchain:
	cd rocket-chip/riscv-tools; $(P); ./build.sh

toolchain-ubuntu:
	sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf

scala-ubuntu:
	sudo sh scala.sh


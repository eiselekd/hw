PREFIX=$(CURDIR)/bin/or1k-toolchain
P=export PATH=$$PATH:$(PREFIX)

toolchain: gcc-prepare gcc-binutils gcc-gcc gcc-newlib gcc

gcc: gcc-clean gcc-binutils gcc-gcc gcc-newlib gcc

# from: https://github.com/embecosm/chiphack/wiki/OpenRISC-tools-install
gcc-prepare:
	mkdir tmp-gcc
	cd tmp-gcc; git clone git://github.com/openrisc/or1k-src.git
	cd tmp-gcc; git clone git://github.com/openrisc/or1k-gcc.git
	cd tmp-gcc; mkdir -p bld-or1k-src bld-or1k-gcc

gcc-clean:
	cd tmp-gcc; rm -rf bld-or1k-src bld-or1k-gcc

# Build the first set of tools, binutils etc.
gcc-binutils:
	mkdir -p tmp-gcc/bld-or1k-src
	cd tmp-gcc/bld-or1k-src; $P; ../or1k-src/configure --target=or1k-elf --prefix=$(PREFIX) --enable-shared --disable-itcl \
	    --disable-tk --disable-tcl --disable-winsup --disable-libgui --disable-rda --disable-sid \
	    --disable-sim --disable-gdb --with-sysroot --disable-newlib --disable-libgloss --disable-werror 2>&1 | tee configure.binutils.txt 
	cd tmp-gcc/bld-or1k-src; $P; make 2>&1 | tee compile.binutils.txt  ; make install 2>&1 | tee install.binutils.txt

# Build gcc only
gcc-gcc:
	mkdir -p tmp-gcc/bld-or1k-gcc
	cd tmp-gcc/bld-or1k-gcc; $P; ../or1k-gcc/configure --target=or1k-elf --prefix=$(PREFIX) --enable-languages=c --disable-shared --disable-libssp
	cd tmp-gcc/bld-or1k-gcc; $P;  make 2>&1 | tee compile.gcc-gcc.txt; make install | tee install.gcc-gcc.txt

# Build newlib
gcc-newlib:
	mkdir -p tmp-gcc/bld-or1k-src
	cd tmp-gcc/bld-or1k-src; $P; ../or1k-src/configure --target=or1k-elf --prefix=$(PREFIX) --enable-shared --disable-itcl \
	    --disable-tk --disable-tcl --disable-winsup --disable-libgui --disable-rda --disable-sid \
	    --enable-sim --disable-or1ksim --enable-gdb --with-sysroot --enable-newlib --enable-libgloss --disable-werror
	cd tmp-gcc/bld-or1k-src; $P; make make 2>&1 | tee compile.newlib.txt ; make install | tee install.newlib.txt

# build gcc again, this time with newlib
gcc-all:
	mkdir -p tmp-gcc/bld-or1k-gcc
	cd tmp-gcc/bld-or1k-gcc; $P; ../or1k-gcc/configure --target=or1k-elf --prefix=$(PREFIX) --enable-languages=c,c++ \
	    --disable-shared --disable-libssp --with-newlib
	cd tmp-gcc/bld-or1k-gcc; $P;  make 2>&1 | tee compile.gcc.txt; make install 2>&1 | tee install.gcc.txt


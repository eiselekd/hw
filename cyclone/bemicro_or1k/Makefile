TOP=bemicro

QUARTUS_CDB = quartus_cdb
QUARTUS_MAP = quartus_map --64bit
QUARTUS_FIT = quartus_fit --64bit
QUARTUS_ASM = quartus_asm
QUARTUS_STA = quartus_sta
QUARTUS_PGM = quartus_pgm
QUARTUS_SH  = quartus_sh

ALTCABLE ?= USB-BlasterII

quartus: qsys
	make quartus-map quartus-route

firmware:
	or1k-elf-as -o firmware.o firmware.S
	or1k-elf-objcopy --change-address 0x0 -O ihex firmware.o firmware.hex

qsys:
	rm -rf bemicro_soc
	ip-generate --file-set=QUARTUS_SYNTH \
		--report-file=csv:bemicro_soc/synthesis/bemicro_soc.csv \
		--report-file=qip:bemicro_soc/synthesis/bemicro_soc.qip \
		--report-file=spd:bemicro_soc/synthesis/bemicro_soc.spd \
		--output-directory=bemicro_soc/synthesis  --output-name=bemicro_soc bemicro_soc.qsys;
	ip-generate --file-set=SIM_VERILOG   \
		--report-file=csv:bemicro_soc/simulation/bemicro_soc.csv \
		--report-file=spd:bemicro_soc/simulation/bemicro_soc.spd \
		--output-directory=bemicro_soc/simulation --output-name=bemicro_soc bemicro_soc.qsys;
	ip-make-simscript --spd=bemicro_soc/simulation/bemicro_soc.spd --compile-to-work --output-directory=bemicro_soc/simulation
	# add include path to vlog compile
	cp bemicro_soc/simulation/mentor/msim_setup.tcl bemicro_soc/simulation/mentor/msim_setup.tcl.bck
	cat bemicro_soc/simulation/mentor/msim_setup.tcl.bck | \
		perl -e ' while(<>) { my $$l = $$_ ; if ($$l =~ /submodules\/mor1kx/) {$$l =~ s/[\n\s]*$$//; $$l .= " +incdir+$(CURDIR)/bemicro_soc/simulation/submodules\n"; }; print ($$l); } ' > tmp2.tcl
	cp tmp2.tcl bemicro_soc/simulation/mentor/msim_setup.tcl
	echo "" > bemicro_soc/generated

quartus-map: $(TOP)_quartus.qsf
	$(QUARTUS_MAP) --import_settings_files=on  --export_settings_files=off $(TOP)_quartus -c $(TOP)_quartus
	$(QUARTUS_SH) -t pin_assign_wrap.tcl quartus_map     $(TOP)_quartus $(TOP)_quartus

quartus-route: $(TOP)_quartus.qsf
	$(QUARTUS_CDB) --merge $(TOP)_quartus
	$(QUARTUS_FIT) --import_settings_files=off --export_settings_files=off $(TOP)_quartus -c $(TOP)_quartus
	$(QUARTUS_ASM) --import_settings_files=off --export_settings_files=off $(TOP)_quartus -c $(TOP)_quartus
	$(QUARTUS_STA) $(TOP)_quartus

quartus-prog-fpga:
	$(QUARTUS_PGM) -c $(ALTCABLE) -m JTAG -o p\;output/$(TOP)_quartus.sof

quartus-srec:
	$(QUARTUS_PGM)

quartus-clean:
	-rm -rf db *.syr *.qws automake.log dumpdata.txt \
        *.rpt *.done *.eqn *.pof *.summary *.ttf *.pin *.sof \
	*.jam *.jbc cmp_state.ini simulation undo_redo.txt *.vqm *.qdf \
	*.csf *.psf *.quartus *.smsg .undefinedlib .jaguarc .unorderedFilePath \
	incremental_db PLLJ_PLLSPE_INFO.txt *.jdi

vsim: 
	(echo "set QSYS_SIMDIR \"$(CURDIR)/bemicro_soc/simulation\""; echo "source bemicro_soc/simulation/mentor/msim_setup.tcl"; echo "dev_com"; echo "com"; ) | vsim || exit 1
	vlog -quiet  -work work mobile/mobile_ddr.v
	vlog -quiet  -work work bemicro_top.v
	vlog -quiet  -work work tb.v

vsim-libs:
	vlib libraries
	vlib libraries/work
	vmap work $(CURDIR)/libraries/work

vsim-run:
	vsim -do "source run.do"

####################################

PREFIX=$(CURDIR)/bin/or1k-toolchain
P=export PATH=$$PATH:$(CURDIR)/bin/bin:$(PREFIX)/bin; export PYTHONPATH=$(CURDIR)/bin/lib/python2.7/site-packages:$$PYTHONPATH


toolchain: gcc-prepare gcc-binutils gcc-gcc gcc-newlib gcc

gcc: gcc-clean gcc-binutils gcc-gcc gcc-newlib gcc

# from: https://github.com/embecosm/chiphack/wiki/OpenRISC-tools-install
gcc-prepare:
	mkdir -p tmp-gcc
	cd tmp-gcc; git clone git://github.com/openrisc/or1k-src.git
	cd tmp-gcc; git clone git://github.com/openrisc/or1k-gcc.git
	cd tmp-gcc; mkdir -p bld-or1k-src bld-or1k-gcc

gcc-ubuntu:
	sudo apt-get install libgmp-dev libmpc-dev libmpfr-dev g++ build-essential

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
	cd tmp-gcc/bld-or1k-src; $P; make 2>&1 | tee compile.newlib.txt ; make install | tee install.newlib.txt

# build gcc again, this time with newlib
gcc-all:
	mkdir -p tmp-gcc/bld-or1k-gcc
	cd tmp-gcc/bld-or1k-gcc; $P; ../or1k-gcc/configure --target=or1k-elf --prefix=$(PREFIX) --enable-languages=c,c++ \
	    --disable-shared --disable-libssp --with-newlib
	cd tmp-gcc/bld-or1k-gcc; $P;  make 2>&1 | tee compile.gcc.txt; make install 2>&1 | tee install.gcc.txt

#################
fusesoc-prepare:
	rm -rf tmp-fdir fdir orpsoc-cores fusesoc
	mkdir -p tmp-fdir;
	cd tmp-fdir; git clone https://github.com/olofk/fusesoc.git; 
	cd tmp-fdir/fusesoc; autoreconf -i; ./configure --prefix=$(CURDIR)/bin; make ; make install
	git clone https://github.com/openrisc/orpsoc-cores.git
	mkdir -p fusesoc;
	echo '[main]'                                 >  fusesoc/fusesoc.conf
	echo 'cores_root   = ../orpsoc-cores/cores'   >> fusesoc/fusesoc.conf
	echo 'systems_root = ../orpsoc-cores/systems' >> fusesoc/fusesoc.conf
	echo "use de1 design to retrive sources"
	cd fusesoc; $P; fusesoc build de1
	mkdir -p orpsoc-cores-src
	cp -r fusesoc/build/de1/src/* orpsoc-cores-src/





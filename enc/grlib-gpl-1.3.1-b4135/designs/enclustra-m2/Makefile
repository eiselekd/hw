include .config

GRLIB=../..
TOP=leon3mp
BOARD=enclustra-m2
DESIGN=enclustra-m2
#leon3-gr-xc6s
TECHNOLOGY=spartan6
include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
#UCF=$(GRLIB)/boards/$(BOARD)/$(TOP).ucf
#UCF=leon3mp.	ucf 
UCF=enc_tqs_pm3_usb3_mx2.ucf
UCF_PLANAHEAD=$(UCF)
QSF=$(GRLIB)/boards/$(BOARD)/$(TOP).qsf
EFFORT=high
ISEMAPOPT=-timing
XSTOPT=
SYNPOPT="set_option -maxfan 100; set_option -pipe 1; set_option -retiming 1; set_option -write_apr_constraint 0"
GRLIB_SIMULATOR=ModelSim-SE

VHDLSYNFILES= 

VHDLOPTSYNFILES= mig37/mig_37/user_design/rtl/iodrp_controller.vhd \
	mig37/mig_37/user_design/rtl/iodrp_mcb_controller.vhd \
	mig37/mig_37/user_design/rtl/mcb_raw_wrapper.vhd \
	mig37/mig_37/user_design/rtl/mcb_soft_calibration.vhd \
	mig37/mig_37/user_design/rtl/mcb_soft_calibration_top.vhd \
	mig37/mig_37/user_design/rtl/memc3_infrastructure.vhd \
	mig37/mig_37/user_design/rtl/memc3_wrapper.vhd \
	mig37/mig_37/user_design/rtl/mig_37.vhd \
	mig39/mig_39/user_design/rtl/iodrp_controller.vhd \
	mig39/mig_39/user_design/rtl/iodrp_mcb_controller.vhd \
	mig39/mig_39/user_design/rtl/mcb_raw_wrapper.vhd \
	mig39/mig_39/user_design/rtl/mcb_soft_calibration.vhd \
	mig39/mig_39/user_design/rtl/mcb_soft_calibration_top.vhd \
	mig39/mig_39/user_design/rtl/memc3_infrastructure.vhd \
	mig39/mig_39/user_design/rtl/memc3_wrapper.vhd \
	mig39/mig_39/user_design/rtl/mig_39.vhd \
	config.vhd svga2ch7301c.vhd ahbrom.vhd \
	ahb2mig_grxc6s_2p.vhd vga_clkgen.vhd \
	 leon3mp.vhd  tb_fx3_fifo.vhd fx3_clk_wiz_v3_6_2.vhd

# fx3_clk_wiz_v3_6_2.vhd \
	fx3_pck.vhd fx3_fifo.vhd \
	fx3.vhd fx3_apb.vhd


VHDLSIMFILES= testbench.vhd

SIMTOP=testbench
#SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
SDCFILE=default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean migclean
VCOMOPT=-explicit

TECHLIBS = secureip unisim 

VSIMOPT= -gdisas=0 -i -t ps -novopt +notimingchecks $(SIMTOP)
LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF \
	tmtc openchip ihp gsi fmf spansion micron
DIRSKIP = b1553 pci/pcif leon2 leon2ft crypto satcan pci ambatest ddr \
	leon4 leon4v0 l2cache gr1553b iommu ascs slink pwm \
	hcan greth 

#cypress
#FILEADD = MCB.vhd
FILESKIP = grcan.vhd ddr2.v mobile_ddr.v 
#unisim_VPKG.vhd unisim_VCOMP.vhd simple_simprim.vhd unisim_VITAL.vhd

include $(GRLIB)/bin/Makefile
include $(GRLIB)/software/leon3/Makefile

##################  project specific targets ##########################

mig:
	cp -r grlib_mig/mig37 .
	coregen -b mig37/mig.xco -p mig37
	patch -p0 < grlib_mig/mig.diff

mig39:
	cp -r grlib_mig/mig39 .
	coregen -b mig39/mig.xco -p mig39
	patch -p0 < grlib_mig/mig_patch.txt
	patch -p0 < grlib_mig/memc3_infrastructure_patch.txt
	patch -p0 < grlib_mig/mcb_soft_calibration_patch.txt

migclean:
	-rm -rf mig37 mig39

run:
	vsim -do "source run.do"

run_fifo:
	vsim -do "source run_fifo.do"

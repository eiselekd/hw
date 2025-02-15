TECHNOLOGY=Spartan6
ISETECH="Spartan6"
PART=XC6SLX45T
PACKAGE=csg324
SPEED=-3
SYNFREQ=60
PROMGENPAR= -c FF -s 8192 -u 0 $(TOP).bit -p mcs -spi -w -o enclustra-m2

MANUFACTURER=Xilinx
MGCPART=XC6SLX75$(PACKAGE)
MGCTECHNOLOGY=SPARTAN-6
MGCPACKAGE=$(PACKAGE)

# Set PlanAhead Synthesis Flow and Strategy used for build
PLANAHEAD_SYNTH_FLOW="XST 14"
PLANAHEAD_SYNTH_STRATEGY="TimingWithIOBPacking"

# Set PlanAhead Implementation strategy
PLANAHEAD_IMPL_STRATEGY="MapLogicOptParHighExtra"

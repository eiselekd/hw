TOP=bemicrocpu

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

quartus-map: $(TOP)_quartus.qsf
	$(QUARTUS_MAP) --import_settings_files=on  --export_settings_files=off $(TOP)_quartus -c $(TOP)_quartus
	$(QUARTUS_SH) -t pin_assign_wrap.tcl quartus_map     $(TOP)_quartus $(TOP)_quartus

quartus-route: $(TOP)_quartus.qsf
	$(QUARTUS_CDB) --merge $(TOP)_quartus
	$(QUARTUS_FIT) --import_settings_files=off --export_settings_files=off $(TOP)_quartus -c $(TOP)_quartus
	$(QUARTUS_ASM) --import_settings_files=off --export_settings_files=off $(TOP)_quartus -c $(TOP)_quartus
	$(QUARTUS_STA) $(TOP)_quartus

quartus-prog-fpga:
	$(QUARTUS_PGM) -c $(ALTCABLE) -m JTAG -o p\;4sgx230/$(TOP)_quartus.sof

quartus-prog-fpga-simple:
	$(QUARTUS_PGM) -c $(ALTCABLE) -m JTAG -o p\;$(TOP)_quartus_simple.sof

quartus-srec:
	$(QUARTUS_PGM)

quartus-clean:
	-rm -rf db *.syr *.qws automake.log dumpdata.txt \
        *.rpt *.done *.eqn *.pof *.summary *.ttf *.pin *.sof \
	*.jam *.jbc cmp_state.ini simulation undo_redo.txt *.vqm *.qdf \
	*.csf *.psf *.quartus *.smsg .undefinedlib .jaguarc .unorderedFilePath \
	incremental_db PLLJ_PLLSPE_INFO.txt *.jdi


qsys:
	rm -rf bemicrocpu
	ip-generate --file-set=QUARTUS_SYNTH \
		--report-file=csv:bemicrocpu/synthesis/bemicrocpu.csv \
		--report-file=qip:bemicrocpu/synthesis/bemicrocpu.qip \
		--report-file=spd:bemicrocpu/synthesis/bemicrocpu.spd \
		--output-directory=bemicrocpu/synthesis  --output-name=bemicrocpu_soc bemicrocpu.qsys;

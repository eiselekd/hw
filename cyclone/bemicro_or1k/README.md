Simple QSys wrapper for mor1kx OpenRisc. Use QSys to generate a OpenRisc platform.
The mor1kx core is in subdir ip/. Start QSys from this directory to get mor1kx
processor in the "Processor" tab.

1. make qsys : regenerate QSYS system
2. make quartus : regenerate QSYS system and run synthesis
3. make vsim : (needs "make qsys" first), compile simulation files
4. make vsim-run: run simulation


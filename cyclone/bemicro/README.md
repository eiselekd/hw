Simple design for the BeMicro SDK. A Jtag master connected to DDR memory.
Use the Quartus System Console and script set_memory_values.tcl
to read/write memory.
Before compiling, set the working path to this directory (so that
QSys finds the ip/ subdir) and regenerate the QSys system bemicrocpu.qsys in QSys.
Used Quartus version is 13.0. After that issue
 "make quartus"
 




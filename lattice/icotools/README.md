
[Directory icoprog](icoprog/)
-----------------------------

Low-level programming tool for IcoBoard. Runs on Raspberry Pi. Usually called
via SSH from a workstation (unless FPGA bit-streams are generated locally on
the Raspberry Pi).

[Directory examples](examples/)
-------------------------------

Small and simple example designs that run on the IcoBoard.

[Directory icosoc](icosoc/)
---------------------------

Simple System-on-Chip (SoC) generator for PicoRV32-based SoCs running on the
IcoBoard. Including standard components for GPIO, RS232, SPI, ...

[Directory makeimg](makeimg/)
-----------------------------

Scripts used to generate Raspbian images with pre-installed icotools, icestorm
flow, and RISC-V compilers.

[Directory mxoprog](mxoprog/)
-----------------------------

Programming tools and image for the MachXO2 auxiliary FPGA on the IcoBoard.
The MachXO2 on IcoBoards is pre-programmed. No need to use this tool unless
you want to change the MachXO2 bit-stream.


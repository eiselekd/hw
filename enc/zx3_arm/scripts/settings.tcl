# Arguments:
# ~~~~~~~~~~
# Leave all arguments except FPGA part on default value
# 
# hw_base_platform       -device family: Mercury, Mars
# module_name            -module name within family: KX1, AX3, ZX3, ...
# fpga_part              -FPGA part - see below the options for Mars ZX3
#    xc7z020clg484-1
#    xc7z020clg484-2
# part_specific_text     -specifc text to be added to the directory naming (if needed)
# hw_platforms           -base board platform name PE1, PM3, EB1, STA

set hw_base_platform       Mars
set module_name            ZX3
set fpga_part              xc7z020clg484-1
set part_specific_text     _
set hw_platforms           PM3

setMode -bs
setCable -port auto
identify -inferir 
attachflash -position 1 -spi "W25Q128BV"
assignfiletoattachedflash -position 1 -file "enclustra-m2.mcs"
program -p 1 -dataWidth 4 -spionly -e -v -loadfpga 
quit

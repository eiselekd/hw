# wget https://github.com/zylin/zpugcc/raw/master/releases/old/zpugcclinux.tar.bz2

all: hello

tool:
	wget https://github.com/zylin/zpugcc/raw/master/releases/old/zpugcclinux.tar.bz2
	tar xvf zpugcclinux.tar.bz2

hello: hello.c crt_io.c
	-rm hello.bram
	gcc zpuromgen.c -o zpuromgen
	install/bin/zpu-elf-gcc -Os -phi `pwd`/hello.c `pwd`/crt_io.c -o hello.elf -Wl,--relax -Wl,--gc-sections -g
	install/bin/zpu-elf-objcopy -O binary hello.elf hello.bin
	install/bin/zpu-elf-objdump --disassemble-all >hello.dis hello.elf
	./zpuromgen hello.bin > hello.bram
	cat bram.vhdl.temp hello.bram bram.vhdl.temp.post  > ../zpu/hdl/bram.vhdl

clean:
	rm -f *.elf *.bin *.dis *.bram *.o zpuromgen

// To compile: zpu-elf-gcc test.c -o test.elf -phi
// To run:

static volatile int *UART = (volatile int *)0x080a400c;

static
int _inbyte()
{
	int val;
	for (;;)
	{
		val=UART[1];
		if ((val&0x100)!=0)
		{
			return val&0xff;
		}
	}
}

void _outbyte(int c)
{
	/* Wait for space in FIFO */
	while ((UART[0]&0x100)==0);
	UART[0]=c;
}

int main(int argc, char **argv)
{
  int c;
  while(c = _inbyte()) {
    _outbyte(':');
    _outbyte(c);
    _outbyte('\n');
  }
}

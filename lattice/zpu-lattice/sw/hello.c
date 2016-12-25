// To compile: zpu-elf-gcc test.c -o test.elf -phi
// To run:
int main(int argc, char **argv)
{
  int c = 0;
  while ( (c = getc()))  {
    printf("Hello world!: %c\n", c);
  }
}

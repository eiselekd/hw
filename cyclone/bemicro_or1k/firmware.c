
f() {
  volatile int *p = 0x40000000;
  *p = 0x01020304;
  while(1) {
    (**p)++;
  }
}

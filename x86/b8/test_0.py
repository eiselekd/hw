import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), ".."))
from x86test.state import REG_EAX, REG_EBX, REG_ECX, REG_EDX
from x86test import test_init_std0

def test():
    v=test_init_std0()
    v.run_insn(b"\xb8\x02\x00\x00\x00")
    v.test_reg(REG_EAX, 0x00000002);

if __name__ == "__main__":
    test();

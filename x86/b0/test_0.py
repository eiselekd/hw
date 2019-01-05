import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), ".."))
from x86test.state import REG_EAX, REG_EBX, REG_ECX, REG_EDX
from x86test import test_init_std0

def test():
    v=test_init_std0()
    v.run_insn(b"\xb0\x02\xb1\x03\xb6\x04\xb7\x05")
    v.test_reg(REG_EAX, 0xffffff02);
    v.test_reg(REG_ECX, 0xffffff03);
    v.test_reg(REG_EDX, 0xffff04ff);
    v.test_reg(REG_EBX, 0xffff05ff);

if __name__ == "__main__":
    test();

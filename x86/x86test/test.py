from unicorn.x86_const import *
from x86test import *
from x86test.state import reg_to_str

class testExc(Exception):
    def __init__(self,m):
        super(testExc,self).__init__()
        self.m = m;
    def __str__(self):
        return self.m

class testenv(object):

    def __init__(self, *args):
        super(testenv,self).__init__(*args)

    def test_reg(self, reg, val):
        c = self.get_reg(reg)
        if (val != c):
            raise(testExc("Expect 0x%08x in reg %s: value is 0x%08x\nstate:\n%s" %(val,reg_to_str(reg),c,self.get_state())));

from x86test.uni import unienv
from x86test.node import nodeenv

class test_init_std0(object):

    def __init__(self, *args):
        super(test_init_std0,self).__init__()
        self.u = unienv()

    def run_insn(self,*args):
        self.u.run_insn(*args)

    def test_reg(self,r, v):
        self.u.test_reg(r,v)

from __future__ import print_function
from unicorn import *
from unicorn.x86_const import *
from x86test.test import testenv
from x86test.state import state, REG_EAX, REG_EBX, REG_ECX, REG_EDX, reg_to_str

# memory address where emulation starts
ADDRESS = 0x1000000

# callback for tracing instructions
def hook_code(uc, address, size, user_data):
    eflags = uc.reg_read(UC_X86_REG_EFLAGS)
    print(">>> Tracing instruction at 0x%x, instruction size = 0x%x EFLAGS is 0x%x" %(address, size,eflags))

class unienv(testenv):

    def __init__(self, *args):

        super(unienv,self).__init__(*args)

        # Initialize emulator in X86-32bit mode
        self.mu = Uc(UC_ARCH_X86, UC_MODE_32)
        # initialize machine registers
        self.mu.reg_write(UC_X86_REG_EAX, -1)
        self.mu.reg_write(UC_X86_REG_EBX, -1)
        self.mu.reg_write(UC_X86_REG_ECX, -1)
        self.mu.reg_write(UC_X86_REG_EDX, -1)

        # tracing all instructions with customized callback
        self.mu.hook_add(UC_HOOK_CODE, hook_code)

    def run_insn(self,b):
        try:

            # map 2MB memory for this emulation
            self.mu.mem_map(ADDRESS, 2 * 1024 * 1024)

            # write machine code to be emulated to memory
            self.mu.mem_write(ADDRESS, b)

            try:
                # emulate machine code in infinite time
                self.mu.emu_start(ADDRESS, ADDRESS + len(b))
            except UcError as e:
                print("ERROR: %s" % e)

        except UcError as e:
            print("ERROR: %s" % e)

    def get_reg(self,r):
        if (r == REG_EAX):
            return self.mu.reg_read(UC_X86_REG_EAX)
        elif (r == REG_EBX):
            return self.mu.reg_read(UC_X86_REG_EBX)
        elif (r == REG_ECX):
            return self.mu.reg_read(UC_X86_REG_ECX)
        elif (r == REG_EDX):
            return self.mu.reg_read(UC_X86_REG_EDX)
        else:
            raise(testExc("Undefined register {}".format(r)));
        c = state();
        c.set_reg(REG_EAX, self.mu.reg_read(UC_X86_REG_EAX))
        return c

    def get_state(self):
        c = state()
        c.eax = self.mu.reg_read(UC_X86_REG_EAX)
        c.ebx = self.mu.reg_read(UC_X86_REG_EBX)
        c.ecx = self.mu.reg_read(UC_X86_REG_ECX)
        c.edx = self.mu.reg_read(UC_X86_REG_EDX)
        return c

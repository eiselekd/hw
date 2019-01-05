
#define R_EAX 0
#define R_ECX 1
#define R_EDX 2
#define R_EBX 3
#define R_ESP 4
#define R_EBP 5
#define R_ESI 6
#define R_EDI 7

REG_EAX=0
REG_ECX=1
REG_EDX=2
REG_EBX=3
REG_ESP=4
REG_EBP=5
REG_ESI=6
REG_EDI=7

def reg_to_str(r):
    if (r == REG_EAX):
        return "REG_EAX"
    elif (r == REG_EBX):
        return "REG_EBX"
    elif (r == REG_ECX):
        return "REG_ECX"
    elif (r == REG_EDX):
        return "REG_EDX"
    return "undef"

class state(object):
    def __init__(self, *args):
        super(state,self).__init__()
        self.eax = 0
        self.ebx = 0
        self.ecx = 0
        self.edx = 0

    def __str__(self):
        return ("""eax: %08x
ecx: %08x
edx: %08x
ebx: %08x
""" %(self.eax, self.ecx, self.edx, self.ebx))

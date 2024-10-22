# The MIT License (MIT)
#
# Copyright (c) 2017 Dan Halbert
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

"""
`adafruit_max7219.bcddigits.BCDDigits`
====================================================
"""
from micropython import const
from adafruit_max7219 import max7219

__version__ = "1.1.0"
__repo__ = "https://github.com/adafruit/Adafruit_CircuitPython_MAX7219.git"

_DECODEMODE = const(9)
_SCANLIMIT = const(11)
_SHUTDOWN = const(12)
_DISPLAYTEST = const(15)

class BCDDigits(max7219.MAX7219):
    """
    Basic support for display on a 7-Segment BCD display controlled
    by a Max7219 chip using SPI.

    :param object spi: an spi busio or spi bitbangio object
    :param ~digitalio.DigitalInOut cs: digital in/out to use as chip select signal
    :param int nDigits: number of led 7-segment digits; default 1; max 8
    """
    def __init__(self, spi, cs, nDigits=1):
        self._ndigits = nDigits
        super().__init__(self._ndigits, 8, spi, cs)

    def init_display(self):

        for cmd, data in ((_SHUTDOWN, 0),
                          (_DISPLAYTEST, 0),
                          (_SCANLIMIT, 7),
                          (_DECODEMODE, (2**self._ndigits)-1),
                          (_SHUTDOWN, 1),
                         ):
            self.write_cmd(cmd, data)

        self.clear_all()
        self.show()

    def set_digit(self, dpos, value):
        """
        Display one digit.

        :param int dpos: the digit position; zero-based
        :param int value: integer ranging from 0->15
        """
        dpos = self._ndigits - dpos - 1
        for i in range(4):
            #print('digit {} pixel {} value {}'.format(dpos,i+4,v & 0x01))
            self.pixel(dpos, i, value & 0x01)
            value >>= 1

    def set_digits(self, start, values):
        """
        Display digits from a list.

        :param int s: digit to start display zero-based
        :param list ds: list of integer values ranging from 0->15
        """
        for value in values:
            #print('set digit {} start {}'.format(d,start))
            self.set_digit(start, value)
            start += 1

    def show_dot(self, dpos, bit_value=None):
        """
        The decimal point for a digit.

        :param int dpos: the digit to set the decimal point zero-based
        :param int value: value > zero lights the decimal point, else unlights the point
        """
        if dpos < self._ndigits and dpos >= 0:
            #print('set dot {} = {}'.format((self._ndigits - d -1),col))
            self.pixel(self._ndigits-dpos-1, 7, bit_value)

    def clear_all(self):
        """
        Clear all digits and decimal points.
        """
        self.fill(1)
        for i in range(self._ndigits):
            self.show_dot(i)

    def show_str(self, start, strg):
        """
        Displays a numeric str in the display.  Shows digits ``0-9``, ``-``, and ``.``.

        :param int start: start position to show the numeric string
        :param string str: the numeric string
        """
        cpos = start
        for char in strg:
            # print('c {}'.format(c))
            value = 0x0f # assume blank
            if char >= '0' and char <= '9':
                value = int(char)
            elif char == '-':
                value = 10 # minus sign
            elif char == '.':
                self.show_dot(cpos-1, 1)
                continue
            self.set_digit(cpos, value)
            cpos += 1

    def show_help(self, start):
        """
        Display the word HELP in the display.

        :param int start: start position to show HELP
        """
        digits = [12, 11, 13, 14]
        self.set_digits(start, digits)

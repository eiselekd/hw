# The MIT License (MIT)
#
# Copyright (c) 2017 Tony DiCola for Adafruit Industries
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
"""
`adafruit_mcp4725` - MCP4725 digital to analog converter
========================================================

CircuitPython module for the MCP4725 digital to analog converter.  See
examples/mcp4725_simpletest.py for a demo of the usage.

* Author(s): Tony DiCola

Implementation Notes
--------------------

**Hardware:**

* Adafruit `MCP4725 Breakout Board - 12-Bit DAC w/I2C Interface
  <https://www.adafruit.com/product/935>`_ (Product ID: 935)

**Software and Dependencies:**

* Adafruit CircuitPython firmware for the ESP8622 and M0-based boards:
  https://github.com/adafruit/circuitpython/releases
"""
from micropython import const

__version__ = "1.1.1"
__repo__ = "https://github.com/adafruit/Adafruit_CircuitPython_MCP4725.git"


# Internal constants:
_MCP4725_DEFAULT_ADDRESS = 0b01100010
_MCP4725_WRITE_FAST_MODE = const(0b00000000)


class MCP4725:
    """
    MCP4725 12-bit digital to analog converter.  This class has a similar
    interface as the CircuitPython AnalogOut class and can be used in place
    of that module.

    :param ~busio.I2C i2c: The I2C bus.
    :param int address: The address of the device if set differently from the default.
    """


    # Global buffer to prevent allocations and heap fragmentation.
    # Note this is not thread-safe or re-entrant by design!
    _BUFFER = bytearray(3)

    def __init__(self, i2c, *, address=_MCP4725_DEFAULT_ADDRESS):
        # This device doesn't use registers and instead just accepts a single
        # command string over I2C.  As a result we don't use bus device or
        # other abstractions and just talk raw I2C protocol.
        self._i2c = i2c
        self._address = address

    def _write_fast_mode(self, val):
        # Perform a 'fast mode' write to update the DAC value.
        # Will not enter power down, update EEPROM, or any other state beyond
        # the 12-bit DAC value.
        assert 0 <= val <= 4095
        try:
            # Make sure bus is locked before write.
            while not self._i2c.try_lock():
                pass
            # Build bytes to send to device with updated value.
            val &= 0xFFF
            self._BUFFER[0] = _MCP4725_WRITE_FAST_MODE | (val >> 8)
            self._BUFFER[1] = val & 0xFF
            self._i2c.writeto(self._address, self._BUFFER, end=2)
        finally:
            # Ensure bus is always unlocked.
            self._i2c.unlock()

    def _read(self):
        # Perform a read of the DAC value.  Returns the 12-bit value.
        try:
            # Make sure bus is locked before write.
            while not self._i2c.try_lock():
                pass
            # Read 3 bytes from device.
            self._i2c.readfrom_into(self._address, self._BUFFER)
            # Grab the DAC value from last two bytes.
            dac_high = self._BUFFER[1]
            dac_low = self._BUFFER[2] >> 4
            # Reconstruct 12-bit value and return it.
            return ((dac_high << 4) | dac_low) & 0xFFF
        finally:
            # Ensure bus is always unlocked.
            self._i2c.unlock()

    @property
    def value(self):
        """
        The DAC value as a 16-bit unsigned value compatible with the
        :py:class:`~analogio.AnalogOut` class.

        Note that the MCP4725 is still just a 12-bit device so quantization will occur.  If you'd
        like to instead deal with the raw 12-bit value use the ``raw_value`` property, or the
        ``normalized_value`` property to deal with a 0...1 float value.
        """
        raw_value = self._read()
        # Scale up to 16-bit range.
        return raw_value << 4

    @value.setter
    def value(self, val):
        assert 0 <= val <= 65535
        # Scale from 16-bit to 12-bit value (quantization errors will occur!).
        raw_value = val >> 4
        self._write_fast_mode(raw_value)

    @property
    def raw_value(self):
        """The DAC value as a 12-bit unsigned value.  This is the the true resolution of the DAC
        and will never peform scaling or run into quantization error.
        """
        return self._read()

    @raw_value.setter
    def raw_value(self, val):
        self._write_fast_mode(val)

    @property
    def normalized_value(self):
        """The DAC value as a floating point number in the range 0.0 to 1.0.
        """
        return self._read()/4095.0

    @normalized_value.setter
    def normalized_value(self, val):
        assert 0.0 <= val <= 1.0
        raw_value = int(val * 4095.0)
        self._write_fast_mode(raw_value)

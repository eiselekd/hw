# The MIT License (MIT)
#
# Copyright (c) 2017 Tony DiCola
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
`adafruit_is31fl3731`
====================================================

CircuitPython driver for the IS31FL3731 charlieplex IC.


* Author(s): Tony DiCola

Implementation Notes
--------------------

**Hardware:**

* `Adafruit 16x9 Charlieplexed PWM LED Matrix Driver - IS31FL3731
  <https://www.adafruit.com/product/2946>`_

* `Adafruit 15x7 CharliePlex LED Matrix Display FeatherWings
  <https://www.adafruit.com/product/2965>`_

**Software and Dependencies:**

* Adafruit CircuitPython firmware (2.2.0+) for the ESP8622 and M0-based boards:
  https://github.com/adafruit/circuitpython/releases
"""

# imports
import math
import time
from micropython import const

__version__ = "2.2.1"
__repo__ = "https://github.com/adafruit/Adafruit_CircuitPython_IS31FL3731.git"

_MODE_REGISTER = const(0x00)
_FRAME_REGISTER = const(0x01)
_AUTOPLAY1_REGISTER = const(0x02)
_AUTOPLAY2_REGISTER = const(0x03)
_BLINK_REGISTER = const(0x05)
_AUDIOSYNC_REGISTER = const(0x06)
_BREATH1_REGISTER = const(0x08)
_BREATH2_REGISTER = const(0x09)
_SHUTDOWN_REGISTER = const(0x0a)
_GAIN_REGISTER = const(0x0b)
_ADC_REGISTER = const(0x0c)

_CONFIG_BANK = const(0x0b)
_BANK_ADDRESS = const(0xfd)

_PICTURE_MODE = const(0x00)
_AUTOPLAY_MODE = const(0x08)
_AUDIOPLAY_MODE = const(0x18)

_ENABLE_OFFSET = const(0x00)
_BLINK_OFFSET = const(0x12)
_COLOR_OFFSET = const(0x24)

class Matrix:
    """
    The Matrix class support the main function for driving the 16x9 matrix Display

    :param ~adafruit_bus_device.i2c_device i2c_device: the connected i2c bus i2c_device
    :param address: the device address; defaults to 0x74
    """
    width = 16
    height = 9

    def __init__(self, i2c, address=0x74):
        self.i2c = i2c
        self.address = address
        self._frame = None
        self.reset()
        self._init()

    def _i2c_read_reg(self, reg, result):
        # Read a buffer of data from the specified 8-bit I2C register address.
        # The provided result parameter will be filled to capacity with bytes
        # of data read from the register.
        while not self.i2c.try_lock():
            pass
        try:
            self.i2c.writeto(self.address, bytes([reg]), stop=False)
            self.i2c.readfrom_into(self.address, result)
            return result
        finally:
            self.i2c.unlock()
        return None

    def _i2c_write_reg(self, reg, data):
        # Write a buffer of data (byte array) to the specified I2C register
        # address.
        while not self.i2c.try_lock():
            pass
        try:
            buf = bytearray(1)
            buf[0] = reg
            buf.extend(data)
            self.i2c.writeto(self.address, buf)
        finally:
            self.i2c.unlock()

    def _bank(self, bank=None):
        if bank is None:
            result = bytearray(1)
            return self._i2c_read_reg(_BANK_ADDRESS, result)[0]
        self._i2c_write_reg(_BANK_ADDRESS, bytearray([bank]))
        return None


    def _register(self, bank, register, value=None):
        self._bank(bank)
        if value is None:
            result = bytearray(1)
            return self._i2c_read_reg(register, result)[0]
        self._i2c_write_reg(register, bytearray([value]))
        return None

    def _mode(self, mode=None):
        return self._register(_CONFIG_BANK, _MODE_REGISTER, mode)

    def _init(self):
        self._mode(_PICTURE_MODE)
        self.frame(0)
        for frame in range(8):
            self.fill(0, False, frame=frame)
            for col in range(18):
                self._register(frame, _ENABLE_OFFSET + col, 0xff)
        self.audio_sync(False)

    def reset(self):
        """Kill the display for 10MS"""
        self.sleep(True)
        time.sleep(0.01)  # 10 MS pause to reset.
        self.sleep(False)

    def sleep(self, value):
        """
        Set the Software Shutdown Register bit

        :param value: True to set software shutdown bit; False unset
        """
        return self._register(_CONFIG_BANK, _SHUTDOWN_REGISTER, not value)

    def autoplay(self, delay=0, loops=0, frames=0):
        """
        Start autoplay

        :param delay: in ms
        :param loops: number of loops - 0->7
        :param frames: number of frames: 0->7
        """
        if delay == 0:
            self._mode(_PICTURE_MODE)
            return
        delay //= 11
        if not 0 <= loops <= 7:
            raise ValueError("Loops out of range")
        if not 0 <= frames <= 7:
            raise ValueError("Frames out of range")
        if not 1 <= delay <= 64:
            raise ValueError("Delay out of range")
        self._register(_CONFIG_BANK, _AUTOPLAY1_REGISTER, loops << 4 | frames)
        self._register(_CONFIG_BANK, _AUTOPLAY2_REGISTER, delay % 64)
        self._mode(_AUTOPLAY_MODE | self._frame)


    def fade(self, fade_in=None, fade_out=None, pause=0):
        """
        Start and stop the fade feature.  If both fade_in and fade_out are None (the
        default), the breath feature is used for fading.  if fade_in is None, then
        fade_in = fade_out.  If fade_out is None, then fade_out = fade_in

        :param fade_in: positive number; 0->100
        :param fade-out: positive number; 0->100
        :param pause: breath register 2 pause value
        """
        if fade_in is None and fade_out is None:
            self._register(_CONFIG_BANK, _BREATH2_REGISTER, 0)
        elif fade_in is None:
            fade_in = fade_out
        elif fade_out is None:
            fade_out = fade_in
        fade_in = int(math.log(fade_in / 26, 2))
        fade_out = int(math.log(fade_out / 26, 2))
        pause = int(math.log(pause / 26, 2))
        if not 0 <= fade_in <= 7:
            raise ValueError("Fade in out of range")
        if not 0 <= fade_out <= 7:
            raise ValueError("Fade out out of range")
        if not 0 <= pause <= 7:
            raise ValueError("Pause out of range")
        self._register(_CONFIG_BANK, _BREATH1_REGISTER, fade_out << 4 | fade_in)
        self._register(_CONFIG_BANK, _BREATH2_REGISTER, 1 << 4 | pause)

    def frame(self, frame=None, show=True):
        """
        Set the current frame

        :param frame: frame number; 0-7 or None. If None function returns current frame
        :param show: True to show the frame; False to not show.
        """
        if frame is None:
            return self._frame
        if not 0 <= frame <= 8:
            raise ValueError("Frame out of range")
        self._frame = frame
        if show:
            self._register(_CONFIG_BANK, _FRAME_REGISTER, frame)
        return None

    def audio_sync(self, value=None):
        """Set the audio sync feature register
        """
        return self._register(_CONFIG_BANK, _AUDIOSYNC_REGISTER, value)

    def audio_play(self, sample_rate, audio_gain=0,
                   agc_enable=False, agc_fast=False):
        """Controls the audio play feature
        """
        if sample_rate == 0:
            self._mode(_PICTURE_MODE)
            return
        sample_rate //= 46
        if not 1 <= sample_rate <= 256:
            raise ValueError("Sample rate out of range")
        self._register(_CONFIG_BANK, _ADC_REGISTER, sample_rate % 256)
        audio_gain //= 3
        if not 0 <= audio_gain <= 7:
            raise ValueError("Audio gain out of range")
        self._register(_CONFIG_BANK, _GAIN_REGISTER,
                       bool(agc_enable) << 3 | bool(agc_fast) << 4 | audio_gain)
        self._mode(_AUDIOPLAY_MODE)

    def blink(self, rate=None):
        """Updates the blink register
        """
        # pylint: disable=no-else-return
        # This needs to be refactored when it can be tested
        if rate is None:
            return (self._register(_CONFIG_BANK, _BLINK_REGISTER) & 0x07) * 270
        elif rate == 0:
            self._register(_CONFIG_BANK, _BLINK_REGISTER, 0x00)
            return None
        rate //= 270
        self._register(_CONFIG_BANK, _BLINK_REGISTER, rate & 0x07 | 0x08)
        return None

    def fill(self, color=None, blink=None, frame=None):
        """
        Fill the display with a brightness level

        :param color: brightness 0->255
        :param blink: True if blinking is required
        :param frame: which frame to fill 0->7
        """
        if frame is None:
            frame = self._frame
        self._bank(frame)
        if color is not None:
            if not 0 <= color <= 255:
                raise ValueError("Color out of range")
            data = bytearray([color] * 25) # Extra byte at front for address.
            while not self.i2c.try_lock():
                pass
            try:
                for row in range(6):
                    data[0] = _COLOR_OFFSET + row * 24
                    self.i2c.writeto(self.address, data)
            finally:
                self.i2c.unlock()
        if blink is not None:
            data = bool(blink) * 0xff
            for col in range(18):
                self._register(frame, _BLINK_OFFSET + col, data)

    @staticmethod
    def pixel_addr(x, y):
        """Calulate the offset into the device array for x,y pixel
        """
        return x + y * 16

    #pylint: disable-msg=too-many-arguments
    def pixel(self, x, y, color=None, blink=None, frame=None):
        """
        Blink or brightness for x-, y-pixel

        :param x: horizontal pixel position
        :param y: vertical pixel position
        :param color: brightness value 0->255
        :param blink: True to blink
        :param frame: the frame to set the pixel
        """
        if not 0 <= x <= self.width:
            return None
        if not 0 <= y <= self.height:
            return None
        pixel = self.pixel_addr(x, y)
        if color is None and blink is None:
            return self._register(self._frame, pixel)
        if frame is None:
            frame = self._frame
        if color is not None:
            if not 0 <= color <= 255:
                raise ValueError("Color out of range")
            self._register(frame, _COLOR_OFFSET + pixel, color)
        if blink is not None:
            addr, bit = divmod(pixel, 8)
            bits = self._register(frame, _BLINK_OFFSET + addr)
            if blink:
                bits |= 1 << bit
            else:
                bits &= ~(1 << bit)
            self._register(frame, _BLINK_OFFSET + addr, bits)
        return None
    #pylint: enable-msg=too-many-arguments


class CharlieWing(Matrix):
    """Supports the Charlieplexed feather wing
    """
    width = 15
    height = 7

    @staticmethod
    def pixel_addr(x, y):
        """Calulate the offset into the device array for x,y pixel
        """
        if x > 7:
            x = 15 - x
            y += 8
        else:
            y = 7 - y
        return x * 16 + y

import board
import busio
import digitalio
import time
from os import uname
from mfrc522 import MFRC522

def uart_setup_featherm0():
    uart = busio.UART(board.TX, board.RX, baudrate=9600)
    return uart

def led_setup_featherm0():
    pin_name = board.D13
    led = digitalio.DigitalInOut(pin_name)
    led.direction = digitalio.Direction.OUTPUT
    return led

bn = uname()[0]
print("Boardname: %s" %(bn))

rfid = MFRC522()

uart = uart_setup_featherm0()
led = led_setup_featherm0()

i=0
while True:
    led.value = True
    time.sleep(0.5)
    led.value = False
    time.sleep(0.5)
    led.value = True
    time.sleep(0.1)
    led.value = False
    time.sleep(0.1)
    print("Test %s" %(i))
    i+=1

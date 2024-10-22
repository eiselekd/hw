
 PARAMETER VERSION = 2.2.0


BEGIN OS
 PARAMETER OS_NAME = xilkernel
 PARAMETER OS_VER = 5.01.a
 PARAMETER PROC_INSTANCE = microblaze_1
 PARAMETER STDIN = rs232_0
 PARAMETER STDOUT = rs232_0
 PARAMETER SYSTMR_SPEC = true
 PARAMETER SYSTMR_DEV = axi_timer_0
 PARAMETER SYSINTC_SPEC = microblaze_0_intc
END


BEGIN PROCESSOR
 PARAMETER DRIVER_NAME = cpu
 PARAMETER DRIVER_VER = 1.15.a
 PARAMETER HW_INSTANCE = microblaze_1
END


BEGIN DRIVER
 PARAMETER DRIVER_NAME = tmrctr
 PARAMETER DRIVER_VER = 2.05.a
 PARAMETER HW_INSTANCE = axi_timer_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = tmrctr
 PARAMETER DRIVER_VER = 2.05.a
 PARAMETER HW_INSTANCE = axi_timer_1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = uartlite
 PARAMETER DRIVER_VER = 2.01.a
 PARAMETER HW_INSTANCE = debug_module
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = gpio
 PARAMETER DRIVER_VER = 3.01.a
 PARAMETER HW_INSTANCE = leds
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = mbox
 PARAMETER DRIVER_VER = 3.04.a
 PARAMETER HW_INSTANCE = mailbox_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = s6_ddrx
 PARAMETER DRIVER_VER = 1.00.a
 PARAMETER HW_INSTANCE = mcb_ddr2
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = intc
 PARAMETER DRIVER_VER = 2.06.a
 PARAMETER HW_INSTANCE = microblaze_0_intc
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = bram
 PARAMETER DRIVER_VER = 3.03.a
 PARAMETER HW_INSTANCE = microblaze_1_d_bram_ctrl
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = bram
 PARAMETER DRIVER_VER = 3.03.a
 PARAMETER HW_INSTANCE = microblaze_1_i_bram_ctrl
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = intc
 PARAMETER DRIVER_VER = 2.06.a
 PARAMETER HW_INSTANCE = microblaze_1_intc
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = mutex
 PARAMETER DRIVER_VER = 3.02.a
 PARAMETER HW_INSTANCE = mutex_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = uartlite
 PARAMETER DRIVER_VER = 2.01.a
 PARAMETER HW_INSTANCE = rs232_0
END



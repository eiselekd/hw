#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <termios.h>
#include <assert.h>
#include <sys/time.h>
#include <wiringPi.h>
#include "libxsvf.h"

#define RPI_ICE_CLK      7 // PIN  7, GPIO.7
#define RPI_ICE_CDONE    2 // PIN 13, GPIO.2
#define RPI_ICE_MOSI    21 // PIN 29, GPIO.21
#define RPI_ICE_MISO    22 // PIN 31, GPIO.22
#define LOAD_FROM_FLASH 23 // PIN 33, GPIO.23
#define RPI_ICE_CRESET  25 // PIN 37, GPIO.25
#define RPI_ICE_CS      10 // PIN 24, CE0
#define RPI_ICE_SELECT  26 // PIN 32, GPIO.26

#define RASPI_D8   0 // PIN 11, GPIO.0
#define RASPI_D7   1 // PIN 12, GPIO.1
#define RASPI_D6   3 // PIN 15, GPIO.3
#define RASPI_D5   4 // PIN 16, GPIO.4
#define RASPI_D4  12 // PIN 19, MOSI
#define RASPI_D3  13 // PIN 21, MISO
#define RASPI_D2  11 // PIN 26, CE1
#define RASPI_D1  24 // PIN 35, GPIO.24
#define RASPI_D0  27 // PIN 36, GPIO.27
#define RASPI_DIR 28 // PIN 38, GPIO.28
#define RASPI_CLK 29 // PIN 40, GPIO.29

#define MACHXO2_TDO RPI_ICE_MISO
#define MACHXO2_TDI RPI_ICE_MOSI
#define MACHXO2_TCK RPI_ICE_CS
#define MACHXO2_TMS RPI_ICE_CLK

static void io_tms(int val)
{
	digitalWrite(MACHXO2_TMS, val ? HIGH : LOW);
}

static void io_tdi(int val)
{
	digitalWrite(MACHXO2_TDI, val ? HIGH : LOW);
}

static void io_tck(int val)
{
	digitalWrite(MACHXO2_TCK, val ? HIGH : LOW);
}

static void io_sck(int val)
{
	/* not available */
}

static void io_trst(int val)
{
	/* not available */
}

static int io_tdo()
{
	return digitalRead(MACHXO2_TDO) == HIGH ? 1 : 0;
}

static int h_setup(struct libxsvf_host *h)
{
	return 0;
}

static int h_shutdown(struct libxsvf_host *h)
{
	return 0;
}

static void h_udelay(struct libxsvf_host *h, long usecs, int tms, long num_tck)
{
	// printf("[DELAY:%ld, TMS:%d, NUM_TCK:%ld]\n", usecs, tms, num_tck);

	if (num_tck > 0)
	{
		struct timeval tv1, tv2;
		gettimeofday(&tv1, NULL);

		io_tms(tms);
		while (num_tck > 0) {
			io_tck(0);
			io_tck(1);
			num_tck--;
		}

		gettimeofday(&tv2, NULL);
		if (tv2.tv_sec > tv1.tv_sec) {
			usecs -= (1000000 - tv1.tv_usec) + (tv2.tv_sec - tv1.tv_sec - 1) * 1000000;
			tv1.tv_usec = 0;
		}
		usecs -= tv2.tv_usec - tv1.tv_usec;

		// printf("[DELAY_AFTER_TCK:%ld]\n", usecs > 0 ? usecs : 0);
	}

	if (usecs > 0) {
		usleep(usecs);
	}
}

static int h_getbyte(struct libxsvf_host *h)
{
	return fgetc(stdin);
}

static int h_pulse_tck(struct libxsvf_host *h, int tms, int tdi, int tdo, int rmask, int sync)
{
	io_tms(tms);

	if (tdi >= 0)
		io_tdi(tdi);

	io_tck(0);
	io_tck(1);

	int line_tdo = io_tdo();
	int rc = line_tdo >= 0 ? line_tdo : 0;

	if (tdo >= 0 && line_tdo >= 0) {
		if (tdo != line_tdo)
			rc = -1;
	}

	// printf("[TMS:%d, TDI:%d, TDO_ARG:%d, TDO_LINE:%d, RMASK:%d, RC:%d]\n", tms, tdi, tdo, line_tdo, rmask, rc);
	return rc;
}

static void h_pulse_sck(struct libxsvf_host *h)
{
	// printf("[SCK]\n");

	io_sck(0);
	io_sck(1);
}

static void h_set_trst(struct libxsvf_host *h, int v)
{
	// printf("[TRST:%d]\n", v);
	io_trst(v);
}

static int h_set_frequency(struct libxsvf_host *h, int v)
{
	printf("WARNING: Setting JTAG clock frequency to %d ignored!\n", v);
	return 0;
}

static void h_report_tapstate(struct libxsvf_host *h)
{
	// printf("[%s]\n", libxsvf_state2str(h->tap_state));
}

static void h_report_device(struct libxsvf_host *h, unsigned long idcode)
{
	printf("idcode=0x%08lx, revision=0x%01lx, part=0x%04lx, manufactor=0x%03lx\n", idcode,
			(idcode >> 28) & 0xf, (idcode >> 12) & 0xffff, (idcode >> 1) & 0x7ff);
}

static void h_report_status(struct libxsvf_host *h, const char *message)
{
	// printf("[STATUS] %s\n", message);
}

static void h_report_error(struct libxsvf_host *h, const char *file, int line, const char *message)
{
	printf("[%s:%d] %s\n", file, line, message);
}

static void *h_realloc(struct libxsvf_host *h, void *ptr, int size, enum libxsvf_mem which)
{
	return realloc(ptr, size);
}

static struct libxsvf_host h = {
	.udelay = h_udelay,
	.setup = h_setup,
	.shutdown = h_shutdown,
	.getbyte = h_getbyte,
	.pulse_tck = h_pulse_tck,
	.pulse_sck = h_pulse_sck,
	.set_trst = h_set_trst,
	.set_frequency = h_set_frequency,
	.report_tapstate = h_report_tapstate,
	.report_device = h_report_device,
	.report_status = h_report_status,
	.report_error = h_report_error,
	.realloc = h_realloc,
	.user_data = NULL
};

void reset_inout()
{
	pinMode(RPI_ICE_CLK,     INPUT);
	pinMode(RPI_ICE_CDONE,   INPUT);
	pinMode(RPI_ICE_MOSI,    INPUT);
	pinMode(RPI_ICE_MISO,    INPUT);
	pinMode(LOAD_FROM_FLASH, INPUT);
	pinMode(RPI_ICE_CRESET,  INPUT);
	pinMode(RPI_ICE_CS,      INPUT);
	pinMode(RPI_ICE_SELECT,  INPUT);

	pinMode(RASPI_D8, INPUT);
	pinMode(RASPI_D7, INPUT);
	pinMode(RASPI_D6, INPUT);
	pinMode(RASPI_D5, INPUT);
	pinMode(RASPI_D4, INPUT);
	pinMode(RASPI_D3, INPUT);
	pinMode(RASPI_D2, INPUT);
	pinMode(RASPI_D1, INPUT);
	pinMode(RASPI_D0, INPUT);

	pinMode(RASPI_DIR, OUTPUT);
	pinMode(RASPI_CLK, OUTPUT);

	digitalWrite(RASPI_DIR, LOW);
	digitalWrite(RASPI_CLK, LOW);
}

int main(int argc, char **argv)
{
	wiringPiSetup();
	reset_inout();

	pinMode(MACHXO2_TDI, OUTPUT);
	pinMode(MACHXO2_TCK, OUTPUT);
	pinMode(MACHXO2_TMS, OUTPUT);

	printf("Scanning...\n");
	if (libxsvf_play(&h, LIBXSVF_MODE_SCAN) < 0) {
		fprintf(stderr, "Error while scanning JTAG chain.\n");
		reset_inout();
		return 1;
	}

	printf("Programming (reading SVF from stdin)...\n");
	if (libxsvf_play(&h, LIBXSVF_MODE_SVF) < 0) {
		fprintf(stderr, "Error while playing SVF file.\n");
		reset_inout();
		return 1;
	}

	printf("DONE.\n");
	reset_inout();
	return 0;
}


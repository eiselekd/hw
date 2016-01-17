#include "musl/features.h"
#include <sys/types.h>
#include <sys/time.h>
#include "xparameters.h"
#include "xil_types.h"

int fsync(int fd) {
	return 0;
}

pid_t waitpid(pid_t pid, int *status, int options)
{
	return 0;
}

int dup(int a) {
	return 0;
}

int dup2(int a) {
	return 0;
}

ssize_t preadv (int a, const struct iovec *vec, int i, off_t o)
{
	return 0;
}
ssize_t pwritev (int a, const struct iovec *vec, int i, off_t o)
{
	return 0;
}

ssize_t pread(int fd, void *buf, size_t count, off_t offset)
{
	return 0;
}

ssize_t pwrite(int fd, const void *buf, size_t count, off_t offset)
{
	return 0;
}

unsigned int alarm(unsigned int seconds)
{
	return 0;
}

char *getcwd(char *buf, size_t size)
{
	return 0;
}

int chdir(const char *path)
{
	return 0;
}

int ftruncate(int fd, off_t length)
{
	return 0;
}

char *crypt(char *key, char *salt)
{
	return 0;
}

int select(int nfds, fd_set *readfds, fd_set *writefds,
                 fd_set *exceptfds, struct timeval *timeout)
{
	return 0;
}

int gettimeofday (struct timeval *__restrict __p, void *__restrict __tz)
{
	return 0;
}

clock_t times(struct tms *a)
{
	return 0;
}

extern void outbyte(char c);


s32
read (s32 fd, char8* buf, s32 nbytes)
{
  s32 i;
  char8* LocalBuf = buf;

  (void)fd;
  for (i = 0; i < nbytes; i++) {
	if(LocalBuf != NULL) {
		LocalBuf += i;
	}
	if(LocalBuf != NULL) {
	    *LocalBuf = inbyte();
	    outbyte(*LocalBuf);
	    if (*LocalBuf == '\r') {
	    	outbyte('\n');
	    	*LocalBuf = '\n';
	    }
	    if ((*LocalBuf == '\n' )|| (*LocalBuf == '\r')) {
	        break;
		}
	}
	if(LocalBuf != NULL) {
	LocalBuf -= i;
	}
  }

  return (i + 1);
}

static char RCS_Id[]
    = "$Id: gettimeofday.c,v 1.1 2006-10-16 17:23:21-07 kst Exp $";
static char RCS_Source[]
    = "$Source: /home/kst/gx-map-redacted/gettimeofday.c,v $";

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <time.h>
#include <sys/time.h>

int main(void)
{
    struct timeval tv = { 0, 0 };

    if (gettimeofday(&tv, NULL) == 0) {
	printf("%ld.%06ld\n", (long)tv.tv_sec, (long)tv.tv_usec);
	exit(EXIT_SUCCESS);
    }
    else {
	perror("gettimeofday");
	exit(EXIT_FAILURE);
    }
} /* main */

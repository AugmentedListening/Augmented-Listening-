#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <inttypes.h>
#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"
#include "hps_0.h"

#define BUF_SIZE 8000000			// about 10 seconds of buffer (@ 48K samples/sec)
#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

int main() {

	void *virtual_base;
	int fd;
	int index;
	int choice = 5;
	void *h2p_lw_led_addr;
	void *h2p_lw_audio_addr;
	unsigned long* left_buffer = (unsigned long*)malloc(BUF_SIZE * sizeof(unsigned long));
	unsigned long* right_buffer = (unsigned long*)malloc(BUF_SIZE * sizeof(unsigned long));

	// map the address space for the LED registers into user space so we can interact with them.
	// we'll actually map in the entire CSR span of the HPS since we want to access various registers within that span

	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	}

	virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );

	if( virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return( 1 );
	}

	h2p_lw_led_addr=virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + PIO_LED_BASE ) & ( unsigned long)( HW_REGS_MASK ) );
	h2p_lw_audio_addr=virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + AUDIO_INTERFACE_BASE ) & ( unsigned long)( HW_REGS_MASK ) );

	*(uint32_t*) h2p_lw_led_addr = 0;

	while(1)
	{
			printf("Enter 0 to record data\nEnter 1 to turn play data\nEnter -1 to exit and save mic data\n");
			printf("INPUT: ");
			scanf("%d", &choice);
			if (choice == 0)
			{
				*(uint32_t*) h2p_lw_led_addr = 0x1;
				index = 0;
				while(index < BUF_SIZE)
				{
						left_buffer[index] = (*(unsigned long*) h2p_lw_audio_addr) | 0x00000000;
						right_buffer[index] = (*((unsigned long*) h2p_lw_audio_addr + 1)) | 0x00000000;
						++index;
				}
				*(uint32_t*) h2p_lw_led_addr = 0x0;
			}
			else if (choice == 1)
			{
					*(uint32_t*) h2p_lw_led_addr = 0x2;
					*((unsigned long*) h2p_lw_audio_addr + 2) = 1;
					index = 0;
					while (index < BUF_SIZE)
					{
						*(unsigned long*) h2p_lw_audio_addr = left_buffer[index];
						*((unsigned long*) h2p_lw_audio_addr + 1) = right_buffer[index];
						++index;
					}
					*((unsigned long*) h2p_lw_audio_addr + 2) = 0;
					*(uint32_t*) h2p_lw_led_addr = 0x0;
			}
			else if(choice == -1)
			{
					break;
			}
	}

	FILE * f;
	int i;

	f = fopen("OUT.dat", "w");
	if (f == NULL)
	{
			printf("ERROR: OUT.dat not found.\n");
	}

	for(i = 0; i < BUF_SIZE; ++i)
	{
			fprintf(f, "%lX				%lX\n", left_buffer[i], right_buffer[i]);
	}

	fclose(f);

	printf("Wrote to OUT.dat file successfully\n");

	free(left_buffer);
	free(right_buffer);

	// clean up our memory mapping and exit

	if( munmap( virtual_base, HW_REGS_SPAN ) != 0 ) {
		printf( "ERROR: munmap() failed...\n" );
		close( fd );
		return( 1 );
	}

	close( fd );

	return( 0 );
}

/********************************************************************************
 *				xbee.h  					*
 *		This file contains the code to configure the zigbee ports	*
 *		and controling the data coming through zigbee			*
 *										*
 *		Author	  : Sarbartha Sengupta, Kishaloy Halder, Kaustav Das	*
 *										*
 ********************************************************************************/
#include<avr/io.h>
#include<avr/interrupt.h>
#include<util/delay.h>

unsigned char data; //to store received data from UDR1



//Function To Initialize UART0
// baud rate:9600
// char size: 8 bit
// parity: Disabled
void uart0_init(void)
{
 UCSR0B = 0x00; //disable while setting baud rate
 UCSR0A = 0x00;
 UCSR0C = 0x06;
 UBRR0L = 0x5F; //set baud rate lo
 UBRR0H = 0x00; //set baud rate hi
 UCSR0B = 0x98;
}


SIGNAL(SIG_USART0_RECV) 		// ISR for receive complete interrupt
{
	data = UDR0; 				//making copy of data from UDR0 in 'data' variable 

	UDR0 = data; 				//echo data back to PC

		if(data >= 0x30 && data <=0x39) //ASCII value of 0 - 9
		{
			if (xbeeImageInsert ==0)
			{
				colourValue[imageInput]*=10;
				colourValue[imageInput]+=(int)data-48;
			}
			if (xbeeImageInsert ==1)
			{
				noofpixels[imageInput]*=10;
				noofpixels[imageInput]+=(int)data-48;
			}
			if (xbeeImageInsert ==2)
			{
				max_row*=10;
				max_row+=(int)data-48;
			}
			if (xbeeImageInsert ==3)
			{
				max_col*=10;
				max_col+=(int)data-48;
			}

		}
		if(data == 0x61) //ASCII value of a  -- indicates end of a digit for a cell
		{
			imageInput++;
			if(xbeeImageInsert ==0)
				colourValue[imageInput]=0;
			if (xbeeImageInsert ==1)
				noofpixels[imageInput]=0;

		}
		if(data == 0x62) //ASCII value of b  -- indicates end of an array or a veriable
		{
			imageInput=0;
			xbeeImageInsert++;
			if(xbeeImageInsert==4)
				inputFinished=1;

		}
		if(data == 0x6A) //ASCII value of j  -- indicates the Bot should move left
		{
			botMove=2;
		}
		if(data == 0x6C) //ASCII value of l  -- indicates  the Bot should move right
		{
			botMove=1;
		}
		if(data == 0x69) //ASCII value of i  -- indicates  the Bot should move forward
		{
			botMove=3;
		}
		if(data == 0x6B) //ASCII value of k  -- indicates  the Bot should move backward
		{
			botMove=4;
		}
		if(data == 0x64) //ASCII value of d  -- indicates  the Bot is in proper position and it can start drawing the row.
		{
			botMove=5;
		}

}


//Function To Initialize all The Devices
void init_xbee()
{
 cli(); //Clears the global interrupts
 port_init();  //Initializes all the ports
 uart0_init(); //Initailize UART1 for serial communiaction
 sei();   //Enables the global interrupts
}



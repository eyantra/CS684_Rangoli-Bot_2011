/****************************************************************
 * 			servo.h					*
 * This file contains code to intialize and run the left and 	*
 * right motors, three servo motors (only two are being used.	*
 * It has the function which initializes the timers. The 	*
 * functions of the form servo_<num> rotate the servo given	*
 * servo motor to the angle given as argument. The functions	*
 * servo_<num>_free free the servo motors and allow them to 	*
 * freely rotate.						*
 *								*
 * Author  : Sarbartha Sengupta, Kishaloy Halder, Kaustav Das	*
 *								*
 ****************************************************************/
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

int wait=500;          /*! The delay in milliseconds */
int dropping_time = 500;

/*!
 * The following three fucntions intialize and configure
 * the servo motors.
 */
void servo1_pin_config (void)
{
 DDRB  = DDRB | 0x20;  //making PORTB 5 pin output
 PORTB = PORTB | 0x20; //setting PORTB 5 pin to logic 1
}

void servo2_pin_config (void)
{
 DDRB  = DDRB | 0x40;  //making PORTB 6 pin output
 PORTB = PORTB | 0x40; //setting PORTB 6 pin to logic 1
}

//Configure PORTB 7 pin for servo motor 3 operation
void servo3_pin_config (void)
{
 DDRB  = DDRB | 0x80;  //making PORTB 7 pin output
 PORTB = PORTB | 0x80; //setting PORTB 7 pin to logic 1
}

/*!
 * Timer1 initialization
 * TIMER1 initialization in 10 bit fast PWM mode  
 * prescale:256
 * WGM: 7) PWM 10bit fast, TOP=0x03FF
 * actual value: 42.187Hz 
 */
void timer1_init(void)
{
 TCCR1B = 0x00; /*! stop */
 TCNT1H = 0xFC; /*! Counter high value to which OCR1xH value is to be compared with */
 TCNT1L = 0x01;	/*! Counter low value to which OCR1xH value is to be compared with */
 OCR1AH = 0x03;	/*! Output compare eegister high value for servo 1 */
 OCR1AL = 0xFF;	/*! Output Compare Register low Value For servo 1  */
 OCR1BH = 0x03;	/*! Output compare eegister high value for servo 2 */
 OCR1BL = 0xFF;	/*! Output Compare Register low Value For servo 2  */
 OCR1CH = 0x03;	/*! Output compare eegister high value for servo 3  */
 OCR1CL = 0xFF;	/*! Output Compare Register low Value For servo 3 */
 ICR1H  = 0x03;	
 ICR1L  = 0xFF;
 TCCR1A = 0xAB; /*! 
                 * {COM1A1=1, COM1A0=0; COM1B1=1, COM1B0=0; COM1C1=1 COM1C0=0}s
                 * For Overriding normal port functionalit to OCRnA outputs.
				 * {WGM11=1, WGM10=1} Along With WGM12 in TCCR1B for Selecting FAST PWM Mode
				 */
 TCCR1C = 0x00;
 TCCR1B = 0x0C; /*! WGM12=1; CS12=1, CS11=0, CS10=0 (Prescaler=256) */
}

/*!
 * Initialize all ports for the servo motors one by one 
 */
void port_servo_init(void)
{
 servo1_pin_config(); //Configure PORTB 5 pin for servo motor 1 operation
 servo2_pin_config(); //Configure PORTB 6 pin for servo motor 2 operation 
 servo3_pin_config(); //Configure PORTB 7 pin for servo motor 3 operation  
}




/*!
 * The following three functions make the relevant servo 
 * motors to the given angles. 
 * NOTE: The servo motor can move to angles ranging from
 * 0 to 180 degrees. 
 * The given angle has to be in multiples of 2.25 degrees.
 */
 
///Function to rotate Servo 2 by a specified angle in the multiples of 2.25 degrees
void servo_1(unsigned char degrees)  
{
 float PositionPanServo = 0;
 PositionPanServo = ((float)degrees / 2.25) + 21.0;
 OCR1AH = 0x00;
 OCR1AL = (unsigned char) PositionPanServo;
}

///Function to rotate Servo 2 by a specified angle in the multiples of 2.25 degrees
void servo_2(unsigned char degrees)
{
 float PositionTiltServo = 0;
 PositionTiltServo = ((float)degrees / 2.25) + 21.0;
 OCR1BH = 0x00;
 OCR1BL = (unsigned char) PositionTiltServo;
}

///Function to rotate Servo 3 by a specified angle in the multiples of 2.25 degrees
void servo_3(unsigned char degrees)
{
 float PositionTiltServo = 0;
 PositionTiltServo = ((float)degrees / 2.25) + 21.0;
 OCR1CH = 0x00;
 OCR1CL = (unsigned char) PositionTiltServo;
}

/*!
 * The following functions are to free the servo motors
 * servo_free functions unlock the servo motors from the any angle 
 * and make them free by giving 100% duty cycle at the PWM. This function can be used to 
 * reduce the power consumption of the motor if it is holding load against the gravity.
*/
void servo_1_free (void) /// makes servo 1 free rotating
{
 OCR1AH = 0x03; 
 OCR1AL = 0xFF; //Servo 1 off
}




void servo_2_free (void) /// makes servo 2 free rotating
{
 OCR1BH = 0x03;
 OCR1BL = 0xFF; //Servo 2 off
}

void servo_3_free (void) /// makes servo 3 free rotating
{
 OCR1CH = 0x03;
 OCR1CL = 0xFF; //Servo 3 off
} 

int pen_on = 0; /*! This variable stores the current state
                 * of the servo motor controlling the flow
                 * of the rangoli powder
                 */
                 
/*!
 * This function blocks the opening of the hopper containing 
 * the rangoli powder.                 
*/
void pen_up(){
	servo_1(140);
	_delay_ms(wait);
}

/*!
 * This function unblocks the opening of the hopper containing
 * the rangoli powder.
 */
void pen_down(){
	servo_1(150);
	servo_1(90);
	_delay_ms(dropping_time);  // delay
}

int vt;  /*! How many times to tap the rangoli hopper before 
          * dropping powder at a point
          */
          
/*!
 * This function taps the rangoli hopper so that the flow of 
 * the rangoli powder is maintained.
 */          
void vibrate(){
 	for(vt=0;vt<2;vt++){
		servo_2(105);
		_delay_ms(300);
		servo_2(165);
		_delay_ms(300);
	}
	
}

/*! Intialize the servo motors */
void servo_init(){
cli();
 port_servo_init();
 timer1_init();
 sei(); //re-enable interrupts 
}


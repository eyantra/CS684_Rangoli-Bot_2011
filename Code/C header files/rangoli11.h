/********************************************************************************
 *				rangoli.h  					*
 *		This file contains necessary variables and Functions 		*
 *	        required in the Rangoli Bot Project.				*
 *										*
 *		Author	  : Sarbartha Sengupta, Kishaloy Halder, Kaustav Das	*
 *										*
 ********************************************************************************/
unsigned int leftShaftCounter = 0;

int colourValue[100]={0}; 	// This array contains the color values of the Encoded data sent by Scilab.
int noofpixels[100]={0};  	// This array contains the no of pixels each color value contains.  

int max_row = 0; 	  	// Contains The no of rows the input picture have.
int max_col = 0;		// Contains The no of columns the input picture have.

//int insertColor=0;		
//int insertLength=0;
int imageInput=0;		// This variable is used to insert the Image data coming from Zigbee into the arrays (colorValues & noofpixels) & variables (max_row & max_col).

int inputFinished=0;		// Indicates whether The image is completed feeded of not. 0-> Image send has not started or is in process. || 1-> Image input is done.

int xbeeImageInsert=0; 		// Determine where the data will be insurted (coming from zigbee).  0 -> colorValue || 1 -> noofpixels || 2-> max_row || 3-> max_col

int botMove = 0;		// Determines bot's movement while in the control of the camera. 1-> Right || 2-> Left || 3-> Forward || 4-> Backward

int movementState = 1;		// Determines which is the status of the bot. 1-> Means not in the control of the bot. || 2-> Listening to the instruction os the Camera.

int currentRow=-1;		// Indicates which row the bot is now drawing.
int currentCol=100;		// Indicates which column the bot is now drawing.
int is_Fwd=1; 			// Indicates whether the bot will draw by moving forward or backward.  0-> Move Forward || 1-> Move Backward.
int cellCountinImage=0;		// Indicates the current array locations.
int endofRow=1;			// Indicates whether we have completed drawing 1 row or not.
#define MOTOR_SHAFT_L get_shaft_l()
#define MAXROW  maxRow()
#define MAXCOLUMN maxCol()
#define GETCOLOR get_col()
#define GETLENGTH get_length()
#define ISFWD get_isFwd()
#define ISDRAW isDraw()
#define BOTMOVE get_botmove()
#define MOVEMENTSTATE get_movementstate()

int get_isFwd() 		// Returns the value of is_Fwd
{
	return is_Fwd;
}
int get_movementstate()		// Returns the value of movementState
{
	return movementState;
}
int get_botmove()		// Returns the value of botMove
{
	return botMove;
}
int isDraw()			// Returns the value of inputFinished
{
	return inputFinished;
}


void set_currentCol()		// Set bot parameters when its ready to draw the next line.
{
	currentRow++;
	currentCol=0;
	endofRow=0;
	movementState=0;
	if(is_Fwd==0)
		is_Fwd=1;
	else
		is_Fwd=0;
}
int maxRow()			// Returns whether we have drawn all rows or not.
{
	if(currentRow < max_row)
		return 0;
	else
		return 1;
		
}
int maxCol()			// Returns whether we have drawn all columns of a row or not.
{
	if(currentCol < max_col)
		return 0;
	else
	{
		

		endofRow=1;
		return 1;

	}
}
int get_col()					// Returns the color value.
{
	return colourValue[cellCountinImage];
}
int get_length()				// Returns the length value.
{
	return noofpixels[cellCountinImage];

}
void increase_cell_count()			// Increment cell count.
{
	currentCol+=noofpixels[cellCountinImage];
	cellCountinImage++;
}

void DELAY(int val)				// Delay
{
	_delay_ms(val);
}

void set_bot_move()				// Returns botMove status.
{
	botMove=0;
}

void set_movement_state()			// Increments movementState
{
	movementState++;
}
void set_shaft_l()				// Set the leftShaftCounter to 0
{
	leftShaftCounter=0;
}
int get_shaft_l()				// Returns the value of leftShaftCounter
{
	return leftShaftCounter;
}
ISR(INT4_vect)					// Shaft Counter Interrupt call.
{
	leftShaftCounter++;
}


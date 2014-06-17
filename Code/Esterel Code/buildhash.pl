#!/usr/bin/perl
#use Switch;
$ip=" ";  
$ip=(@ARGV)[0];
$filename=$ip;
$modulename=(@ARGV)[2];
#print "$modulename\n";
unless(-e $filename)
{
   print "file doesnot exitst";
   return;
}
open FH,$filename or die $!;
@inputfile_contents=<FH>;
$length_inputfile=@inputfile_contents;
$i=0;
$key=0;
$value=0;
while( $i < $length_inputfile )       # code for getting the input and output signals used in the esterel program
{
  $e15 = (@inputfile_contents)[$i];
  if ( $e15 =~ /<BuiltinTypeSymbol id="(.*)">/ )
  {
	$key = $1;
	$i++;
	$e16=(@inputfile_contents)[$i];
	if ( $e16 =~ /<S>(.*)<\/S>/ )
	{
		$value=$1;
		$symboltable{$key}=$value;
        }
  }
  $i++;
}
#my %symboltable=(
#	4   => boolean,
#	5   => integer,
#	6   => float,
#	7   => double,
#	8   => string,
#	10  => false,
#	11  => 0,
#	12  => ture,
#	13  => 1,
#);
#print %symboltable;
#exit 0;

$i=0;
$key=0;
$value=0;
$type="null";
while( $i < $length_inputfile )       # code for getting the input and output signals used in the esterel program
{
  $e12 = (@inputfile_contents)[$i];
  if ( $e12 =~ /<SignalSymbol id="(.*)">/ )
  {
    #print "$1 ----";
    $key = $1;
    $i++;
    $e13=(@inputfile_contents)[$i];
    if ( $e13 =~ /<S>(.*)<\/S>/ )
    {
      #print "$1 \n";
      $value=$1;
      $i=$i+1;
      $e1311=(@inputfile_contents)[$i];		
      if($e1311 =~ /<Ref id="(.*)"\/>/ )
      {
	$type=$symboltable{$1};
	#print "\n$type\n";
      }
      $i=$i+2;
      $e131=(@inputfile_contents)[$i];
      if($e131 =~ /<Int>(.*)<\/Int>/ )
      {
	if( $1 =~ /0/ )
	{
	      $signals{$key}=$value;
	      @input=(@input,$value);
	      if($type !~ /null/)
            	     { @input_signature=(@input_signature,$value."(".$type.")"); }
	      else
		     { @input_signature=(@input_signature,$value);}	
 	}
	elsif ( $1 =~ /1/ )
	{
	      $signals{$key}=$value;
	      @output=(@output,$value);
	      if($type !~ /null/)
            	    {  @output_signature=(@output_signature,$value."(".$type.")");}
	      else
		    {  @output_signature=(@output_signature,$value);}		 	
	}
	elsif ( $1 =~ /2/ )
	{
	      $signals{$key}=$value;
	      @inputoutput=(@inputoutput,$value);
	      if($type !~ /null/)
            	    {  @inputoutput_signature=(@inputoutput_signature,$value."(".$type.")");}
	      else
		    {  @inputoutput_signature=(@inputoutput_signature,$value);}		 	
	
        }
	elsif ( $1 =~/3/ )
	{
	      $signals{$key}=$value;
	      @sensor=(@sensor,$value);
	      if($type !~ /null/)
            	    {  @sensor_signature=(@sensor_signature,$value."(".$type.")");}
	      else
		    {  @sensor_signature=(@sensor_signature,$value);}	
	} 
      }		
    }
  }
  $i++;
  $type="null";
}

#removing duplicates from output signals  ---- duplicates occur when your program has multiple modules
my %hash   = map { $_ => 1 } @output_signature;
@output_signature = keys %hash;

#print %signals;
#print "\n";
#print "input signals:\n";
#print "@input\n";
#print "input signals with signatures:\n";
#print "@input_signature\n";
#print "output signals:\n";
#print "@output\n";
#print "output signals with signatures:\n";
#print "@output_signature\n";
#print "inputoutput signals:\n";
#print "@inputoutput\n";
#print "inputoutput signals with signatures:\n";
#print "@inputoutput_signature\n";
#print "sensors:\n";
#print "@sensor\n";
#print "sensors with types:\n";
#print "@sensor_signature\n";
#exit 0; # to be removed


$j=0;
while( $j < $length_inputfile )   #Code for getting the signals on which awaits are called. (ex. await, abort..when, do..watching, etc.)
{
  $e14 = (@inputfile_contents)[$j];
  if ( $e14 =~ /<LoadSignalExpression id="(.*)">/ )
  {
    $j++;
    $j++; 	
    $e15=(@inputfile_contents)[$j];
    if ( $e15 =~ /<Ref id="(.*)"\/>/ )
    {
      #print "$1 \n";
      @awaits_id=(@awaits_id,$1);
    }
  }
  $j++;
}
#print "awaits_ids\n";
#print "@awaits_id\n";
@awaits_without_dups = grep { !$count{$_}++ } @awaits_id; # removing duplicates for awaits
#print "@awaits_without_dups\n";
for $e16 (@awaits_without_dups)
{
  @await=(@await,$signals{$e16});
}
@await = grep { !$count{$_}++ } @await; # removing duplicates for awaits
#print "awaits:\n";
#print "@await\n";

#these are the set of valid input signals for firebird
@input_keywords = ("MIDDLE_WHITELINE_VALUE(integer)","LEFT_WHITELINE_VALUE(integer)","RIGHT_WHITELINE_VALUE(integer)",
		   "IS_FWD(integer)","BOT_MOVE(integer)","MOVEMENT_STATE(integer)","GET_LENGTH(integer)","IS_DRAW(integer)","MAX_ROW(integer)","MAX_COLUMN(integer)","GET_COLOR(integer)","BUMPSWITCH_ANY","BUMPSWITCH_1","BUMPSWITCH_2","BUMPSWITCH_3","BUMPSWITCH_4","BUMPSWITCH_5",
		   "FRONT_IR_VALUE(integer)","MOTOR_SHAFT_LEFT(integer)","LEFT_IR_VALUE(integer)","RIGHT_IR_VALUE(integer)","BATTERY_VOLTAGE(integer)","RECEIVE(integer)",
                   "MOTOR_SHAFT_R","MOTOR_SHAFT_L","FIR_LESS_THRE","RIR_LESS_THRE","LIR_LESS_THRE");

#there are the set of valid output signals for firebird
@output_keywords = ("BUZZER_ON","BUZZER_OFF","MOTOR_LEFT_SPEED(integer)","MOTOR_RIGHT_SPEED(integer)",
		    "SET_ROW","INCREASE_CELL_COUNT","SET_SHAFT_L","SET_MOVEMENT_STATE","SET_BOT_MOVE","MOVE_FWD","MOVE_REV","MOVE_RIGHT","MOVE_LEFT","MOVE_STOP","MOVE_INPLACE_LEFT",
		    "MOVE_INPLACE_RIGHT","MOVE_SOFT_LEFT","MOVE_SOFT_RIGHT","MOVE_REV_DIST(integer)",
		    "MOVE_FWD_DIST(integer)","MOVE_INPLACE_LEFT_DEGREE(integer)","MOVE_INPLACE_RIGHT_DEGREE(integer)",
		    "MOVE_SOFT_LEFT_DEGREE(integer)","MOVE_SOFT_RIGHT_DEGREE(integer)","MOVE_RIGHT_DEGREE(integer)",
		    "MOVE_LEFT_DEGREE(integer)","LCD_INIT","LCD_CLEAR","LCD_DISPLAY_1(string)","LCD_DISPLAY_2(string)",
                    "LCD_DISPLAY_INT_1(integer)","LCD_DISPLAY_INT_2(integer)","SERVO_A_ON(integer)","SERVO_A_OFF(integer)",
		    "SERVO_B_ON(integer)","SERVO_B_OFF(integer)","SERVO_C_ON(integer)","DELAY(integer)","SERVO_C_OFF(integer)","SERVO_TURN_OFF","SET_FIR_THRESHOLD(integer)",
		    "SET_LIR_THRESHOLD(integer)","SET_RIR_THRESHOLD(integer)","SEND(integer)");

#these are the set of valid sesors for firebird
@sensor_keywords = ("MIDDLE_WHITELINE_VALUE(integer)","LEFT_WHITELINE_VALUE(integer)","RIGHT_WHITELINE_VALUE(integer)",
		    "FRONT_IR_VALUE(integer)","LEFT_IR_VALUE(integer)","RIGHT_IR_VALUE(integer)","BATTERY_VOLTAGE(integer)");

#cheking whether the used input signals are valid or not
$flag_input=0;
$global_flag=0;
for $l1 (@input_signature)
{
 $flag_input=0;
 for $m1 (@input_keywords)
 {
   if ( $l1 eq $m1)
   {
     $flag_input=1;
   }
 }
 if ( $flag_input == 0 )
 {
   print "$l1 : Not a valid keyword\n";
   $global_flag=1;
 }
}

#cheking whether the used output signals are valid or not
$flag_output=0;
for $l2 (@output_signature)
{
 $flag_output=0;
 for $m2 (@output_keywords)
 {
   if ( $l2 eq $m2)
   {
     $flag_output=1;
   }
 }
 if ( $flag_output == 0 )
 {
   print "$l2 : Not a valid keyword\n";
   $global_flag=1;
 }
}

#cheking whether the used sensors are valid or not
$flag_sensor=0;
for $l2 (@sensor_signature)
{
 $flag_sensor=0;
 for $m2 (@sensor_keywords)
 {
   if ( $l2 eq $m2)
   {
     $flag_sensor=1;
   }
 }
 if ( $flag_sensor == 0 )
 {
   print "$l2 : Not a valid keyword\n";
   $global_flag=1;
 }
}

if ( $global_flag == 1 )
{
  exit 0;
}

#code for the main() function to be added to the esterel generated C code

$ofile=(@ARGV)[1];
open OF,">$ofile" or die $!;
print OF "/****************************** Fire Bird Specific part ***************************/\n";
#print OF "#include \"functions.h\"\n";
print OF "static int  IR_THRESHHOLD[3] = {50, 50, 50};\n";
$length_output=@output_signature;
if( $length_output !=0 )
{
 for $elem (@output_signature)
 {
	if ( $elem eq "BUZZER_ON" )
	{
	  print OF "$modulename\_O_BUZZER_ON(void)\n";
 	  print OF "{\n";
	  print OF "	BUZZER_ON();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "BUZZER_OFF" )
	{
	  print OF "$modulename\_O_BUZZER_OFF(void)\n";
 	  print OF "{\n";
	  print OF "	BUZZER_OFF();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "MOTOR_LEFT_SPEED(integer)" )
	{
	  print OF "$modulename\_O_MOTOR_LEFT_SPEED(int val)\n";
 	  print OF "{\n";
	  print OF "	MOTOR_LEFT_SPEED(val);\n";
	  print OF "}\n";	
	}
	if ( $elem eq "MOTOR_RIGHT_SPEED(integer)" )
	{
	  print OF "$modulename\_O_MOTOR_RIGHT_SPEED(int val)\n";
 	  print OF "{\n";
	  print OF "	MOTOR_RIGHT_SPEED(val);\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SET_MOVEMENT_STATE" )
	{
	  print OF "$modulename\_O_SET_MOVEMENT_STATE(void)\n";
 	  print OF "{\n";
	  print OF "	set_movement_state();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SET_SHAFT_L" )
	{
	  print OF "$modulename\_O_SET_SHAFT_L(void)\n";
 	  print OF "{\n";
	  print OF "	set_shaft_l();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SET_BOT_MOVE" )
	{
	  print OF "$modulename\_O_SET_BOT_MOVE(void)\n";
 	  print OF "{\n";
	  print OF "	set_bot_move();\n";
	  print OF "}\n";	
	}
	if ( $ele eq "MAX_ROW(integer)" )
	{
	   print OF "int $modulename\_S_MAX_ROW(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=maxRow();\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
	if ( $ele eq "IS_DRAW(integer)" )
	{
	   print OF "int $modulename\_S_IS_DRAW(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=isDraw();\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
	if ( $ele eq "MAX_COLUMN(integer)" )
	{
	   print OF "int $modulename\_S_MAX_COLUMN(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=maxCol();\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
	if ( $ele eq "GET_COLOR(integer)" )
	{
	   print OF "int $modulename\_S_GET_COLOR(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=get_Col();\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
	if ( $ele eq "IS_ROW_SET(integer)" )

	{
	   print OF "int $modulename\_S_IS_ROW_SET(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=get_endofrow();\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
	if ( $ele eq "GET_LENGTH(integer)" )

	{
	   print OF "int $modulename\_S_GET_LENGTH(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=get_length();\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
	if ( $elem eq "INCREASE_CELL_COUNT" )
	{
	  print OF "$modulename\_O_INCREASE_CELL_COUNT(void)\n";
 	  print OF "{\n";
	  print OF "	increase_cell_count();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SET_ROW" )
	{
	  print OF "$modulename\_O_SET_ROW(void)\n";
 	  print OF "{\n";
	  print OF "	set_currentCol();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "MOVE_FWD" )
	{
	  print OF "$modulename\_O_MOVE_FWD(void)\n";
 	  print OF "{\n";
	  print OF "	MOVE_FWD();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "MOVE_REV" )
	{
	  print OF " $modulename\_O_MOVE_REV(void)\n";
 	  print OF "{\n";
	  print OF "	MOVE_REV();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "MOVE_LEFT" )
	{
	  print OF " $modulename\_O_MOVE_LEFT(void)\n";
 	  print OF "{\n";
	  print OF "	MOVE_LEFT();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "MOVE_RIGHT" )
	{
	  print OF "$modulename\_O_MOVE_RIGHT(void)\n";
 	  print OF "{\n";
	  print OF "	MOVE_RIGHT();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "MOVE_STOP" )
	{
	  print OF "$modulename\_O_MOVE_STOP(void)\n";
 	  print OF "{\n";
	  print OF "	MOVE_STOP();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "MOVE_INPLACE_LEFT" )
	{
	  print OF " $modulename\_O_MOVE_INPLACE_LEFT(void)\n";
 	  print OF "{\n";
	  print OF "	MOVE_INPLACE_LEFT();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "MOVE_INPLACE_RIGHT" )
	{
	  print OF " $modulename\_O_MOVE_INPLACE_RIGHT(void)\n";
 	  print OF "{\n";
	  print OF "	MOVE_INPLACE_RIGHT();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "MOVE_SOFT_LEFT" )
	{
	  print OF " $modulename\_O_MOVE_SOFT_LEFT(void)\n";
 	  print OF "{\n";
	  print OF "	MOVE_SOFT_LEFT();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "MOVE_SOFT_RIGHT" )
	{
	  print OF " $modulename\_O_MOVE_SOFT_RIGHT(void)\n";
 	  print OF "{\n";
	  print OF "	MOVE_SOFT_RIGHT();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "LCD_INIT" )
	{
	  print OF "$modulename\_O_LCD_INIT(void)\n";
 	  print OF "{\n";
	  print OF "	LCD_INIT();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "LCD_CLEAR" )
	{
	  print OF "$modulename\_O_LCD_CLEAR(void)\n";
 	  print OF "{\n";
	  print OF "	LCD_CLEAR();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "LCD_DISPLAY_1(string)" )
	{
	  print OF "$modulename\_O_LCD_DISPLAY_1(char val[])\n";
 	  print OF "{\n";
	  print OF "	LCD_DISPLAY_1(val);\n";
	  print OF "}\n";	
	}
	if ( $elem eq "LCD_DISPLAY_2(string)" )
	{
	  print OF "$modulename\_O_LCD_DISPLAY_2(char val[])\n";
 	  print OF "{\n";
	  print OF "	LCD_DISPLAY_2(val);\n";
	  print OF "}\n";	
	}
	if ( $elem eq "LCD_DISPLAY_INT_1(integer)" )
	{
	  print OF " $modulename\_O_LCD_DISPLAY_INT_1(int val)\n";
 	  print OF "{\n";
	  print OF "	LCD_DISPLAY_INT_1(val);\n";
	  print OF "}\n";	
	}
	if ( $elem eq "LCD_DISPLAY_INT_2(integer)" )
	{
	  print OF " $modulename\_O_LCD_DISPLAY_INT_2(int val)\n";
 	  print OF "{\n";
	  print OF "	LCD_DISPLAY_INT_2(val);\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SERVO_A_ON(integer)" )
	{
	  print OF "$modulename\_O_SERVO_A_ON(integer val)\n";
 	  print OF "{\n";
	  print OF "	SERVO_A_DIRECTION(val);\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SERVO_A_OFF(integer)" )
	{
	  print OF "$modulename\_O_SERVO_A_OFF(integer val)\n";
 	  print OF "{\n";
	  print OF "	SERVO_A_DIRECTION(val);\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SERVO_B_ON(integer)" )
	{
	  print OF "$modulename\_O_SERVO_B_ON(integer val)\n";
 	  print OF "{\n";
	  print OF "	SERVO_B_DIRECTION(val);\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SERVO_B_OFF(integer)" )
	{
	  print OF "$modulename\_O_SERVO_B_OFF(integer val)\n";
 	  print OF "{\n";
	  print OF "	SERVO_B_DIRECTION(val);\n";
	  print OF "}\n";	
	}

	if ( $elem eq "SERVO_C_ON(integer)" )
	{
	  print OF "$modulename\_O_SERVO_C_ON(integer val)\n";
 	  print OF "{\n";
	  print OF "	SERVO_C_DIRECTION(val);\n";
	  print OF "}\n";	
	}
	if ( $elem eq "DELAY(integer)" )
	{
	  print OF "$modulename\_O_DELAY(integer val)\n";
 	  print OF "{\n";
	  print OF "	DELAY(val);\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SERVO_C_OFF(integer)" )
	{
	  print OF "$modulename\_O_SERVO_C_OFF(integer val)\n";
 	  print OF "{\n";
	  print OF "	SERVO_C_DIRECTION(val);\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SERVO_TURN_OFF" )
	{
	  print OF "$modulename\_O_SERVO_TURN_OFF(void)\n";
 	  print OF "{\n";
	  print OF "	SERVO_TURN_OFF();\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SEND(integer)" )
	{
	  print OF "$modulename\_O_SEND(int val)\n";
 	  print OF "{\n";
	  print OF "	send_integer(val);\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SET_FIR_THRESHOLD(integer)" )
	{
	  print OF "$modulename\_O_SET_FIR_THRESHOLD(int val)\n";
 	  print OF "{\n";
	  print OF "	IR_THRESHHOLD[0] = val;\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SET_LIR_THRESHOLD(integer)" )
	{
	  print OF "$modulename\_O_SET_LIR_THRESHOLD(int val)\n";
 	  print OF "{\n";
	  print OF "	IR_THRESHHOLD[1] = val;\n";
	  print OF "}\n";	
	}
	if ( $elem eq "SET_RIR_THRESHOLD(integer)" )
	{
	  print OF "$modulename\_O_SET_RIR_THRESHOLD(int val)\n";
 	  print OF "{\n";
	  print OF "	IR_THRESHHOLD[2] = val;\n";
	  print OF "}\n";	
	}
 }
}

$length_sensor=@sensor_signature;
if( $length_sensor !=0 )
{
 for $ele (@sensor_signature)
 {
	if ( $ele eq "MIDDLE_WHITELINE_VALUE(integer)" )
	{
	   print OF "int $modulename\_S_MIDDLE_WHITELINE_VALUE(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=(int)ADC_conversion(5);\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
	if ( $ele eq "LEFT_WHITELINE_VALUE(integer)" )
	{
	   print OF "int $modulename\_S_LEFT_WHITELINE_VALUE(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=(int)ADC_conversion(4);\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
	if ( $ele eq "RIGHT_WHITELINE_VALUE(integer)" )
	{
	   print OF "int $modulename\_S_RIGHT_WHITELINE_VALUE(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=(int)ADC_conversion(6);\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
	if ( $ele eq "BATTERY_VOLTAGE(integer)" )
	{
	   print OF "int $modulename\_S_BATTERY_VOLTAGE(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=battery_voltage_calculation();\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
	if ( $ele eq "MOTOR_SHAFT_LEFT(integer)" )
	{
	   print OF "int $modulename\_S_MOTOR_SHAFT_LEFT(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=get_shaft_l();\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
	if ( $ele eq "FRONT_IR_VALUE(integer)" )
	{
	   print OF "int $modulename\_S_FRONT_IR_VALUE(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=front_dist_mm();\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
	if ( $ele eq "LEFT_IR_VALUE(integer)" )
	{
	   print OF "int $modulename\_S_LEFT_IR_VALUE(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=left_dist_mm();\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
	if ( $ele eq "RIGHT_IR_VALUE(integer)" )
	{
	   print OF "int $modulename\_S_RIGHT_IR_VALUE(void)\n";
	   print OF "{\n";
	   print OF "	int val;\n";
	   print OF "	val=right_dist_mm();\n";
	   print OF "        return val;\n";
	   print OF "}\n";
	}
 }
}


print OF "\n/****************************** Main function ***************************/\n";
print OF "void main()\n";
print OF "{\n";
print OF " init_devices();\n";
print OF " $modulename\_reset();\n";
print OF " $modulename();\n";
$length_await=@await;
if ( $length_await != 0 )
{
  print OF " while(1)\n";
  print OF " {\n";
  for $e133 (@await)
  {
	#print $e133."\n";
	if ( $e133 eq  "BUMPSWITCH_ANY" )
  	{
	   print OF "    if(BUMPANY == 1)  { $modulename\_I_BUMPSWITCH_ANY(); }\n";
	}
	if ( $e133 eq  "BUMPSWITCH_1" )
  	{
	   print OF "    if(BUMP1 == 1)  { $modulename\_I_BUMPSWITCH_1(); }\n";
	}
	if ( $e133 eq  "BUMPSWITCH_2" )
  	{
	   print OF "    if(BUMP2 == 1)  { $modulename\_I_BUMPSWITCH_2(); }\n";
	}
	if ( $e133 eq  "BUMPSWITCH_3" )
  	{
	   print OF "    if(BUMP3 == 1)  { $modulename\_I_BUMPSWITCH_3(); }\n";
	}
	if ( $e133 eq  "BUMPSWITCH_4" )
  	{
	   print OF "    if(BUMP4 == 1)  { $modulename\_I_BUMPSWITCH_4(); }\n";
	}
	if ( $e133 eq  "BUMPSWITCH_5" )
  	{
	   print OF "    if(BUMP5 == 1)  { $modulename\_I_BUMPSWITCH_5(); }\n";
	}
	if ( $e133 eq "MIDDLE_WHITELINE_VALUE" )
	{
	   print OF "    $modulename\_I_MIDDLE_WHITELINE_VALUE(LIGHT_MIDDLE);\n";
	}
	if ( $e133 eq "LEFT_WHITELINE_VALUE" )
	{
	   print OF "    $modulename\_I_LEFT_WHITELINE_VALUE(LIGHT_LEFT);\n";
	}
	if ( $e133 eq "RIGHT_WHITELINE_VALUE" )
	{
	   print OF "    $modulename\_I_RIGHT_WHITELINE_VALUE(LIGHT_RIGHT);\n";
	}
	if ( $e133 eq "MOTOR_SHAFT_LEFT" )
	{
	   print OF "    $modulename\_I_MOTOR_SHAFT_LEFT(MOTOR_SHAFT_L);\n";
	}
	if ( $e133 eq "FRONT_IR_VALUE" )
	{
	   print OF "    $modulename\_I_FRONT_IR_VALUE(FRONT_IR);\n";
	}
	if ( $e133 eq "LEFT_IR_VALUE" )
	{
	   print OF "    $modulename\_I_LEFT_IR_VALUE(LEFT_IR);\n";
	}
	if ( $e133 eq "RIGHT_IR_VALUE" )
	{
	   print OF "    $modulename\_I_RIGHT_IR_VALUE(RIGHT_IR);\n";
	}
	if ( $e133 eq "BATTERY_VOLTAGE" )
	{
	   print OF "    $modulename\_I_BATTERY_VOLTAGE(BATTERY_VOLTAGE);\n";
	}
	if ( $e133 eq "MOTOR_SHAFT_R" )
	{
	   print OF "    if(rshaft_present == 1)  { rshaft_present=0; $modulename\_I_MOTOR_SHAFT_R();}\n";
	}
	if ( $e133 eq "MAX_ROW" )
	{
	   print OF "    $modulename\_I_MAX_ROW(MAXROW);\n";
	}
	if ( $e133 eq "IS_DRAW" )
	{
	   print OF "    $modulename\_I_IS_DRAW(ISDRAW);\n";
	}
	if ( $e133 eq "MAX_COLUMN" )
	{
	   print OF "    $modulename\_I_MAX_COLUMN(MAXCOLUMN);\n";
	}
	if ( $e133 eq "GET_COLOR" )
	{
	   print OF "    $modulename\_I_GET_COLOR(GETCOLOR);\n";
	}
	if ( $e133 eq "GET_LENGTH" )
	{
	   print OF "    $modulename\_I_GET_LENGTH(GETLENGTH);\n";
	}
	if ( $e133 eq "IS_FWD" )
	{
	   print OF "    $modulename\_I_IS_FWD(ISFWD);\n";
	}
	if ( $e133 eq "BOT_MOVE" )
	{
	   print OF "    $modulename\_I_BOT_MOVE(BOTMOVE);\n";
	}
	if ( $e133 eq "MOVEMENT_STATE" )
	{
	   print OF "    $modulename\_I_MOVEMENT_STATE(MOVEMENTSTATE);\n";
	}
	if ( $e133 eq "MOTOR_SHAFT_L" )
	{
	   print OF "    if(lshaft_present == 1)  { lshaft_present=0; $modulename\_I_MOTOR_SHAFT_L();}\n";
	}
	if ( $e133 eq  "RECEIVE" )
  	{
	   print OF "    if(DATA_RECEIVED == 1)\n"; #$modulename\_I_BUMPSWITCH_4(); }\n";
	   print OF "    {\n";
	   print OF "	   int val;\n";
	   print OF "	   val=receive_integer();\n";
	   print OF "      $modulename\_I_RECEIVE(val);\n";
	   print OF "    }\n";
	}
	if ( $e133 eq "FIR_LESS_THRE" )
	{
           print OF "    if(FRONT_IR < IR_THRESHHOLD[0])\n";
	   print OF "    {\n";
	   print OF "    	$modulename\_I_FIR_LESS_THRE();\n";
	   print OF "    }\n";
	}
	if ( $e133 eq "LIR_LESS_THRE" )
	{
           print OF "    if(LEFT_IR < IR_THRESHHOLD[1])\n";
	   print OF "    {\n";
	   print OF "    	$modulename\_I_LIR_LESS_THRE();\n";
	   print OF "    }\n";
	}
	if ( $e133 eq "RIR_LESS_THRE" )
	{
           print OF "    if(RIGHT_IR < IR_THRESHHOLD[0])\n";
	   print OF "    {\n";
	   print OF "    	$modulename\_I_RIR_LESS_THRE();\n";
	   print OF "    }\n";
	}
  }
  print OF "    $modulename();\n";
  print OF " }\n";
}
else
{ 
  print OF " $modulename();\n";
}
print OF "}\n";

close FH;
close OF;


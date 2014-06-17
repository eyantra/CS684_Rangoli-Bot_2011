CS684 Course Project (Rangoli Bot)

Team 1
Team Members:
Sarartha Sengupta (10305903) [Team Leader]
Kaustav Das (10305024)
Kishaloy Halder (10305022)

==========================================================================================================================================

Source Code folder contains 4 folders.

1>"Esterel Code" folder contains two files "rangoli.strl" and "buildhash.pl".
2>"C header files" folder contains 4 header files "rangoli11.h", "firebird_winavr.h", "servo.h" and "xbee.h".
3>"Scilab Code" folder contains three files "inputImageProcessing.sce" and "negativeFeedbackSystem.sce" and "siseli.dll' file.
4>"test input" folder contains input binary images.

==========================================================================================================================================

Compiling and burning esterel code
==========================================================================================================================================
To compile the esterel code command is "$./firebird_gen rangoli.strl". builhash.pl needs to be kept in same directory as of esterel file.

This will generate "rangoli.c" file which needs to be compiled using winavr studio and corresponding generated hex file needs to be burnt into the bot using programmer. While compiling all the header files need to be kept in the same directory as that of the "rangoli.c" file.

===========================================================================================================================================

Running scilab Code
===========================================================================================================================================
Dependencies:

scilab 4.0 (http://www.scilab.org)
OpenCV 1.0 (http://sourceforge.net/projects/opencvlibrary)
SIVP toolbox ( http://atoms.scilab.org/toolboxes/IPD/2.0)
ipd.zip file needs to be extracted in cotrib folder of scilab 4.0 (e.g., C:/Program Files/scilab-4.0/contrib)

Firstly Scilab Image and Video Processing (SIVP) toolbox needs to be loaded in the scilab environment. Directory has to be changed where the scilab codes are. Command is chdir("C:/Program Files/scilab-4.0/Embedded") if the codes are in Embedded folder. "siseli.dll" needs to be kept in same directory. After this "inputImageProcessing.sce" code needs to be executed. Command is "exec("inputImageProcessing.sce"). Finally "negativeFeedbackSystem.sce" needs to be executed. Command is exec(""negativeFeedbackSystem.sce").

===========================================================================================================================================









//*****************************************************************************
//*** slLoad
//*****************************************************************************
function slLoad()
    slFuncs(1,1)= link("siseli.dll","version","c");
    slFuncs(1,2)= link("siseli.dll","mount","c");
    slFuncs(1,3)= link("siseli.dll","umount","c");
    slFuncs(1,4)= link("siseli.dll","check","c");
    slFuncs(1,5)= link("siseli.dll","config","c");
    slFuncs(1,6)= link("siseli.dll","open","c");
    slFuncs(1,7)= link("siseli.dll","close","c");
    slFuncs(1,8)= link("siseli.dll","sendb","c");
    slFuncs(1,9)= link("siseli.dll","senda","c");
    slFuncs(1,10)=link("siseli.dll","count","c");
    slFuncs(1,11)=link("siseli.dll","recvb","c");
    slFuncs=resume(slFuncs)
endfunction
//*****************************************************************************
//*** slVersion
//*****************************************************************************
function res=slVersion()
    res=fort("version","out",[1,1],1,"i")/10
endfunction    


//*****************************************************************************
//*** slUnload
//*****************************************************************************
function slUnload()
    for i=1:size(slFuncs,2)
        ulink(slFuncs(i))
    end
    clear slFuncs
endfunction    


//*****************************************************************************
//*** slMount
//*****************************************************************************
function res=slMount(nHandle)
    res=fort("mount",nHandle,1,"i","out",[1,1],2,"i")
endfunction


//*****************************************************************************
//*** slUMount
//*****************************************************************************
function res=slUMount(nHandle)
    res=fort("umount",nHandle,1,"i","out",[1,1],2,"i")
endfunction


//*****************************************************************************
//*** slCheck
//*****************************************************************************
function res=slCheck(nHandle, nPort)
    res=fort("check",nHandle,1,"i",nPort,2,"i","out",[1,1],3,"i")
endfunction


//*****************************************************************************
//*** slConfig
//*****************************************************************************
function res=slConfig(nHandle, nBaud, nBits, nPar, nStop)
    res=fort("config",nHandle,1,"i",nBaud,2,"i",nBits,3,"i",nPar,4,"i",nStop,5,"i","out",[1,1],6,"i")
endfunction


//*****************************************************************************
//*** slOpen
//*****************************************************************************
function res=slOpen(nHandle, nPort)
    res=fort("open",nHandle,1,"i",nPort,2,"i","out",[1,1],3,"i")
endfunction


//*****************************************************************************
//*** slClose
//*****************************************************************************
function res=slClose(nHandle)
    res=fort("close",nHandle,1,"i","out",[1,1],2,"i")
endfunction


//*****************************************************************************
//*** slSendByte
//*****************************************************************************
function res=slSendByte(nHandle, nByte)
    res=fort("sendb",nHandle,1,"i",nByte,2,"i","out",[1,1],3,"i")
endfunction


//*****************************************************************************
//*** slSendArray
//*****************************************************************************
function res=slSendArray(nHandle, nByte, nLength)
    res=fort("senda",nHandle,1,"i",nByte,2,"i",nLength,3,"i","out",[1,1],4,"i")
endfunction
//*****************************************************************************
//*** slCount
//*****************************************************************************
function res=slCount(nHandle)
    res=fort("count",nHandle,1,"i","out",[1,1],2,"i")
endfunction


//*****************************************************************************
//*** slCount
//*****************************************************************************
function res=slReadByte(nHandle, nBlock)
    res=fort("recvb",nHandle,1,"i",nBlock,2,"i","out",[1,1],3,"i")
endfunction


//CameraImage=imread('C:\Documents and Settings\Kishaloy\Desktop\embedded\a.bmp');
camopen();
//moon = imresize(CameraImage,[100 75]);
//[rows, cols]=size(moon);

tolerancePixels_xaxis = 3;  			// Setting the tolarence value in x-axis
tolerancePixels_yaxis = 3;			// Setting the tolarence value in y-axis
distanceFromReferenceUpperThreshold = 390;	// The Upper threshold from where the bot will draw the even lines
distanceFromReferenceLowerThreshold = 185;	// The Lower threshold from where the bot will draw the odd lines
partitioningThreshold =(distanceFromReferenceUpperThreshold+distanceFromReferenceLowerThreshold)/2;	// the mid of the upper & lower threshold

while 1
  CameraImage=avireadframe(1);			// taking the current frame from the camera.
  [rows,cols]=size(CameraImage);
  filteredImage=uint8(zeros(rows,cols,3));	// array to store the filtered imge.
imshow(CameraImage);
 
 // Determining the blue patch
  Isblue=uint8(CameraImage(:,:,1)<uint8(70) & CameraImage(:,:,2)<uint8(70) & CameraImage(:,:,3)>uint8(120));
  [y1,x1] = find(Isblue==1);
  filteredImage(y1,x1,3)=255;
  
 // Determining the blue patch
  Isred=uint8(CameraImage(:,:,1)>uint8(130) & CameraImage(:,:,2)<uint8(80) & CameraImage(:,:,3)<uint8(80));
  [y2,x2] = find(Isred==1);
 filteredImage(y2,x2,1)=255;
 
//imshow(filteredImage)


  if(size(x1)<>0 & size(x2)<>0) then,
    x1 = round(mean(x1));		//determining the x coordinate of the mean point of the blue patch
    x2 = round(mean(x2));		//determining the x coordinate of the mean point of the red patch
    
    y1 = round(mean(y1));		//determining the y coordinate of the mean point of the blue patch
    y2 = round(mean(y2));		//determining the y coordinate of the mean point of the red patch
    
    meanDistanceFromReference =(x1+x2)/2;
    disp(x1);
    disp(y1);
    disp(x2);
    disp(y2);
  
    if abs(y1-y2)>tolerancePixels_yaxis then,
      if y1>y2 then,
        slSendByte(1,ascii('j'));		// send instruction to rotate left
        disp("rotate left");
      else
        slSendByte(1,ascii('l'));		// send instruction to rotate right
        disp("rotate right");
      end
    elseif  ((abs(meanDistanceFromReference - distanceFromReferenceUpperThreshold) > tolerancePixels_xaxis) & (abs(meanDistanceFromReference - distanceFromReferenceLowerThreshold) > tolerancePixels_xaxis))
      if meanDistanceFromReference > partitioningThreshold  then,
        if meanDistanceFromReference < (distanceFromReferenceUpperThreshold - tolerancePixels_xaxis) then,
          slSendByte(1,ascii('i'));			// send instruction to move forward
          disp("move forward");			
        else
          slSendByte(1,ascii('k'));			// send instruction to move backward
		  
          disp("move backward");
        end
      else 
        if meanDistanceFromReference  < (distanceFromReferenceLowerThreshold - tolerancePixels_xaxis) then,
          slSendByte(1,ascii('i'));			// send instruction to move forward
          disp("move forward");	
        else
          slSendByte(1,ascii('k'));			// send instruction to move backward
          disp("move backward");
        end
      end
    else
      slSendByte(1,ascii('d'));				// send done
      disp("done");
    end
  else
	disp("points not detected.");
  end
  CameraImage=uint8(zeros(rows,cols,3));
  sleep(2000);
end,

  

Task2 Gives as Result the F1, number of Tp and number of pixels on the Foreground for each frame for the two methods A & B.

Function GetNamesImg:
  This function computes all the names of the images in order to be able to open them afterwards. It separates the names between the         methods A or B depending on the name. It needs that the images of the methods A and B are in the same folder.
  
Function GetNamesGT:
  This function computes all the names of the ground truth images in order to be able to open them afterwards.
  
Function BinarizeImg:
  This function binarizes the ground truth images, puting a threshold of 171. Where all the pixels under this threshold are equal to 0 and   all the ones above are equal to 1. This is done in order to be able to compute the comparison between the images of the methods A & B  
  with the groundtruth images.
  
Function CalculateMetrics:
  This function compares an image with the ground truth image. It gives as results the number of pixels that are TP,TN,FP,FN.
  
Function ForeGroundCount:
  This function counts the number of pixels of the method A or B that are part of the foreground.
  
Function CalculateF1:
  This function calculates the F1 coefficient.

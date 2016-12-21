close all;

I=imread('datasets/LKFlow/training/image_0/000157_10.png');
I2=imread('datasets/LKFlow/training/image_0/000157_11.png');
%retrieve GT OF
F2=flow_read('datasets/LKFlow/training/flow_noc/000157_10.png');
F_gt=opticalFlow(F2(:,:,1),F2(:,:,2));
%estimate OF
opticFlow = opticalFlowLK;
flow = estimateFlow(opticFlow,I);
flow2 = estimateFlow(opticFlow,I2);

%show calculated optical flow
figure;
imshow(I2)
    hold on
    plot(flow2,'DecimationFactor',[5 5], 'ScaleFactor',10)
    hold off
%show GT
figure;
imshow(I2)
    hold on
    plot(F_gt,'DecimationFactor',[5 5], 'ScaleFactor',10)
    hold off

   

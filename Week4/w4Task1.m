close all;

I=imread('../datasets/LKFlow/training/image_0/000157_10.png');
I2=imread('../datasets/LKFlow/training/image_0/000157_11.png');

%retrieve GT OF
F2=flow_read('../datasets/LKFlow/training/flow_noc/000157_10.png');
F_gt=opticalFlow(F2(:,:,1),F2(:,:,2));

%estimate OF
opticFlow = opticalFlowLK;
flow = estimateFlow(opticFlow,I);
flow2 = estimateFlow(opticFlow,I2);

[Image,motioni,motionj]=blockMatching(I,I2);

%Plot motion i and motion j with quiver plot
%First, resize Image to the size of the motion i/j
I3=imresize(I,size(motioni));

%then, in order to plot them, you need to make a grid of positions to set
%the velocities at the points
[X Y] = meshgrid(1:size(I3,2),1:size(I3,1));
figure
imshow(I3);
hold on;
quiver(X(:),Y(:),motioni(:),motionj(:),10);
hold off;

% %show calculated optical flow
% figure;
% imshow(I2)
%     hold on
%     plot(flow2,'DecimationFactor',[5 5], 'ScaleFactor',10)
%     hold off
% %show GT
% figure;
% imshow(I2)
%     hold on
%     plot(F_gt,'DecimationFactor',[5 5], 'ScaleFactor',10)
%     hold off
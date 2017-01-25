close all;

I=imread('datasets/LKFlow/training/image_0/000157_10.png');
I2=imread('datasets/LKFlow/training/image_0/000157_11.png');

%retrieve GT OF
GT=flow_read('datasets/LKFlow/training/flow_noc/000157_10.png');
% F_gt=opticalFlow(F2(:,:,1),F2(:,:,2));
% 
% %estimate OF
% opticFlow = opticalFlowLK;
% flow = estimateFlow(opticFlow,I);
%flow2 = estimateFlow(opticFlow,I2);

[Image,motioni,motionj]=blockMatching(I,I2);
comp_of=opticalFlow(motioni,motionj);


figure
imshow(I2);
hold on;
  plot(comp_of,'DecimationFactor',[1 1], 'ScaleFactor',1)
%quiver(X(:),Y(:),motioni,motionj,10);
hold off;

%MSEN
msen_F1= sqrt((motioni-GT(:,:,1)).^2+(motionj-GT(:,:,2)).^2);
msen_F1(~logical(GT(:,:,3)))=0;

figure;
imshow(msen_F1)
figure;
imagesc(msen_F1)
colorbar

msen_F1(~logical(GT(:,:,3)))=-200;
%PEPN
pepn_F1=sum(sum(msen_F1>3))/sum(sum((msen_F1~=-200)))

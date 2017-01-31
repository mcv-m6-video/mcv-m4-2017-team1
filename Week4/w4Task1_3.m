close all;
clear all;
I=imread('datasets/middlebury/images/Dimetrodon/frame10.png');
I2=imread('datasets/middlebury/images/Dimetrodon/frame11.png');

%retrieve GT OF
GT_=readFlowFile('datasets/middlebury/gt/Dimetrodon/flow10.flo');
% adequate OF format to previous used formats
GT(:,:,1)=GT_(:,:,1);
GT(:,:,2)=GT_(:,:,2);
GT(:,:,3)=ones(size(GT(:,:,1)));
GT(GT_(:,:,1)>1e9)=0;
GT(GT_(:,:,2)>1e9)=0;
GT(:,:,3)=~(GT(:,:,1)>1e9 | GT(:,:,2)>1e9);

%Set parameters
block_size=32;
len=20;
disp(['Block size ' num2str(block_size) ' with search length ' num2str(len)])
%Perform block matching
disp('Performing block matching for sequence 157')
[Image,motioni,motionj]=blockMatching(I,I2,block_size,len);
%Convert motion from axes x and y to opticalFlow classes
comp_of=opticalFlow(motioni,motionj);
GT_of=opticalFlow(GT(:,:,1),GT(:,:,2));

%%Metrics

%calculate MSEN
msen= sqrt((motionj-GT(:,:,1)).^2+(motioni-GT(:,:,2)).^2);
msen(~logical(GT(:,:,3)))=0;
%show MSEN
figure;
imagesc(msen)
colorbar
title('MSEN sequence middlebury (Block matching)')
%MMEN and PEPN
msen(~logical(GT(:,:,3)))=-200;
mmen=mean2(msen(msen~=-200));
disp(['MMEN for middlebury sequence (our BM) :' num2str(mmen)])

pepn=sum(sum(msen>3))/sum(sum((msen~=-200)));
disp(['PEPN for middlebury sequence (our BM) :'  num2str(pepn)])


%Other methods
opticFlow = opticalFlowLKDoG;
flow = estimateFlow(opticFlow,I);
flow_LK = estimateFlow(opticFlow,I2);

%%Metrics

%calculate MSEN
msen_LK= sqrt((flow_LK.Vx-GT(:,:,1)).^2+(flow_LK.Vy-GT(:,:,2)).^2);
msen_LK(~logical(GT(:,:,3)))=0;
%show MSEN
figure;
imagesc(msen_LK)
colorbar
title('MSEN sequence middlebury')
%MMEN and PEPN
msen_LK(~logical(GT(:,:,3)))=-200;
mmen_LK=mean2(msen_LK(msen_LK~=-200));
disp(['MMEN for middlebury sequence :' num2str(mmen_LK)])

pepn_LK=sum(sum(msen_LK>3))/sum(sum((msen_LK~=-200)));
disp(['PEPN for middlebury sequence :'  num2str(pepn_LK)])




figure
imshow(I2);
hold on;
plot(GT_of,'DecimationFactor',[ 10 10 ], 'ScaleFactor',2)
hold off
title ('Optical flow sequence Middlebury')

%     figure;
%     imshow(I_45_2);
%     hold on;
%     plot(comp_of_45,'DecimationFactor',[block_size block_size], 'ScaleFactor',2)
%     %quiver(X(:),Y(:),motioni,motionj,10);
%     hold off;
%     title('Optical flow sequence 45')
%     %MSEN



%  bs=10:10:40;
%  figure;
%  for i=1:4
%     plot(bs,mmen_45_vec(i,:))
%     hold on
%     plot(bs,mmen_157_vec(i,:))
%     hold on
%  end
%     hold off
%     title('mmen')
%

%     figure;
%     subplot(1,2,1)
%     for i=1:4
%     plot(bs,pepn_45_vec(:,i)),ylim([0 1])
%     hold on
%     end
%     title('PEPN for sequence 45')
%     subplot(1,2,2)
%     for i=1:4
%     plot(bs,pepn_157_vec(:,i)),ylim([0 1])
%     hold on
%     end
%     title('PEPN for sequence 157')
%     hold off
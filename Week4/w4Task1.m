close all;

I_157=imread('datasets/LKFlow/training/image_0/000157_10.png');
I_157_2=imread('datasets/LKFlow/training/image_0/000157_11.png');

I_45=imread('datasets/LKFlow/training/image_0/000045_10.png');
I_45_2=imread('datasets/LKFlow/training/image_0/000045_11.png');

%retrieve GT OF
GT_157=flow_read('datasets/LKFlow/training/flow_noc/000157_10.png');
GT_45=flow_read('datasets/LKFlow/training/flow_noc/000045_10.png');
ind2=1;

for b=48  
%for b=64
ind=1;
   for l=20
  % for l=20
    block_size=b;
    len=l;
    disp(['Block size ' num2str(block_size) ' with search length ' num2str(len)])
    %Perform block matching
    disp('Performing block matching for sequence 157')
    [Image,motioni,motionj]=blockMatching(I_157,I_157_2,block_size,len);
    disp('Performing block matching for sequence 45')
    [Image_,motioni_,motionj_]=blockMatching(I_45,I_45_2,block_size,len);
    %Convert motion from axes x and y to opticalFlow classes
    comp_of_157=opticalFlow(motioni,motionj);
    comp_of_45=opticalFlow(motioni_,motionj_);
    %comp_gt=opticalFlow(GT(:,:,1),GT(:,:,2));
    
    %LK optical flow
    opticFlow = opticalFlowLK;
    flow = estimateFlow(opticFlow,I_157);
    flow_157_LK = estimateFlow(opticFlow,I_157_2);
    
    opticFlow_ = opticalFlowLK;
    flow_ = estimateFlow(opticFlow_,I_45);
    flow_45_LK = estimateFlow(opticFlow_,I_45_2);
    
    
    figure
    imshow(I_157_2);
    hold on;
    plot(comp_of_157,'DecimationFactor',[block_size block_size], 'ScaleFactor',2)
    hold off
    title ('Optical flow sequence 157')
    
    figure;
    imshow(I_45_2);
    hold on;
    plot(comp_of_45,'DecimationFactor',[block_size block_size], 'ScaleFactor',2)
    %quiver(X(:),Y(:),motioni,motionj,10);
    hold off;
    title('Optical flow sequence 45')
    %MSEN
    msen_F1= sqrt((motionj-GT_157(:,:,1)).^2+(motioni-GT_157(:,:,2)).^2);
    msen_F1(~logical(GT_157(:,:,3)))=0;
    
    msen_F2= sqrt((motionj_-GT_45(:,:,1)).^2+(motioni_-GT_45(:,:,2)).^2);
    msen_F2(~logical(GT_45(:,:,3)))=0;
    
    msen_F1_LK= sqrt((flow_157_LK.Vx-GT_157(:,:,1)).^2+(flow_157_LK.Vy-GT_157(:,:,2)).^2);
    msen_F1_LK(~logical(GT_157(:,:,3)))=0;
    
    msen_F2_LK= sqrt((flow_45_LK.Vx-GT_45(:,:,1)).^2+(flow_45_LK.Vy-GT_45(:,:,2)).^2);
    msen_F2_LK(~logical(GT_45(:,:,3)))=0;
    
    figure;
    subplot(1,2,2)
    imagesc(msen_F1)
    colorbar
    title('MSEN sequence 157')
    subplot(1,2,1)
    imagesc(msen_F2)
    colorbar
    title('MSEN sequence 45')
    msen_F1(~logical(GT_157(:,:,3)))=-200;
    msen_F2(~logical(GT_45(:,:,3)))=-200;
    msen_F1_LK(~logical(GT_157(:,:,3)))=-200;
    msen_F2_LK(~logical(GT_45(:,:,3)))=-200;
    %PEPN
    mmen_157=mean2(msen_F1(msen_F1~=-200));
    disp(['MMEN for sequence 157 :' num2str(mmen_157)])
    mmen_157_LK=mean2(msen_F1_LK(msen_F1_LK~=-200));
  %  disp(['MMEN for sequence 157 LK :'  num2str(mmen_157_LK)])
    mmen_45=mean2(msen_F2(msen_F2~=-200));
   disp(['MMEN for sequence 45 :'  num2str(mmen_45)])
    mmen_45_LK=mean2(msen_F2_LK(msen_F2_LK~=-200));
   % disp(['MMEN for sequence 45 LK :'  num2str(mmen_45_LK)])
    
    pepn_F1=sum(sum(msen_F1>3))/sum(sum((msen_F1~=-200)));
    pepn_F2=sum(sum(msen_F2>3))/sum(sum((msen_F2~=-200)));
    pepn_F1_LK=sum(sum(msen_F1_LK>3))/sum(sum((msen_F1_LK~=-200)));
    pepn_F2_LK=sum(sum(msen_F2_LK>3))/sum(sum((msen_F2_LK~=-200)));
    disp(['PEPN for sequence 157 :'  num2str(pepn_F1)])
    %disp(['PEPN for sequence 157 LK :'  num2str(pepn_F1_LK)])
    disp(['PEPN for sequence 45 :'  num2str(pepn_F2)])
    %disp(['PEPN for sequence 45 LK :'  num2str(pepn_F2_LK)])
    mmen_45_vec(ind2,ind)=mmen_45;
    mmen_157_vec(ind2,ind)=mmen_157;
    
    pepn_45_vec(ind2,ind)=pepn_F1;
    pepn_157_vec(ind2,ind)=pepn_F2;
    ind=ind+1;
    end
    ind2=ind2+1;
end


bs=8:8:64;
figure;
subplot(1,2,1)
for i=1:5
    plot(bs,mmen_45_vec(:,i))
    hold on
end
legend('Search area 20','Search area 40', 'Search area 60', 'Search area 80','Search area 100')
xlabel('Block size')
ylabel('MMEN')
title('MMEN for sequence 45')
subplot(1,2,2)
for i=1:5
    hold on
    plot(bs,mmen_157_vec(:,i))
    hold on
end
legend('Search area 20','Search area 40', 'Search area 60', 'Search area 80','Search area 100')
xlabel('Block size')
ylabel('MMEN')
hold off
title('MMEN for sequence 157')



figure;
subplot(1,2,1)
for i=1:5
    plot(bs,pepn_45_vec(:,i)),ylim([0 1])
    hold on
end
legend('Search area 20','Search area 40', 'Search area 60', 'Search area 80','Search area 100')
xlabel('Block size')
ylabel('PEPN')
title('PEPN for sequence 45')
subplot(1,2,2)
for i=1:5
    plot(bs,pepn_157_vec(:,i)),ylim([0 1])
    hold on
end
legend('Search area 20','Search area 40', 'Search area 60', 'Search area 80','Search area 100')
xlabel('Block size')
ylabel('PEPN')
title('PEPN for sequence 157')

hold off
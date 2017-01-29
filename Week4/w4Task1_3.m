close all;

I=imread('datasets/middlebury/images/Dimetrodon/frame10.png');
I2=imread('datasets/middlebury/images/Dimetrodon/frame11.png');

%retrieve GT OF
GT=readFlowFile('datasets/middlebury/gt/Dimetrodon/flow10.flo');
ind2=1;
for b=10:10:40  
ind=1;
    for l=20:10:50
    block_size=b;
    len=l;
    disp(['Block size ' num2str(block_size) ' with search length ' num2str(len)])
    %Perform block matching
    disp('Performing block matching for sequence 157')
    [Image,motioni,motionj]=blockMatching(I,I2,block_size,len);
     %Convert motion from axes x and y to opticalFlow classes
    comp_of=opticalFlow(motioni,motionj);
     
  
    
    figure
    imshow(I2);
    hold on;
    plot(comp_of,'DecimationFactor',[block_size block_size], 'ScaleFactor',2)
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
    msen_F1= sqrt((motioni-GT(:,:,1)).^2+(motionj-GT(:,:,2)).^2);
    msen_F1(~logical(GT(:,:,3)))=0;
     
    figure;
    imagesc(msen_F1)
    colorbar
    title('MSEN sequence middlebury')
    msen_F1(~logical(GT_157(:,:,3)))=-200;
    %PEPN
    mmen_157=mean2(msen_F1(msen_F1~=-200));
   % disp(['MMEN for sequence 157 :' num2str(mmen_157)])
    
    pepn_F1=sum(sum(msen_F1>3))/sum(sum((msen_F1~=-200)));
    %disp(['PEPN for sequence 157 :'  num2str(pepn_F1)])

    end
end


 bs=10:10:40;
 figure;
 for i=1:4
    plot(bs,mmen_45_vec(i,:))
    hold on
    plot(bs,mmen_157_vec(i,:))
    hold on
 end
    hold off
    title('mmen')
    
    
    figure;
    subplot(1,2,1)
    for i=1:4
    plot(bs,pepn_45_vec(:,i)),ylim([0 1])
    hold on
    end
    title('PEPN for sequence 45')
    subplot(1,2,2)
    for i=1:4
    plot(bs,pepn_157_vec(:,i)),ylim([0 1])
    hold on
    end
    title('PEPN for sequence 157')
    hold off
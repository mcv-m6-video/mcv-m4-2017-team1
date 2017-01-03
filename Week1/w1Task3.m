close all;

F1=flow_read('datasets/LKflow/training/flow_noc/000045_10.png');
F1_c=flow_read('results/LKflow/LKflow_000045_10.png');
F2=flow_read('datasets/LKflow/training/flow_noc/000157_10.png');
F2_c=flow_read('results/LKflow/LKflow_000157_10.png');


msen_F1= sqrt((F1_c(:,:,1)-F1(:,:,1)).^2+(F1_c(:,:,2)-F1(:,:,2)).^2);
msen_F2= sqrt((F2_c(:,:,1)-F2(:,:,1)).^2+(F2_c(:,:,2)-F2(:,:,2)).^2);

%set 0 as the value for non-valid motion vectors (to avoid a negative
%effect on the colormap)
msen_F1(~logical(F1(:,:,3)))=0;
msen_F2(~logical(F2(:,:,3)))=0;

figure;
imshow(msen_F1)
figure;
imagesc(msen_F1)
colorbar
figure;
imshow(msen_F2)
figure;
imagesc(msen_F2)
colorbar


%set -200 as the value for non-valid motion vectors (to avoid negative
%visualization effect on the histogram computation)
msen_F1(~logical(F1(:,:,3)))=-200;
msen_F2(~logical(F2(:,:,3)))=-200;
% normalized histograms of MSE errors excluding non-valid motion vectors
for i=1:2
        if i==1
            msen=msen_F1;
        else 
            msen=msen_F2;
        end
figure;
 v_msen=reshape(msen,[numel(msen),1]);
[counts,centers]=hist(double(v_msen),200);

%do not consider -200 as a valid value
counts=counts(centers>=0);
centers=centers(centers>=0);
counts=counts/sum(counts);
%plot error histograms
bar(centers,counts,'b')
xlabel('MSEN')
ylabel('Percentage of pixels')
title('Histogram of errors')

end

%PEPN measures
disp('MSEN for sequence 45')
mean2(msen_F1(msen_F1~=-200))
disp('MSEN for sequence 157')
mean2(msen_F2(msen_F2~=-200))
disp('PEPN for sequence 45')
pepn_F1=sum(sum(msen_F1>3))/sum(sum((msen_F1~=-200)))
disp('PEPN for sequence 157')
pepn_F2=sum(sum(msen_F2>3))/sum(sum((msen_F2~=-200)))

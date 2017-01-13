function [TP,FP,TN,FN] = computePerformance(labelImage, testImage)

TP = nnz(labelImage.*testImage==1); %TP = 1 in label, 1 test image
FP = nnz((labelImage-testImage)==-1); %FP = 0 in label, 1 test image
TN = nnz(~(labelImage+testImage)); %TN = 0 in label, 0 test image
FN = nnz((testImage-labelImage)==-1); %FN = 1 in label, 0 test image

end


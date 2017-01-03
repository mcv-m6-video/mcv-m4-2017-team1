function [TP,FP,TN,FN] = computeTP(GT, img)
TP=0;
TN=0;
FP=0;
FN=0;
for j=1:size(GT,1)
    for k=1:size(GT,2)
        if img(j,k)==1 && GT(j,k)==1
            TP=TP+1;
        elseif img(j,k)==0 && GT(j,k)==0
            TN=TN+1;
        elseif img(j,k)==1 && GT(j,k)==0
            FP=FP+1;
        elseif img(j,k)==0 && GT(j,k)==1
            FN=FN+1;
        end
    end
end
end
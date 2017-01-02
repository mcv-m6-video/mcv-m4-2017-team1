function [TP,FP,TN,FN] = computePerformanceHalf(TestDirectory, Image, i)

%Store the information from the directories (#images, names...)
FilesGT = dir(strcat(TestDirectory, '*png'));
GTImage = (imread(strcat(TestDirectory, FilesGT(i).name)));
for j=1:size(GTImage,1)
    for k=1:size(GTImage,2)
        if GTImage(j,k)< 60
            GTImage(j,k)=0;
        elseif GTImage(j,k)==255
            GTImage(j,k)=1;
        else
            GTImage(j,k)=-200;
        end
    end
end


[TP,FP,TN,FN] = computeTP(Image, GTImage);

end
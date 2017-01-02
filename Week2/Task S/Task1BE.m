clc;
clear all;
close all;
GTDirectory = '../datasets/fall/groundtruth/';
InputDirectory = '../datasets/fall/input/';

FilesInput = dir(strcat(InputDirectory, '*jpg'));
FilesGT= dir(strcat(GTDirectory, '*png'));

for i=1:((length(FilesInput)/2)) %read all images of the frame
    Input = (imread(strcat(InputDirectory, FilesInput(i).name))); 
    InputImage{i}=rgb2gray(Input);
end

for i=1:((length(FilesInput)/2))  %Read al Ground truth files of the frame
    GT = (imread(strcat(GTDirectory, FilesGT(i).name)));
    for j=1:size(GT,1)
        for k=1:size(GT,2)              %Convert GT in binary with Threshold
            if GT(j,k) == 50 || GT(j,k)==0
                GT(j,k)=1;
            else
                GT(j,k)=0;
            end
        end
    end
    GTImage{i}=GT;
end

val=0;
n=0;
for i=1:size(InputImage{1},1)
    for j=1:size(InputImage{1},2)
        for k=1:(length(FilesInput)/2)
            FinalImage=((GTImage{k}).*(InputImage{k}));   %Take into account only Background of the image
            if FinalImage(i,j) == 0
            else
            val(k)=FinalImage(i,j); %Store all the values for the pixel i,j of all the frames
            n=n+1;
            end
        end
        mean(i,j)=(sum(sum(val)))/n;  %Make the mean of the values of the pixel i,j
        stdeviation(i,j)= std2(val);  %Calculate the deviation
        val=0;
        n=0;
        %i
        %j
    end
end
           

for alpha=1:10
    r=1;
    for i=round(length(FilesInput)/2):length(FilesInput)
        InputImage = (imread(strcat(InputDirectory, FilesInput(i).name)));
        InputImage=rgb2gray(InputImage);
        for j=1:size(InputImage,1)
            for k=1:size(InputImage,2)
                if InputImage(j,k)<mean(j,k)
                    Image(j,k)=mean(j,k)-InputImage(j,k);
                else
                    Image(j,k)=InputImage(j,k)-mean(j,k);
                end
                if abs(Image(j,k))>=(alpha*(stdeviation(j,k)+2))
                    Image(j,k)=1;
                else
                    Image(j,k)=0;
                end
            end
        end
        [TP(i),FP(i),TN(i),FN(i)] = computePerformanceHalf(GTDirectory, Image, i);
        %Compute metrics from the total TP,FP,TN and FN of the sequence
        [precision(i),recall(i),~,FMeasure(i)] = computeMetrics(TP(i),FP(i),TN(i),FN(i));
        
    end
    Ftot{alpha}=FMeasure;
    Ptot{alpha}=precision;
    Rtot{alpha}=recall;
    TPtot{alpha}=TP;
    FPtot{alpha}=FP;
    TNtot{alpha}=TN;
    FNtot{alpha}=FN;
    %alpha
end
    

    
    
    
    
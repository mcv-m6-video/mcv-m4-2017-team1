clc;
close all;

%Directories of original images, Test and ground truth
InputDirectory = 'datasets/traffic/reduced_input/';
%TestDirectory = '../results/highway/testA/';
GTDirectory = '../datasets/highway/reducedGT/';

video = 0; %Decide to save a video with the background substraction result
adaptive = 0; % Adaptive background substraction
%Store the information from the directories (#images, names...)
FilesInput = dir(strcat(InputDirectory, '*jpg'))
%FilesTest = dir(strcat(TestDirectory, '*png'));
FilesGT = dir(strcat(GTDirectory, '*png'));

%Get sequence lenght
NFrames = length(FilesInput)
%Initialize variables
%FMeasure = zeros(1,NFrames);
%TP = zeros(1,NFrames);
%FG = zeros(1,NFrames);


pixelMean=[];
pixelStd=[];
all_frames=zeros(240,320,NFrames);
figure;
for i = 1:round(NFrames/2)
    
    %Read input image
    realImage = rgb2gray(imread(strcat(InputDirectory, FilesInput(i).name)));
    all_frames(:,:,i)=double(realImage);
  %  imshow(realImage)
  %  imshow(realImage);
    %Only show one of the plots as they are updated in real time
    if video==0
        %Plot results
   %     figure(1)
   %     ax1 = subplot(1,2,1);
%        plot(1:i,TP(1:i),1:i,FG(1:i)); axis([0 200 0 12000]); 
 %       xlabel(ax1,'#frame'); ylabel(ax1,'Number of pixels'); 
  %      drawnow();

    %    ax2 = subplot(1,2,2);
     %   plot(1:i,FMeasure(1:i)); axis([0 200 0 1]); 
      %  xlabel(ax2,'#frame'); ylabel(ax2,'F Measure'); drawnow();
  
    end

end
pixelMean=mean(all_frames,3);
pixelStd=std(all_frames,0,3);
figure;
subplot(1,2,1)
imshow(uint8(pixelMean));
title('Mean')
subplot(1,2,2)
imshow(uint8(pixelStd));
title('Std')

alpha=1;
rho=0;
result=[];
figure;
for i = round(NFrames/2)+1: NFrames
    realImage = rgb2gray(imread(strcat(InputDirectory, FilesInput(i).name)));
    result=abs(double(realImage)-double(pixelMean))>= alpha* (double(pixelStd)+2);
    
    %Read and binarize groundtruth image
    gtImage = double(imread(strcat(GTDirectory, FilesGT(i).name))) >= 170; 

    subplot(1,2,1)
    imshow(realImage)
    subplot(1,2,2)
    imshow(result);
    drawnow();
    
    if adaptive == 1
        realImage=double(realImage);
        pixelMean(~logical(result))=rho*realImage(~logical(result)) + (1-rho)*pixelMean(~logical(result));
        pixelStd(~logical(result))=sqrt(rho*(realImage(~logical(result))-pixelMean(~logical(result))).^2 + (1-rho)*pixelStd(~logical(result)).^2);
    end
    
end


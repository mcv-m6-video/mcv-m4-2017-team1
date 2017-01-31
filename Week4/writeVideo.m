v = VideoWriter('trafficSeq.avi');
open(v)

FilesInput = dir('datasets/traffic/input/*jpg');
iniFrame = 950;
endFrame = 1050;

for i = iniFrame:endFrame
    writeVideo(v,imread(strcat(FilesInput(i).folder,'/',FilesInput(i).name)))
end
close(v)
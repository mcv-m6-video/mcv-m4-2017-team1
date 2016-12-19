clc;
clearvars;
dirnameGT='../highway/groundtruth';
GroundTruth=dir(fullfile([dirnameGT '/'],'*.png')); % Get all .png files
dirnameAB='../results_testAB_changedetection/results/highway';
AB=dir(fullfile([dirnameAB '/'],'*.png')); % Get all .png files
j=1;
k=1;
for i=1:length(AB)
     toSplitAB = strsplit(AB(i).name,{'test_','.png'});
     TypeofTest=toSplitAB{1,2}(1);
     if TypeofTest=='A'
         NamesA{j}=AB(i).name;
         j=j+1;
     elseif TypeofTest=='B'
         NamesB{k}=AB(i).name;
         k=k+1;
     end
end

for i=1:length(GroundTruth)
    toSplitGT = strsplit(GroundTruth(i).name,{'gt.','.png'});
    TypeofGT = toSplitGT{1,1}(5:6);
    if (TypeofGT == '12') || (TypeofGT== '13') || (TypeofGT == '14')
        NamesGT{i}=GroundTruth(i).name;
    end
end




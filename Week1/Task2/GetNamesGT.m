function [NamesGT] = GetNamesGT (GroundTruth)
o=1;
for i=1:length(GroundTruth)
    toSplitGT = strsplit(GroundTruth(i).name,{'gt.','.png'});
    TypeofGT = toSplitGT{1,1}(5:6);
    if (TypeofGT == '12') 
        NamesGT{o}=GroundTruth(i).name;
        o=o+1;
    elseif (TypeofGT== '13')
        NamesGT{o}=GroundTruth(i).name;
        o=o+1;
    elseif (TypeofGT == '14')
        NamesGT{o}=GroundTruth(i).name;
        o=o+1;
    end
end

end
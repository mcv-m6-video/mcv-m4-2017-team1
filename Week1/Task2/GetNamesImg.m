function [NamesA, NamesB] = GetNamesImg (AB)
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
end
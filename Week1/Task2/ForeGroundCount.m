function [TotalFor] = ForeGroundCount (img)
TotalFor=0;
for i=1:size(img,1)
    for j=1:size(img,2)
        if img(i,j)==1
            TotalFor=TotalFor + 1;
        end
    end
end

end
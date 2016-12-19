function [GT] = BinarizeImg (img)

for j=1:size(img,1)
    for k=1:size(img,2)
        if img(j,k)>171
            GT(j,k)=1;
        else
            GT(j,k)=0;
        end
    end
end



end
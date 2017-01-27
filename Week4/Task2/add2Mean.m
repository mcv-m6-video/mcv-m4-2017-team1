function newMean = add2Mean(mean, newValue, newN, mask)

%Compute the mean when adding a new element
newMean = mean + (newValue - mean)./newN;

%Put to 0 those values that are Inf or NaN (if the mean is divided by
%0 or is 0/0)
newMean(isinf(newMean)) = 0;
newMean(isnan(newMean)) = 0;

%Set the new mean only on those pixels that are background
newMean = newMean.*mask + mean.*~mask;

end
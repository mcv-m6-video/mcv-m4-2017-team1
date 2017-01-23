function [energy] = computeEnergy(block1, block2)

energy = sum(sum((block1-block2).^2));

end
function [error] = computeError(block1, block2)

error = sum(sum((block1-block2).^2));

end
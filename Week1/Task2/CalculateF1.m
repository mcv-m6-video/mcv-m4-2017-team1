function [F1] = CalculateF1 (TP,FP,FN)

Precision= TP/(TP+FP);
Recall = TP/(TP+FN);

F1=2*Precision*Recall/(Precision+Recall);


end


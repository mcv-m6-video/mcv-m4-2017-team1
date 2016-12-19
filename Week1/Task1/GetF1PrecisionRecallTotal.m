function [F1,Precision,Recall] = GetF1PrecisionRecallTotal (TP,TN,FP,FN)

Precision=TP/(TP+FN);
Recall=TP/(TP+FP);
F1=2*Precision*Recall/(Precision+Recall);

end
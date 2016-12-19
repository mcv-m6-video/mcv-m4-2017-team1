# -*- coding: utf-8 -*-
"""
Created on Sun Dec 18 11:35:46 2016

@author: media
"""

import os
import shutil
import subprocess
import cv2
import numpy as np
import matplotlib.pyplot as plt
import cPickle
from sklearn.preprocessing import StandardScaler
from sklearn import svm
from sklearn.decomposition import PCA

#Calculate TP,FP,TN,FN
def ComparisonImage(IGT, I):
    FP=0
    TP=0
    TN=0
    FN=0
    for j in range (len(IGT)):
        for k in range (len(IGT[0])):
            if (IGT[j][k]==0 and I[j][k]==0):
                TN=TN+1
            elif (IGT[j][k]==1 and I[j][k]==1):
                TP=TP+1
            elif (IGT[j][k]==0 and I[j][k]==1):
                FP=FP+1
            elif (IGT[j][k]==1 and I[j][k]==0):
                FN=FN+1
    
    return TP, FP, TN, FN
    

    
#Calculate Precision, Recall and F1   
def EvaluationMetrics(Results):
    TPtotal=0
    FPtotal=0
    TNtotal=0
    FNtotal=0
    for i in range (len(Results)):
        TPtotal=TPtotal+Results[i][0]
        FPtotal=FPtotal+Results[i][1]
        TNtotal=TNtotal+Results[i][2]
        FNtotal=FNtotal+Results[i][3]
    
    Precision=TPtotal/float(TPtotal+FPtotal)
    Recall=TPtotal/float(TPtotal+FNtotal)
    F1=2*Precision*Recall/float(Precision+Recall)
    
    return Precision, Recall, F1


    
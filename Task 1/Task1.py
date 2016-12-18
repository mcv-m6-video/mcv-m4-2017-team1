# -*- coding: utf-8 -*-
"""
Created on Sat Dec 17 10:55:22 2016

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

import functions

Anames=[]
Bnames=[]  
GTnames=[]
ResultsA=[]
ResultsB=[]

binaryRootPath = '../results_testAB_changedetection/results/highway'
names=os.listdir(binaryRootPath)

GroundTruthPath= '../highway/groundtruth'
namesGT=os.listdir(GroundTruthPath)


for i in range(len(namesGT)):
    prueba1=namesGT[i] 
    for j in range(len(names)):
        prueba2=names[j]
        if (prueba1[4:8]==prueba2[9:13] and prueba2[5]=='A'):   #evitar copiar dos veces los nombres
            GTnames.append(namesGT[i])
            
for j in range(len(names)):
    prueba2=names[j]
    if (prueba2[5] == 'A'):
        Anames.append(names[j])
    elif (prueba2[5] =='B'):
        Bnames.append(names[j])

        
            
for i in range(len(Anames)):                
    imgA=binaryRootPath+'/'+Anames[i]
    IA=cv2.imread(imgA)
    IA=cv2.cvtColor(IA,cv2.COLOR_BGR2GRAY)
    imgB=binaryRootPath+'/'+Bnames[i]
    IB=cv2.imread(imgB)
    IB=cv2.cvtColor(IB,cv2.COLOR_BGR2GRAY)

    imgGT=GroundTruthPath+'/'+GTnames[i]
    IGT=cv2.imread(imgGT)               #abrir las ground truth y aplicar
    I=cv2.cvtColor(IGT,cv2.COLOR_BGR2GRAY)#threshold para eliminar zonas no interesantes
    ret,IBW=cv2.threshold(I,171,1,cv2.THRESH_BINARY)

    TPA, FPA, TNA, FNA = functions.ComparisonImage(IBW,IA) #Comparacion Imagenes
    TPB, FPB, TNB, FNB = functions.ComparisonImage(IBW,IB)
    
    ResultsA.append([TPA, FPA, TNA, FNA])
    ResultsB.append([TPB, FPB, TNB, FNB])

    #leer las imagenes, un range de todos los pixel de la imagen, probar sklearn a ver que hace


PrecisionA, RecallA, F1A = functions.EvaluationMetrics(ResultsA)  
PrecisionB, RecallB, F1B = functions.EvaluationMetrics(ResultsB)

 
#cv2.imshow('Lena',IGT)

#k=cv2.waitKey(0)
        
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




call = subprocess.call

Anames=[]
Bnames=[]  
GTnames=[]

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
    imgA=binaryRootPath+'/'+Anames[0]
    IA=cv2.imread(imgA)
    imgB=binaryRootPath+'/'+Bnames[0]
    IB=cv2.imread(imgB)
    imgGT=GroundTruthPath+'/'+GTnames[0]
    IGT=cv2.imread(imgGT)
    height, width, channels = IGT.shape
    for j in range

    #leer las imagenes, un range de todos los pixel de la imagen, probar sklearn a ver que hace

    
cv2.imshow('Lena',IGT)

k=cv2.waitKey(0)
        
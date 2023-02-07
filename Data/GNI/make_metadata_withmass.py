#!/usr/bin/python

import sys
import numpy as np
import matplotlib.pyplot as plt


N_args = len(sys.argv)
inputs = sys.argv
filename = inputs[1]

print (filename)
    

meta = open("metadata_mass.csv", "a")
     
# load data
hist = np.loadtxt(filename, delimiter='=',  dtype=str, skiprows=29, max_rows=19)

label = filename.split("/",1)[1]
meta.write(label + ",")

for n in range(len(hist)):
        if n+1 == len(hist):
    	    meta.write(str(hist[n][1] + ","))
        else:
            meta.write(str(hist[n][1] + ","))
    
        
meta.close()









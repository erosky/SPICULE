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
hist = np.loadtxt(filename, dtype=str, skiprows=192, max_rows=1)

mass=hist[5]
meta.write(str(mass) + "\n")
    
        
meta.close()

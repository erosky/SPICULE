#!/usr/bin/python

import sys
import numpy as np
import matplotlib.pyplot as plt



# For each hist file

N_args = len(sys.argv)
inputs = sys.argv
filename = inputs[1]

print (filename)
    

# make new csv file
outputfile = filename + ".csv"
csv = open(outputfile, "w")
     
# write header
csv.write("Bin,Lower limit (um),Mid point (um),Upper limit (um),Good=1 Bad=0 flag,Concentration (#/m**3)\n")
     
# load data
hist = np.loadtxt(filename, skiprows=94, max_rows=97)

for row in hist:
    for n in range(len(row)):
        if n+1 == len(row):
    	    csv.write(str(row[n]))
        else:
            csv.write(str(row[n]) + ",")
    csv.write("\n")
     
         
csv.close()





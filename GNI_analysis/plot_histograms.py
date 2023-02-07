import numpy as np
import matplotlib.pyplot as plt


# For each hist file

import os

directory = os.fsencode('spicule_histograms')
    
lats = []
lons = []
mass_load = [] 

meta = open("metadata.csv", "a")
meta.write("slide label, Flight number, Slide exposure date (yymmdd), Slide number within the flight, Slide begin exposure (hhmmss.s), Slide end exposure (hhmmss.s), Slide exposure duration (s), Slide exposure sample volume (m**3), Slide exposure average GPS altitude (m), Slide exposure minimum GPS altitude (m), Slide exposure maximum GPS altitude (m), Slide exposure average pressure (hpa), Slide exposure average temperature (C),")
f.close()   

for file in os.listdir(directory):
     filename = os.fsdecode(file)
     outputfile = filename + ".csv"
     f = open("demofile2.txt", "a")
     f.write("Now the file has more content!")
     f.close()
     # load longitudinal data
     f='spicule_histograms/'+str(filename)
     meta = np.loadtxt(f, delimiter='=',  dtype=str, skiprows=30, max_rows=18)
     lat = float(meta[16][1])
     lon = float(meta[15][1])
     lats.append(lat)
     lons.append(lon)
     # load mass loading
     #mass = np.loadtxt(f,  dtype=str, skiprows=192, max_rows=1)
     #print(mass[5])
     #mass_load.append(float(mass[5]))
     continue

print(len(lats))
print(len(mass_load))








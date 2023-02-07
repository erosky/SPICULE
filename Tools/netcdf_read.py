#!/usr/bin/python

### Reading ncdf in python ###
# Original code from Susanne Glienke, modified by Elise Rosky

# This is an example on how we read a ncdf-file of our meteorological data (IWG). Some of the columns had to be renamed to match other formats.

# It opens the file (xr.open_dataset(filename)) and converts it into a dataframe, which we then use.
# Helpful is also:
# IWG = xr.open_dataset(filename)
# print(IWG.info())
# which gives you all the info of the ncdf file, since you don't know the variables beforehand. But generally, python can read ncdf files easily.



import sys
import numpy as np
from netCDF4 import Dataset
import xarray as xr
import pandas as pd
import time

## Time conversion functions

def UTC2sec(utc_string):
	utc=utc_string.split(':')
	seconds=3600*int(utc[0]) + 60*int(utc[1]) + int(utc[2])
	return seconds
	
def sec2UTC(seconds):
	utc_string=time.strftime('%H:%M:%S', time.gmtime(seconds))
	return utc_string	



print ('Number of arguments:', len(sys.argv), 'arguments.')
print ('Argument List:', str(sys.argv))


if (len(sys.argv)==1):
	print('python3 netcdf_read.py filename [start-time-UTC end-time-UTC variable1 variable2 ...]')
	
if (len(sys.argv)==2):
	print('printing file info')
	filename = sys.argv[1]
	if filename.endswith('.nc'):
		all_data = Dataset(filename)
		print(all_data.variables.keys())
		print('\n')
		print('time start and end:\n')
		print(sec2UTC(all_data.variables['Time'][0]))
		print(sec2UTC(all_data.variables['Time'][-1]))
		print(all_data.variables['Time'])
	else:
		print('Please choose a supported file format!')

if (len(sys.argv)>2):
	print('printing data to txt file')
	filename = sys.argv[1]
	start = sys.argv[2]
	end = sys.argv[3]
	variables = sys.argv[4:]
	
	if filename.endswith('.nc'):
		all_data = Dataset(filename)
		
		# convert input times to seconds
		start_sec = UTC2sec(start)
		end_sec = UTC2sec(end)
		
		# get info of variables
		for var in variables:
			print(all_data.variables[var])
			
		# load into data structure
		start_date = all_data.variables['Time'].units[14:24]
		
		data = []
		for i, timestamp in enumerate(all_data.variables['Time']):
			if (start_sec<=timestamp and end_sec>=timestamp):
				data_array = [timestamp, sec2UTC(timestamp)]
				for var in variables:
					data_array.append(all_data.variables[var][i])
				data.append(data_array)
		
		output = input("Enter output filename (including extension): ")
		f = open(output, "w")
		for row in data:
			row_str = ''
			for column in row:
				row_str = row_str + str(column) + '\t'
			f.write(row_str + '\n')
		f.close()
		
	else:
 		print('Please choose a supported file format!')

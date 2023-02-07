#!/bin/bash

for FILE in spicule_histograms/*
do
	if [ "${FILE: -4}" == ".csv" ]
	then
		echo $FILE
		N=0
		# Plot and save Pot Energy
		gnuplot -e "set terminal png size 1000,600; \
            	set output 'quick_plots/$N.png'; \
           	 set ylabel 'size (um)'; \
           	 set xlabel 'Concentration (#/m**2)'; \
           	 set key autotitle columnhead; \
            	set style data lines; \
            	plot '$FILE' using 3:6"
            	((N=N+1))
	fi
done



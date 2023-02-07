#!/bin/bash

for FILE in spicule_histograms/*
do
	if [ "${FILE: -4}" != ".csv" ]
	then
		echo $FILE
		python3 make_csv_files.py $FILE
	fi
done



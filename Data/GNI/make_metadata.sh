#!/bin/bash

touch metadata.csv
> metadata.csv

echo "slide label,Flight number,Slide exposure date (yymmdd),Slide number within the flight,Slide begin exposure (hhmmss.s),Slide end exposure (hhmmss.s),Slide exposure duration (s),Slide exposure sample volume (m**3),Slide exposure average GPS altitude (m),Slide exposure minimum GPS altitude (m),Slide exposure maximum GPS altitude (m),Slide exposure average pressure (hpa),Slide exposure average temperature (C),Slide exposure average dewpoint temp. (C),Slide exposure average rel. hum. (%),Slide exposure average wind speed (m/s),Slide exposure average wind direction (deg),Slide exposure average longitude (deg.decimal),Slide exposure average latitude (deg.decimal),Ranz-Vong 50% coll-eff radius (m)" > metadata.csv 

for FILE in spicule_histograms/*
do
	if [ "${FILE: -4}" != ".csv" ]
	then
		echo $FILE
		python3 make_metadata.py $FILE
	fi
done



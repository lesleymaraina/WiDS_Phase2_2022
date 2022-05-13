#!/bin/bash

# AQI
#-------

for f in /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/AQI_WiDS_Analysis/WiDS_aqi*.csv
do 
	base=${f#*/Volumes/Lesley_Chapman/WiDS/2022/EPA/data/AQI_WiDS_Analysis/WiDS_aqi_}; name=${base%*.csv}
	tail -n +2 $f | tr -d \"  > /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/AQI_WiDS_Analysis/"tmp_"$name".csv"
done

cat /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/AQI_WiDS_Analysis/tmp*.csv > /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/AQI_WiDS_Analysis/WiDS_aqi_1980_2021.csv

cat /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/AQI_WiDS_Analysis/aqi_hdr.csv /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/AQI_WiDS_Analysis/WiDS_aqi_1980_2021.csv > /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/AQI_WiDS_Analysis/tmp.csv && mv /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/AQI_WiDS_Analysis/tmp.csv /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/AQI_WiDS_Analysis/WiDS_aqi_1980_2021.csv

rm /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/AQI_WiDS_Analysis/tmp*

# Ozone
#-------
for f in /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/Ozone_WiDS_Analysis/WiDS_ozone*.csv
do 
	base=${f#*/Volumes/Lesley_Chapman/WiDS/2022/EPA/data/Ozone_WiDS_Analysis/WiDS_ozone_}; name=${base%*.csv}
	tail -n +2 $f | tr -d \"  > /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/Ozone_WiDS_Analysis/"tmp_"$name".csv"
done

cat /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/Ozone_WiDS_Analysis/tmp*.csv > /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/Ozone_WiDS_Analysis/WiDS_ozone_1980_2021.csv

cat /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/Ozone_WiDS_Analysis/ozone_hdr.csv /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/Ozone_WiDS_Analysis/WiDS_ozone_1980_2021.csv > /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/Ozone_WiDS_Analysis/tmp.csv && mv /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/Ozone_WiDS_Analysis/tmp.csv /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/Ozone_WiDS_Analysis/WiDS_ozone_1980_2021.csv

rm /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/Ozone_WiDS_Analysis/tmp*

#Make a header file
#head -n1 /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/Ozone_WiDS_Analysis/WiDS_ozone_1980.csv | tr -d \"  > /Volumes/Lesley_Chapman/WiDS/2022/EPA/data/Ozone_WiDS_Analysis/ozone_hdr.csv
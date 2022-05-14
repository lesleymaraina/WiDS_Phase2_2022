#!/bin/bash

# AQI
#-------

for f in[path]/data/AQI_WiDS_Analysis/WiDS_aqi*.tsv
do 
	base=${f#*[path]/AQI_WiDS_Analysis/WiDS_aqi_}; name=${base%*.tsv}
	tail -n +2 $f | tr -d \"  >[path]/data/AQI_WiDS_Analysis/"tmp_"$name".tsv"
done

cat[path]/data/AQI_WiDS_Analysis/tmp*.tsv >[path]/data/AQI_WiDS_Analysis/WiDS_aqi_1980_2021.tsv

cat[path]/data/AQI_WiDS_Analysis/aqi_hdr.tsv[path]/data/AQI_WiDS_Analysis/WiDS_aqi_1980_2021.tsv >[path]/data/AQI_WiDS_Analysis/tmp.tsv && mv[path]/data/AQI_WiDS_Analysis/tmp.tsv[path]/data/AQI_WiDS_Analysis/WiDS_aqi_1980_2021.tsv

rm[path]/data/AQI_WiDS_Analysis/tmp*

# Ozone
#-------
for f in[path]/data/Ozone_WiDS_Analysis/WiDS_ozone*.tsv
do 
	base=${f#*[path]/Ozone_WiDS_Analysis/WiDS_ozone_}; name=${base%*.tsv}
	tail -n +2 $f | tr -d \"  >[path]/data/Ozone_WiDS_Analysis/"tmp_"$name".tsv"
done

cat[path]/data/Ozone_WiDS_Analysis/tmp*.tsv >[path]/data/Ozone_WiDS_Analysis/WiDS_ozone_1980_2021.tsv

cat[path]/data/Ozone_WiDS_Analysis/ozone_hdr.tsv[path]/data/Ozone_WiDS_Analysis/WiDS_ozone_1980_2021.tsv >[path]/data/Ozone_WiDS_Analysis/tmp.tsv && mv[path]/data/Ozone_WiDS_Analysis/tmp.tsv[path]/data/Ozone_WiDS_Analysis/WiDS_ozone_1980_2021.tsv

rm[path]/data/Ozone_WiDS_Analysis/tmp*

#Make a header file
#head -n1[path]/data/Ozone_WiDS_Analysis/WiDS_ozone_1980.tsv | tr -d \"  >[path]/data/Ozone_WiDS_Analysis/ozone_hdr.tsv
#head -n1[path]/data/AQI_WiDS_Analysis/WiDS_aqi_1981.tsv >[path]/data/Ozone_WiDS_Analysis/ozone_hdr.tsv

#Add unique row number
#awk '{print NR  "," $0 }'[path]/data/AQI_WiDS_Analysis/WiDS_aqi_1980_2021.tsv > tmp.tsv && mv tmp.tsv[path]/data/AQI_WiDS_Analysis/WiDS_aqi_1980_2021_.tsv

awk '{print NR  "," $0 }'[path]/data/Ozone_WiDS_Analysis/WiDS_ozone_1980_2021.tsv > tmp.tsv && mv tmp.tsv[path]/data/Ozone_WiDS_Analysis/WiDS_ozone_1980_2021.tsv

# Select columns of interest from file
# Reduce modeling run time
awk 'BEGIN{FS=OFS="\t"} {print $10, $13, $9}'[path]/data/Ozone_WiDS_Analysis/WiDS_ozone_1980_2021.tsv > new_file.tsv
#!/bin/bash

#Navigate to data directory
cd $2 

#Download and unxip files
while read line
do
	year="$line"
	wget "https://aqs.epa.gov/aqsweb/airdata/daily_44201_"$year".zip"
	unzip "daily_44201_1"$year".zip"
done < $1

#Unzip files
for file in *.zip 
do
	unzip "${file}"
done

#Remove archived zip files
rm *.zip*

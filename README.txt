WiDS Phase 2
Track 1 : US Environmental Protection Agency (EPA): weather, air pollutant, and census data

Data Source:
EPA: Pre-Generated Data Files
https://aqs.epa.gov/aqsweb/airdata/download_files.html


The following describes how data for the analysis was collected, processed, and merged into final dataframes for downstream analysis.

#########################
Part 1: Scrape Data from EPA
#########################
Code:
bash AQI_dwnld_epa_data.sh [path]
bash ozone_dwnld_epa_data.sh [path]
bash HAPS_dwnld_epa_data.sh [path]

Input:
Path of directory where data will be stored.

Ouput:
Data from 1980 - 2021 for air quality index(AQI), hazardous air particles(HAPS), and ozone across the United States.
AQI: daily_aqi_by_cbsa_1980.csv
HAPS: daily_HAPS_1980.csv
Ozone: daily_44201_1980.csv


WiDS Phase 2
Track 1 : US Environmental Protection Agency (EPA): weather, air pollutant, and census data

Data Source:
EPA: Pre-Generated Data Files
https://aqs.epa.gov/aqsweb/airdata/download_files.html


The following describes how data for the analysis was collected, processed, and merged into final dataframes for downstream analysis.

#########################
Part 1: Scrape Data from EPA
#########################
Collect data from EPA for hazardous air particles (HAPS), AQI, and ozone from 1980-2021.

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

##########################################
Part 2: Select fields of interest from each dataframe
##########################################
Run the following Colab Notebook to generate CSBA, state, and region from WiDS competition.
Goal is to evaluate the same sites for all years from 1980-2021 : WiDS_aqi_rows, WiDS_ozone_rows
WiDS_Track1_HAP_Analysis1_LMCH.ipynb
https://colab.research.google.com/drive/14FMjRldZ-sDJmiaUA4-blJIC3mwsWMVA

Code:
Rscript generate_dataframe_per_yr.R [year]

Input:
HAPS Dataframes: 1980-2021
AQI Dataframes: 1980-2021
ozone Dataframes: 1980-2021
WiDS_aqi_rows
WiDS_ozone_rows

Output:
Dataframe 1: WiDS Ozone Dataframe for each year [1980-2021]
Select data (i.e.: LATITUDE,	LONGITUDE,Parameter_Name_HAPS, etc) for each year for CSBA sites represented in the WiDS 2019-2020 dataframes
WiDS_ozone_',year,'.csv

Dataframe 2: WiDS AQI Dataframe for each year [1980-2021]
Select data (i.e.: LATITUDE,	LONGITUDE,Parameter_Name_HAPS, etc) for each year for CSBA sites represented in the WiDS 2019-2020 dataframes
WiDS_aqi_',year,'.csv

#######################################################
Part 3: Generate merged Ozone and AQI Dataframes for 1980 - 2021
#######################################################

Code:
Bash generate_finaldf_1980_2021_aqi_oz.sh [list of years]
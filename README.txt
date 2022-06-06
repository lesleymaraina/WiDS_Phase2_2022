WiDS Phase 2
Track 1 : US Environmental Protection Agency (EPA): weather, air pollutant, and census data

Data Source:
EPA: Pre-Generated Data Files
https://aqs.epa.gov/aqsweb/airdata/download_files.html

WiDS Track 1 Data EPA


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
WiDS_ozone_',year,'.tsv

Dataframe 2: WiDS AQI Dataframe for each year [1980-2021]
Select data (i.e.: LATITUDE,	LONGITUDE,Parameter_Name_HAPS, etc) for each year for CSBA sites represented in the WiDS 2019-2020 dataframes
WiDS_aqi_',year,'.tsv

Generate merged Ozone and AQI Dataframes for 1980 - 2021

Code:
Bash generate_finaldf_1980_2021_aqi_oz.sh [list of years]

Input:
WiDS_ozone_',year,'.tsv
WiDS_aqi_',year,'.tsv

Output:
Full dataframe: WiDS_aqi_1980_2021.tsv
Select columns: WiDS_aqi_1980_2021_df.tsv


Full dataframe: WiDS_ozone_1980_2021.tsv
Select columns: WiDS_ozone_1980_2021_df.tsv

###############################################################################
Part 3: Plot summary of demographic data across the United States
###############################################################################
Generate plots summarizing social demographics across the United States (i.e.: people of color fraction) for 2019 and 2020

###############################################################################
Part 4: Evaluate association of each hazardous air particle (HAP) with ozone and AQI respectively
###############################################################################

Code:
Evaluate_HAPS.R


###############################################################################
Part 5: Generate dataframes for HAPS multivariate analysis
###############################################################################
Part A: Generate dataframes for each state for each year from 1980-2021* that has columns representing each respective HAP
* Note: some states do not have data for all years from 1980-2021

Code: 
bash generate_df_multivariate_analysis.sh years.txt

Runs generate_df_multivariate_analysis.R
years.txt: text file listing years 1980-2021

Output:
Dataframe with representing each state for each year from 1990-2021.  Dataframe has columns representing each HAP value, and each row represents a daily measurement throughout the course of the year for each CSBA site

Part B:
Merge dataframes for each state across all years represented for the state.

Code:
bash merge_files.sh Alabama
bash merge_files.sh Arizona
bash merge_files.sh Arkansas
[repeat for each state]
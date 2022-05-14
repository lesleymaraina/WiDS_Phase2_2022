library(tidyverse)
library(lubridate)
options(echo=TRUE)


args <- commandArgs(trailingOnly = TRUE)
year <- args[1]

HAP <- paste0('[path]/daily_HAPS_', year,'.csv')
ozone <- paste0('[path]/daily_44201_',year,'.csv')
aqi <- paste0('[path]/daily_aqi_by_cbsa_',year,'.csv')
WiDS_aqi_rows <- '[path]/WiDS_rows_aqi_HAPS.csv'
WiDS_ozone_rows <- '[path]/WiDS_rows_ozone_HAPS_for_1980_2021.csv'

HAP = read.csv(HAP)
ozone = read.csv(ozone)
aqi = read.csv(aqi)
WiDS_aqi_rows = read.csv(WiDS_aqi_rows)
WiDS_ozone_rows = read.csv(WiDS_ozone_rows)


# Modify Column Names
#---------------------
# Column names must match across dataframes

ozone %>% rename(LATITUDE = Latitude,
LONGITUDE = Longitude,
STATE = State.Name,
CBSA = CBSA.Name,
COUNTY = County.Name,
DATE = Date.Local,
Parameter_Name_Ozone = Parameter.Name,
Arithmetic_Mean_Ozone = Arithmetic.Mean,
Max_Value_Ozone = X1st.Max.Value,
Units_of_Measure_Ozone = Units.of.Measure ) -> ozone


HAP %>% rename(LATITUDE = Latitude,
LONGITUDE = Longitude,
STATE = State.Name,
CBSA = CBSA.Name,
COUNTY = County.Name,
DATE = Date.Local,
Parameter_Name_HAPS = Parameter.Name,
Arithmetic_Mean_HAPS = Arithmetic.Mean,
Max_Value_HAPS = X1st.Max.Value,
Units_of_Measure_HAPS = Units.of.Measure ) -> HAPS

aqi <- aqi %>% rename(DATE = Date, Defining_Parameter_AQI = Defining.Parameter, AQI_Measurement = AQI)
aqi %>% mutate(DATE=as.Date(DATE)) -> aqi
ozone %>% mutate(DATE=as.Date(DATE)) -> ozone
HAPS %>% mutate(DATE=as.Date(DATE)) -> HAPS

# Merge Dataframes
#-----------------
HAPS_ozone <- ozone %>% inner_join(HAPS, by = c("DATE", "LATITUDE", "LONGITUDE", "COUNTY", "STATE", "CBSA"))

HAPS_aqi <- aqi %>% inner_join(HAPS, by = c("DATE", "CBSA"))


# Select CSBA based on 2020 and 2019 WiDS Data
#---------------------------------------------
# Ozone
WiDS_ozone_year <- HAPS_ozone %>% inner_join(WiDS_ozone_rows, by = c("LATITUDE", "LONGITUDE", "COUNTY", "STATE", "CBSA"))

WiDS_ozone_year %>% select (c('LONGITUDE', 'STATE', 'CBSA', 'LATITUDE', 'DATE', 'Parameter_Name_Ozone', 'Arithmetic_Mean_Ozone', 'Units_of_Measure_Ozone', 'Max_Value_Ozone', 'Parameter_Name_HAPS', 'Units_of_Measure_HAPS', 'Arithmetic_Mean_HAPS', 'Max_Value_HAPS')) -> WiDS_ozone_year

WiDS_aqi_year <- HAPS_aqi %>% inner_join(WiDS_aqi_rows, by = c("CBSA", "LATITUDE", "LONGITUDE","COUNTY"))

WiDS_aqi_year %>% select(c("CBSA", "DATE",  "COUNTY" , "LATITUDE", "LONGITUDE", "STATE",  "Parameter_Name_HAPS" , "Max_Value_HAPS", "AQI", "AQI_Measurement", "Category", "Units_of_Measure_HAPS", "Arithmetic_Mean_HAPS")) -> WiDS_aqi_year

#Re-arrange column order in dataframe
#WiDS_ozone_year = WiDS_ozone_year %>% select(DATE, CBSA, STATE, LATITUDE, LONGITUDE, 				Parameter_Name_Ozone,	Arithmetic_Mean_Ozone,	Units_of_Measure_Ozone,	Max_Value_Ozone,	Parameter_Name_HAPS,	Arithmetic_Mean_HAPS,  Units_of_Measure_HAPS,	Max_Value_HAPS)

#WiDS_aqi_year = WiDS_aqi_year %>% select(DATE,	CBSA,	STATE, COUNTY,	LATITUDE,	LONGITUDE,		Parameter_Name_HAPS,	Max_Value_HAPS,	Units_of_Measure_HAPS,	Arithmetic_Mean_HAPS, AQI,	AQI_Measurement,	Category)


WiDS_ozone_year$CBSA <- as.character(gsub(",","",WiDS_ozone_year$CBSA))
WiDS_aqi_year$CBSA <- as.character(gsub(",","",WiDS_aqi_year$CBSA))


# Save Dataframes
write.table(WiDS_ozone_year,  row.names=FALSE, quote=FALSE, sep = '\t', file=paste0('[path]_WiDS_Analysis/WiDS_ozone_',year,'.tsv'))
write.table(WiDS_aqi_year, row.names=FALSE, quote=FALSE, sep = '\t', file=paste0('[path]_WiDS_Analysis/WiDS_aqi_',year,'.tsv'))





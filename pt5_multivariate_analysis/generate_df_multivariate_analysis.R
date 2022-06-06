library(tidyverse)
library(data.table)
options(echo=TRUE)

args <- commandArgs(trailingOnly = TRUE)
year <- args[1]

year <- year
year <-  year %>% str_replace("\\r","")

file <- paste0('[path]]/WiDS_ozone_',year,'.tsv')
df = fread(file)

#Create column with unique index
df <- tibble::rowid_to_column(df, "index")


# Store location and ozone columns
df_col <- df %>% select(c(index,STATE,DATE,CBSA,Max_Value_Ozone))

# Generate dataframe where each column lists HAPS data 
df2 <- df %>% select(index,Parameter_Name_HAPS, Max_Value_HAPS) %>%
  pivot_wider(id_cols = index,
              names_from = Parameter_Name_HAPS,
              values_from = Max_Value_HAPS) %>% 
  replace(is.na(.), 0)
  
# Add location and ozone data back to the original dataframe
df3 <- df_col %>% inner_join(df2, by = "index")

# Save each dataframe by state
df3 %>%
  mutate(STATE = str_replace(STATE, " ", "_")) %>%
  split(.$STATE) %>%
  imap(~write.table(.x, paste0("[path]/Ozone_WiDS_Analysis/ozone_multivariate_analysis/",.y, '_', year, '.tsv'), row.names = FALSE, quote=FALSE, sep = '\t'))
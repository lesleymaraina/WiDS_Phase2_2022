library(tidyverse)
library(lubridate)
library(data.table)


Ozone = read.table('[path]/WiDS_ozone_1980_2021_df.tsv', sep="\t", header= TRUE)
AQI = read.table('[path]/WiDS_aqi_1980_2021_df.tsv', sep="\t", header= TRUE)


Ozone$Parameter_Name_HAPS <- as.character(Ozone$Parameter_Name_HAPS)
Ozone$Max_Value_Ozone <- as.numeric(as.character(Ozone$Max_Value_Ozone))
Ozone$Max_Value_HAPS <- as.numeric(as.character(Ozone$Max_Value_HAPS))
AQI$Parameter_Name_HAPS <- as.character(AQI$Parameter_Name_HAPS)
AQI$AQI_Measurement <- as.numeric(as.character(AQI$AQI_Measurement))

#Model each HAP independently with ozone
ozone_model <- Ozone %>%
  group_by(Parameter_Name_HAPS) %>%
  summarise(n = n()) %>%
  mutate(Freq = n/sum(n)) %>%
  arrange(desc(n))

ozone_model_split <- split(Ozone, f = Ozone$Parameter_Name_HAPS) 

df = data.frame()
 for (i in 1:length(ozone_model$Parameter_Name_HAPS)) {
  x <- as.data.frame(ozone_model_split[[ozone_model$Parameter_Name_HAPS[i]]])
  mod1_lm<-lm(Max_Value_Ozone ~ Max_Value_HAPS, data=x, na.action=na.exclude)
  output = c(ozone_model$Parameter_Name_HAPS[i], summary(mod1_lm)$adj.r.)
  df = rbind(df, output)
  df$HAP[i] = ozone_model$Parameter_Name_HAPS[i]
  df$ozone_R2[i] = summary(mod1_lm)$adj.r.
}

df <- df %>% 
select(HAP,ozone_R2) %>% 
mutate_at('ozone_R2', as.numeric) %>% 
arrange(desc(ozone_R2))
head(df)
write.table(df,row.names=FALSE,sep="\t", quote = FALSE, file=paste0('[path]/ozone_HAPS_lm_R2.tsv'))
###-------------------------END Ozone Analysis--------------------###



#Model each HAP independently with AQI
aqi_model <- AQI %>%
 group_by(Parameter_Name_HAPS) %>%
 summarise(n = n()) %>%
 mutate(Freq = n/sum(n)) %>%
 arrange(desc(n))
 
aqi_model_split <- split(AQI, f = AQI$Parameter_Name_HAPS) 


# df = data.frame()
# for (i in 1:length(aqi_model$Parameter_Name_HAPS)) {
 # x <- as.data.frame(aqi_model_split[[aqi_model$Parameter_Name_HAPS[i]]])
 # mod1_lm<-lm(AQI_Measurement ~ Max_Value_HAPS, data=x, na.action=na.exclude)
 # output = c(aqi_model$Parameter_Name_HAPS[i], summary(mod1_lm)$adj.r.)
 # df = rbind(df, output)

# }

# colnames(df)<-c("HAP", "aqi_R2")
# aqi_R2 <- as.numeric(as.character(df$aqi_R2))
# df <- df %>% arrange(desc(aqi_R2))
# head(df, 10)

# write.csv(df,  row.names=FALSE, quote=FALSE, file=paste0('[path]/aqi_analysis/aqi_HAPS_lm_R2.csv'))

df = data.frame()
 for (i in 1:length(aqi_model$Parameter_Name_HAPS)) {
  x <- as.data.frame(aqi_model_split[[aqi_model$Parameter_Name_HAPS[i]]])
 mod1_lm<-lm(AQI_Measurement ~ Max_Value_HAPS, data=x, na.action=na.exclude)
 output = c(aqi_model$Parameter_Name_HAPS[i], summary(mod1_lm)$adj.r.)
 df = rbind(df, output)  
 df$HAP[i] = aqi_model$Parameter_Name_HAPS[i]
 df$AQI_R2[i] = summary(mod1_lm)$adj.r.
}

df <- df %>% 
select(HAP,AQI_R2) %>% 
mutate_at('AQI_R2', as.numeric) %>% 
arrange(desc(AQI_R2))
head(df)
write.table(df,row.names=FALSE,sep="\t", quote = FALSE, file=paste0('[path]/aqi_analysis/aqi_HAPS_lm_R2.tsv'))
###-------------------------END AQI Analysis--------------------###



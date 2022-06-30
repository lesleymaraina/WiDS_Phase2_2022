#install.packages('ggplot2', repos = "http://cran.us.r-project.org")
#install.packages('BSDA', repos = "http://cran.us.r-project.org")
#install.packages('tidyverse', repos = "http://cran.us.r-project.org")
#install.packages('data.table', repos = "http://cran.us.r-project.org")

library(ggplot2)
library(BSDA)
library(data.table)
library(tidyverse)
options(echo=TRUE)

args <- commandArgs(trailingOnly = TRUE)
state <- args[1]
HAP <- args[2]


state_df <- read.csv(paste0('[path]/data/multivar_states/',state,'_multivar.tsv'), sep='\t')
state_df[is.na(state_df)] <- 0
state_df <- unique(state_df)
names(state_df) <- gsub(x = names(state_df), pattern = "\\.\\.", replacement = "_")  
names(state_df) <- gsub(x = names(state_df), pattern = "\\.", replacement = "_")  
names(state_df) <- gsub(x = names(state_df), pattern = "\\_\\_", replacement = "_")  


dem_df <- read.csv('[path]/Datathon_EPA_Air_Quality_Demographics_Meteorology_2020.csv')
dem_df[is.na(dem_df)] <- 0
dem_df <- dem_df %>% select(c(CBSA, STATE, PEOPLE_OF_COLOR_FRACTION, LOW_INCOME_FRACTION, LINGUISTICALLY_ISOLATED_FRACTION, LESS_THAN_HS_ED_FRACTION))
dem_df <- dem_df %>% mutate(CBSA = gsub("\\,", "", CBSA))
dem_df <- dem_df %>% filter(grepl(state, STATE))
dem_df <- unique(dem_df)
#unique(state_df[c("STATE")])
#unique(state_df[c("CBSA")])
#unique(dem_df[c("STATE")])
#unique(dem_df[c("CBSA")])


dem_HAPS_df <- state_df %>% inner_join(dem_df, by = c("STATE", "CBSA"))
#dem_HAPS_df <- dem_HAPS_df[!duplicated(dem_HAPS_df), ]

dem_HAPS_df_pplcol_hi <- dem_HAPS_df %>% filter(PEOPLE_OF_COLOR_FRACTION > 0.5)
dem_HAPS_df_pplcol_lo <- dem_HAPS_df %>% filter(PEOPLE_OF_COLOR_FRACTION < 0.5)

dem_HAPS_df_income_hi <- dem_HAPS_df %>% filter(LOW_INCOME_FRACTION > 0.5)
dem_HAPS_df_income_lo <- dem_HAPS_df %>% filter(LOW_INCOME_FRACTION < 0.5)

dem_HAPS_df_langiso_hi <- dem_HAPS_df %>% filter(LINGUISTICALLY_ISOLATED_FRACTION > 0.5)
dem_HAPS_df_langiso_lo <- dem_HAPS_df %>% filter(LINGUISTICALLY_ISOLATED_FRACTION < 0.5)

dem_HAPS_df_hsed_hi <- dem_HAPS_df %>% filter(LESS_THAN_HS_ED_FRACTION > 0.5)
dem_HAPS_df_hsed_lo <- dem_HAPS_df %>% filter(LESS_THAN_HS_ED_FRACTION < 0.5)

nrow(dem_HAPS_df_pplcol_hi)
nrow(dem_HAPS_df_pplcol_lo)

nrow(dem_HAPS_df_income_hi)
nrow(dem_HAPS_df_income_lo)

nrow(dem_HAPS_df_langiso_hi)
nrow(dem_HAPS_df_langiso_lo)

nrow(dem_HAPS_df_hsed_hi)
nrow(dem_HAPS_df_hsed_lo)


#Box Plots Comparing HAPS between high and low demographic regions
#Create new columns representing demographic infomration
threshold = 0.5
#Overall ozone level comparison between demographic groups
#Box plots
dem_HAPS_df <- dem_HAPS_df %>% mutate(ppl_col = if_else(PEOPLE_OF_COLOR_FRACTION > threshold, "high", "low")) %>% mutate(income = if_else(LOW_INCOME_FRACTION > threshold, "high", "low")) %>% mutate(ling_isol = if_else(LINGUISTICALLY_ISOLATED_FRACTION > threshold, "high", "low")) %>% mutate(hsed = if_else(LESS_THAN_HS_ED_FRACTION > threshold, "high", "low"))
print(head(dem_HAPS_df))

#Create Box Plots
pplcol_plot <- ggplot(dem_HAPS_df) +
  aes(x = ppl_col, y = Max_Value_Ozone) +
  geom_boxplot() +
  theme_minimal()

ggsave(filename=paste(state, "_oz_box_state_pplcol.pdf", sep="_"), plot=pplcol_plot)

while (!is.null(dev.list()))  dev.off()

income_plot <- ggplot(dem_HAPS_df) +
  aes(x = income, y = Max_Value_Ozone) +
  geom_boxplot() +
  theme_minimal()

ggsave(filename=paste(state, "_oz_box_state_income.pdf", sep="_"), plot=income_plot)

while (!is.null(dev.list()))  dev.off()


lingiso_plot <- ggplot(dem_HAPS_df) +
  aes(x = ling_isol, y= Max_Value_Ozone) +
  geom_boxplot() +
  theme_minimal()

ggsave(filename=paste(state, "_oz_box_state_lingiso.pdf", sep="_"), plot=lingiso_plot)

while (!is.null(dev.list()))  dev.off()


hsed_plot <- ggplot(dem_HAPS_df) +
  aes(x =hsed,, y = Max_Value_Ozone) +
  geom_boxplot() +
  theme_minimal()

ggsave(filename=paste(state, "_oz_box_state_hsed.pdf", sep="_"), plot=hsed_plot)
while (!is.null(dev.list()))  dev.off()






#Statistical Tests
#Linear Model Plot Function
#Function Code Soure:
# https://sejohnston.com/2012/08/09/a-quick-and-easy-function-to-plot-lm-results-in-r/

ggplotRegression <- function (fit) {
require(ggplot2)

ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
  geom_point() +
  stat_smooth(method = "lm", col = "red") +
  labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                     "Intercept =",signif(fit$coef[[1]],5 ),
                     " Slope =",signif(fit$coef[[2]], 5),
                     " P =",signif(summary(fit)$coef[2,4], 5)))
}

#Compare high and low demographic groups
#People of Color
x <- as.matrix(dem_HAPS_df_pplcol_hi[HAP])
y <- as.matrix(dem_HAPS_df_pplcol_lo[HAP])

print('Wilcoxon Rank Sum')
wilcox.test(x, y, alternative = "g") 

print('Two Sample t-Test')
t.test(x, y, var.equal = FALSE, alternative = "greater") 


z <- dem_HAPS_df_pplcol_hi
x <- as.matrix(dem_HAPS_df_pplcol_hi[HAP])
y <- as.matrix(dem_HAPS_df_pplcol_hi['Max_Value_Ozone'])

mod1_lm<-lm(y ~ x, data=z, na.action=na.exclude)
summary(mod1_lm)$adj.r.
plot_lm_1 <- ggplotRegression(lm(log(y) ~ log(x), data = z)) + theme_bw() + xlab("HAP") + ylab("Ozone Level for 8 Hours (ppm)")
ggsave(filename=paste(state, HAP, "_oz_lm_pplcol_hidem.pdf", sep="_"), plot=plot_lm_1)
while (!is.null(dev.list()))  dev.off()

z <- dem_HAPS_df_pplcol_lo
x <- as.matrix(dem_HAPS_df_pplcol_lo[HAP])
y <- as.matrix(dem_HAPS_df_pplcol_lo['Max_Value_Ozone'])

mod1_lm<-lm(y ~ x, data=z, na.action=na.exclude)
summary(mod1_lm)$adj.r.
plot_lm_2 <- ggplotRegression(lm(log(y) ~ x, data = z)) + theme_bw() + xlab("HAP") +
  ylab("Ozone Level for 8 Hours (ppm)")
ggsave(filename=paste(state, HAP, "_oz_lm_pplcol_lodem.pdf", sep="_"), plot=plot_lm_2)
while (!is.null(dev.list()))  dev.off()

#Income
x <- as.matrix(dem_HAPS_df_income_hi[HAP])
y <- as.matrix(dem_HAPS_df_income_lo[HAP])

print('Wilcoxon Rank Sum')
wilcox.test(x, y, alternative = "g") 

print('Two Sample t-Test')
t.test(x, y, var.equal = FALSE, alternative = "greater") 

x <- as.matrix(dem_HAPS_df_income_hi[HAP])
y <- as.matrix(dem_HAPS_df_income_lo[HAP])

print('Wilcoxon Rank Sum')
wilcox.test(x, y, alternative = "g") 

print('Two Sample t-Test')
t.test(x, y, var.equal = FALSE, alternative = "greater") 


z <- dem_HAPS_df_income_hi
x <- as.matrix(dem_HAPS_df_income_hi[HAP])
y <- as.matrix(dem_HAPS_df_income_hi['Max_Value_Ozone'])

mod1_lm<-lm(y ~ x, data=z, na.action=na.exclude)
summary(mod1_lm)$adj.r.
plot_lm_3 <- ggplotRegression(lm(log(y) ~ x, data = z)) + theme_bw() + xlab("HAP") +
  ylab("Ozone Level for 8 Hours (ppm)")
ggsave(filename=paste(state, HAP, "_oz_lm_hidem_income.pdf", sep="_"), plot=plot_lm_3)
while (!is.null(dev.list()))  dev.off()

z <- dem_HAPS_df_income_lo
x <- as.matrix(dem_HAPS_df_income_lo[HAP])
y <- as.matrix(dem_HAPS_df_income_lo['Max_Value_Ozone'])

mod1_lm<-lm(y ~ x, data=z, na.action=na.exclude)
summary(mod1_lm)$adj.r.
plot_lm_4 <- ggplotRegression(lm(log(y) ~ log(x), data = z)) + theme_bw() + xlab("HAP") +
  ylab("Ozone Level for 8 Hours (ppm)")
ggsave(filename=paste(state, HAP, "_oz_lm_lodem_income.pdf", sep="_"), plot=plot_lm_4)
while (!is.null(dev.list()))  dev.off()

#Linguistically isolated
x <- as.matrix(dem_HAPS_df_langiso_hi[HAP])
y <- as.matrix(dem_HAPS_df_langiso_lo[HAP])
print(class(x))

print('Wilcoxon Rank Sum')
wilcox.test(x, y, alternative = "g") 

print('Two Sample t-Test')
t.test(x, y, var.equal = FALSE, alternative = "greater") 

x <- as.matrix(dem_HAPS_df_langiso_hi[HAP])
y <- as.matrix(dem_HAPS_df_langiso_lo[HAP])

print('Wilcoxon Rank Sum')
wilcox.test(x, y, alternative = "g") 

print('Two Sample t-Test')
t.test(x, y, var.equal = FALSE, alternative = "greater") 


z <- dem_HAPS_df_langiso_hi
x <- as.matrix(dem_HAPS_df_langiso_hi[HAP])
y <- as.matrix(dem_HAPS_df_langiso_hi['Max_Value_Ozone'])

mod1_lm <-lm(y ~ x, data=z, na.action=na.exclude)
summary(mod1_lm)$adj.r.
plot_lm_5 <- ggplotRegression(lm(log(y) ~ log(x), data = z)) + theme_bw() + xlab("HAP") +
  ylab("Ozone Level for 8 Hours (ppm)")
ggsave(filename=paste(state, HAP, "_oz_lm_hidem_linguist.pdf", sep="_"), plot=plot_lm_5)
while (!is.null(dev.list()))  dev.off()

z <- dem_HAPS_df_langiso_lo
x <- as.matrix(dem_HAPS_df_langiso_lo[HAP])
y <- as.matrix(dem_HAPS_df_langiso_lo['Max_Value_Ozone'])

mod1_lm <- lm(y ~ x, data=z, na.action=na.exclude)
summary(mod1_lm)$adj.r.
plot_lm_6 <- ggplotRegression(lm(log(y) ~ x, data = z)) + theme_bw() + xlab("HAP") +
  ylab("Ozone Level for 8 Hours (ppm)")
ggsave(filename=paste(state, HAP, "_oz_lm_lodem_linguist.pdf", sep="_"), plot=plot_lm_6)
while (!is.null(dev.list()))  dev.off()


#HS Ed
x <- as.matrix(dem_HAPS_df_hsed_hi[HAP])
y <- as.matrix(dem_HAPS_df_hsed_lo[HAP])
print(class(x))

print('Wilcoxon Rank Sum')
wilcox.test(x, y, alternative = "g") 

print('Two Sample t-Test')
t.test(x, y, var.equal = FALSE, alternative = "greater") 

x <- as.matrix(dem_HAPS_df_hsed_hi[HAP])
y <- as.matrix(dem_HAPS_df_hsed_lo[HAP])

print('Wilcoxon Rank Sum')
wilcox.test(x, y, alternative = "g") 

print('Two Sample t-Test')
t.test(x, y, var.equal = FALSE, alternative = "greater") 


z <- dem_HAPS_df_hsed_hi
x <- as.matrix(dem_HAPS_df_hsed_hi[HAP])
y <- as.matrix(dem_HAPS_df_hsed_hi['Max_Value_Ozone'])

mod1_lm <-lm(y ~ x, data=z, na.action=na.exclude)
summary(mod1_lm)$adj.r.
plot_lm_7 <- ggplotRegression(lm(log(y) ~ x, data = z)) + theme_bw() + xlab("HAP") +
  ylab("Ozone Level for 8 Hours (ppm)")
ggsave(filename=paste(state, HAP, "_oz_lm_hidem_hsed.pdf", sep="_"), plot=plot_lm_7)
while (!is.null(dev.list()))  dev.off()

z <- dem_HAPS_df_hsed_lo
x <- as.matrix(dem_HAPS_df_hsed_lo[HAP])
y <- as.matrix(dem_HAPS_df_hsed_lo['Max_Value_Ozone'])

mod1_lm<-lm(y ~ x, data=z, na.action=na.exclude)
summary(mod1_lm)$adj.r.
plot_lm_8 <- ggplotRegression(lm(log(y) ~ x, data = z)) + theme_bw() + xlab("HAP") +
ylab("Ozone Level for 8 Hours (ppm)")
ggsave(filename=paste(state, HAP, "_oz_lm_lodem_hsed.pdf", sep="_"), plot=plot_lmi_8)
while (!is.null(dev.list()))  dev.off()
#write.table(dem_HAPS_df, row.names=FALSE, quote=FALSE, sep='\t', file=paste0(state,'_dem_HAPS.tsv'))

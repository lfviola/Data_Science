#set working directory and load packages 
setwd("~/Data Science/DATATHLON/DemandForecast")
rm(list = ls())
library(ggplot2)
library(reshape2)

#import and transform demand datasets
nord <- read.csv("~/Data Science/DATATHLON/DemandForecast/nord.csv", sep=";")
nord$Date <- as.Date(nord$Date, format = "%d/%m/%Y")
IDF <- read.csv("~/Data Science/DATATHLON/DemandForecast/IDF.csv", sep=";")
IDF$Date <- as.Date(IDF$Date, format = "%d/%m/%Y")
ouest <- read.csv("~/Data Science/DATATHLON/DemandForecast/ouest.csv", sep=";")
ouest$Date <- as.Date(ouest$Date, format = "%d/%m/%Y")

#Polynomial Regressions
Reg_Poly2_IDF <- lm(IDF$Total_QTE ~ poly(IDF$Before_10, 3, raw=TRUE))
summary(Reg_Poly2_IDF)

Reg_Poly2_nord <- lm(nord$Total_QTE ~ poly(nord$Before_10, 2, raw=TRUE))
summary(Reg_Poly2_nord)

Reg_Poly2_ouest <- lm(ouest$Total_QTE ~ poly(ouest$Before_10, 2, raw=TRUE))
summary(Reg_Poly2_ouest)


theme_set(theme_bw())

df_ouest<-data.frame("x"=ouest$Before_10, "y"=ouest$Total_QTE)
ggplot(df_ouest, aes(x, y)) + 
  geom_point(color='red',   alpha=0.3,size=3) + 
  stat_smooth(method="lm", se=TRUE, fill=NA,
              formula=y ~ poly(x, 2, raw=TRUE),colour="black") +
  labs(title="Volume demanded ouest", x="Before 10am", y="Total")

df_IDF<-data.frame("x"=IDF$Before_10, "y"=IDF$Total_QTE)
ggplot(df_IDF, aes(x, y)) + 
  geom_point(color='darkgreen',   alpha=0.3,size=3) + 
  stat_smooth(method="lm", se=TRUE, fill=NA,
              formula=y ~ poly(x, 3, raw=TRUE),colour="black") +
  labs(title="Volume demanded IDF", x="Before 10am", y="Total")

df_nord<-data.frame("x"=nord$Before_10, "y"=nord$Total_QTE)
ggplot(df_nord, aes(x, y)) + 
  geom_point(color='blue',   alpha=0.3,size=3) + 
  stat_smooth(method="lm", se=TRUE, fill=NA,
              formula=y ~ poly(x, 2, raw=TRUE),colour="black") +
  labs(title="Volume demanded nord", x="Before 10am", y="Total")


setwd("~/Data Science/DATATHLON/Files/DataV3")
rm(list = ls())
library(ggplot2)
library(reshape2)
library(reshape)
library("xlsx")

#Importing and prepping the data
truck_amount <- read.csv("truck_amount.csv", sep=";")
truck_amount$DT_STA_LIV_PSG <- as.Date(truck_amount$DT_STA_LIV_PSG, format = "%d/%m/%Y")
fdm_orders_timed_train <- read.csv("fdm_orders_timed_train.csv", sep=";")
fdm_orders_timed_train$DT_STA_LIV_PSG <- as.Date(fdm_orders_timed_train$DT_STA_LIV_PSG, format = "%d/%m/%Y")
fdm_orders_timed_train$before_10 <- as.logical(fdm_orders_timed_train$before_10)
MATRIX <- fdm_orders_timed_train
colnames(MATRIX)[4] <- "CAI_CODE"
client_referential <- read.csv("client_referential.csv", sep=";")
product_referential <- read.csv("product_referential.csv", sep=";")
MATRIX <- merge(MATRIX, client_referential, by = "CLT_C", all.x = TRUE)
MATRIX <- merge(MATRIX, product_referential, by = "CAI_CODE", all.x = TRUE)
MATRIX$TOTAL_VOL <- MATRIX$ENG_QT * MATRIX$VOL

#Pivot the MATRIX
MATRIX.m <- melt(MATRIX, id=c(1:14), measure=c(15))
MATRIX.c <- cast(MATRIX.m, DT_STA_LIV_PSG  ~ zone + before_10, sum)

#Add truck_amount, pivoting...
truck_amount.m <- melt(truck_amount, id=c(2:4), measure=c(1))
truck_amount.c <- cast(truck_amount.m, DT_STA_LIV_PSG  ~ zone + type, sum)

TEST <- merge(MATRIX.c, truck_amount.c, by = "DT_STA_LIV_PSG", all.x = TRUE)

nord_marguerite <- lm(TEST$nord_TRUE ~ poly(TEST$nord_marguerite, 1, raw=TRUE))
summary(nord_marguerite)

nord_direct <- lm(TEST$nord_TRUE ~ poly(TEST$nord_direct, 1, raw=TRUE))
summary(nord_direct)

ouest_third_party <- lm(TEST$ouest_TRUE ~ poly(TEST$ouest_third_party, 2, raw=TRUE))
summary(ouest_third_party)

ouest_direct <- lm(TEST$ouest_TRUE ~ poly(TEST$ouest_direct, 2, raw=TRUE))
summary(ouest_third_party)

IDF_direct <- lm(TEST$IDF_TRUE ~ poly(TEST$IDF_direct, 2, raw=TRUE))
summary(IDF_direct)

IDF_third_party <- lm(TEST$IDF_TRUE ~ poly(TEST$IDF_third_party, 1, raw=TRUE))
summary(IDF_third_party)

ggplot(TEST, aes(x=ouest_TRUE, y=ouest_third_party)) + 
  geom_point(color='red',   alpha=0.3,size=3) + 
  labs(title="Third Party trucks Ouest", x="Before 10am Ouest", y="Third_Party")+
  stat_smooth(method='lm')

ggplot(TEST, aes(x=IDF_TRUE, y=IDF_third_party)) + 
  geom_point(color='red',   alpha=0.3,size=3) + 
  labs(title="IDF trucks Ouest", x="Before 10am IDF", y="IDF")+
  stat_smooth(method='lm')

#set working directory and load packages 
rm(list = ls())
setwd("~/Data Science/DATATHLON/Files/DataV3")
library("ggplot2")
library(reshape2)
library(tseries)
library(forecast)
library(sos)

#import and transform truck_amount dataset
truck_amount <- read.csv("~/Data Science/DATATHLON/Files/DataV3/truck_amount.csv", sep=";")
truck_amount$DT_STA_LIV_PSG <- as.Date(truck_amount$DT_STA_LIV_PSG, format = "%d/%m/%Y")
truck_amount$Amount <- as.integer(truck_amount$Amount)

#Prepare the time series for Ouest
truck_amount_ouest_by_zone <- dcast(truck_amount, DT_STA_LIV_PSG ~ zone, value.var="Amount")
truck_amount_ouest_by_zone[2:3] <- list(NULL)
truck_amount_ouest_by_type <- subset(truck_amount, zone == 'ouest')
truck_amount_ouest_by_type[4] <- list(NULL)
truck_amount_ouest_by_type <- dcast(truck_amount_ouest_by_type, DT_STA_LIV_PSG ~ type, value.var="Amount")
total_ouest <- merge(truck_amount_ouest_by_zone,truck_amount_ouest_by_type,by="DT_STA_LIV_PSG",all.x = TRUE)
total_ouest[2] <- list(NULL)
total_ouest[is.na(total_ouest)] <- 0
total_ouest_thirdparty_TS <- total_ouest[, -2][, -1]
total_ouest_direct_TS <- total_ouest[, -2][, -1]

#Prepare the time series for North
truck_amount_nord_by_zone <- dcast(truck_amount, DT_STA_LIV_PSG ~ zone, value.var="Amount")
truck_amount_nord_by_zone[2:3] <- list(NULL)
truck_amount_nord_by_type <- subset(truck_amount, zone == 'nord')
truck_amount_nord_by_type[4] <- list(NULL)
truck_amount_nord_by_type <- dcast(truck_amount_nord_by_type, DT_STA_LIV_PSG ~ type, value.var="Amount")
total_nord <- merge(truck_amount_nord_by_zone,truck_amount_nord_by_type,by="DT_STA_LIV_PSG",all.x = TRUE)
total_nord[2] <- list(NULL)
total_nord[is.na(total_ouest)] <- 0
total_nord_marguerite_TS <- total_nord[, -2][, -1]
total_nord_direct_TS <- total_nord[, -2][, -1]

#Prepare the time series for IDF
truck_amount_IDF_by_zone <- dcast(truck_amount, DT_STA_LIV_PSG ~ zone, value.var="Amount")
truck_amount_IDF_by_zone[2:3] <- list(NULL)
truck_amount_IDF_by_type <- subset(truck_amount, zone == 'IDF')
truck_amount_IDF_by_type[4] <- list(NULL)
truck_amount_IDF_by_type <- dcast(truck_amount_IDF_by_type, DT_STA_LIV_PSG ~ type, value.var="Amount")
total_IDF <- merge(truck_amount_IDF_by_zone,truck_amount_IDF_by_type,by="DT_STA_LIV_PSG",all.x = TRUE)
total_IDF[2] <- list(NULL)
total_IDF[is.na(total_ouest)] <- 0
total_IDF_thirdparty_TS <- total_IDF[, -2][, -1]
total_IDF_direct_TS <- total_IDF[, -2][, -1]


auto.arima(total_ouest_thirdparty_TS)
auto.arima(total_ouest_direct_TS)
auto.arima(total_nord_marguerite_TS)
auto.arima(total_nord_direct_TS)
auto.arima(total_IDF_thirdparty_TS)
auto.arima(total_IDF_direct_TS)

setwd("~/Data Science/DATATHLON/Files/DataV3")
rm(list = ls())
library(ggplot2)
library(reshape2)
library(reshape)
library(randomForest)

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

MATRIX_Final <- merge(MATRIX.c, truck_amount.c, by = "DT_STA_LIV_PSG", all.x = TRUE)
MATRIX_Final$DAY <- weekdays(as.Date(MATRIX_Final$DT_STA_LIV_PSG))
MATRIX_Final$YEAR <- as.numeric(format(MATRIX_Final$DT_STA_LIV_PSG,"%Y"))
MATRIX_Final$MONTH <- as.numeric(format(MATRIX_Final$DT_STA_LIV_PSG,"%m"))

set.seed(171)
index <- sample(1:nrow(MATRIX_Final),size = 0.7*nrow(MATRIX_Final))
train <- MATRIX_Final[index,]
test <- MATRIX_Final [-index,]
str(test)
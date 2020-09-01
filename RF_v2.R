rm(list = ls())
library(ggplot2)
library(reshape2)
library(reshape)
library(randomForest)
library(caret)
library(e1071)
library(zoo)

#-------------------------------------------TRAIN DATA PREP------------------------------------------------------------
#Importing and preparing variables
truck_amount <- read.csv("truck_amount.csv", sep=";")
truck_amount$DT_STA_LIV_PSG <- as.Date(truck_amount$DT_STA_LIV_PSG, format = "%d/%m/%Y")
fdm_orders_timed_train <- read.csv("fdm_orders_timed_train.csv", sep=";")
fdm_orders_timed_train$DT_STA_LIV_PSG <- as.Date(fdm_orders_timed_train$DT_STA_LIV_PSG, format = "%d/%m/%Y")
fdm_orders_timed_train$before_10 <- as.logical(fdm_orders_timed_train$before_10)
TRAIN <- fdm_orders_timed_train
colnames(TRAIN)[4] <- "CAI_CODE"
client_referential <- read.csv("client_referential.csv", sep=";")
product_referential <- read.csv("product_referential.csv", sep=";")
TRAIN <- merge(TRAIN, client_referential, by = "CLT_C", all.x = TRUE)
TRAIN <- merge(TRAIN, product_referential, by = "CAI_CODE", all.x = TRUE)
TRAIN$TOTAL_VOL <- TRAIN$ENG_QT * TRAIN$VOL

#Pivot the TRAIN
TRAIN.m <- melt(TRAIN, id=c(1:14), measure=c(15))
TRAIN.c <- cast(TRAIN.m, DT_STA_LIV_PSG + zone ~ before_10, sum)
colnames(TRAIN.c)[3] <- "after_10"
colnames(TRAIN.c)[4] <- "before_10"

#Add truck_amount, pivoting...
truck_amount.m <- melt(truck_amount, id=c(2:4), measure=c(1))
truck_amount.c <- cast(truck_amount.m, DT_STA_LIV_PSG + zone ~ type, sum)

TRAIN_Final <- merge(TRAIN.c, truck_amount.c, by = c("DT_STA_LIV_PSG", "zone"), all.x = TRUE)
TRAIN_Final$DAY <- as.factor(weekdays(as.Date(TRAIN_Final$DT_STA_LIV_PSG)))
TRAIN_Final$YEAR <- as.numeric(format(TRAIN_Final$DT_STA_LIV_PSG,"%Y"))
TRAIN_Final$MONTH <- as.numeric(format(TRAIN_Final$DT_STA_LIV_PSG,"%m"))
#TRAIN_Final$DT_STA_LIV_PSG <- as.numeric(TRAIN_Final$DT_STA_LIV_PSG)
colnames(TRAIN_Final)[4] <- "before_10"
colnames(TRAIN_Final)[3] <- "after_10"
TRAIN_Final$DAY_QTE <- TRAIN_Final$after_10 + TRAIN_Final$before_10
TRAIN_Final$after_10 <- NULL

#Final IDF Trainning Files
TRAIN_Final_IDF <- TRAIN_Final[TRAIN_Final$zone == "IDF",]
TRAIN_Final_IDF <- TRAIN_Final_IDF[order(as.Date(TRAIN_Final_IDF$DT_STA_LIV_PSG, format="%d/%m/%Y")),]
TRAIN_Final_IDF$DAY_QTE_lag1 <- c(NA, head(TRAIN_Final_IDF$DAY_QTE, -1))
TRAIN_Final_IDF$DAY_QTE_lag2<- c(NA, head(TRAIN_Final_IDF$DAY_QTE_lag1, -1))
TRAIN_Final_IDF$DAY_QTE_lag3<- c(NA, head(TRAIN_Final_IDF$DAY_QTE_lag2, -1))
TRAIN_Final_IDF$DAY_QTE_lag4<- c(NA, head(TRAIN_Final_IDF$DAY_QTE_lag3, -1))
TRAIN_Final_IDF$DAY_QTE <- NULL

TRAIN_Final_IDF$direct_lag1 <- c(NA, head(TRAIN_Final_IDF$direct, -1))
TRAIN_Final_IDF$direct_lag2<- c(NA, head(TRAIN_Final_IDF$direct_lag1, -1))
TRAIN_Final_IDF$direct_lag3<- c(NA, head(TRAIN_Final_IDF$direct_lag2, -1))
TRAIN_Final_IDF$direct_lag4<- c(NA, head(TRAIN_Final_IDF$direct_lag3, -1))

TRAIN_Final_IDF$marguerite_lag1 <- c(NA, head(TRAIN_Final_IDF$marguerite, -1))
TRAIN_Final_IDF$marguerite_lag2<- c(NA, head(TRAIN_Final_IDF$marguerite_lag1, -1))
TRAIN_Final_IDF$marguerite_lag3<- c(NA, head(TRAIN_Final_IDF$marguerite_lag2, -1))
TRAIN_Final_IDF$marguerite_lag4<- c(NA, head(TRAIN_Final_IDF$marguerite_lag3, -1))

TRAIN_Final_IDF$third_party_lag1 <- c(NA, head(TRAIN_Final_IDF$third_party, -1))
TRAIN_Final_IDF$third_party_lag2<- c(NA, head(TRAIN_Final_IDF$third_party_lag1, -1))
TRAIN_Final_IDF$third_party_lag3<- c(NA, head(TRAIN_Final_IDF$third_party_lag2, -1))
TRAIN_Final_IDF$third_party_lag4<- c(NA, head(TRAIN_Final_IDF$third_party_lag3, -1))
TRAIN_Final_IDF <- TRAIN_Final_IDF[-c(1:4), ]

#Final nord Trainning Files
TRAIN_Final_nord <- TRAIN_Final[TRAIN_Final$zone == "nord",]
TRAIN_Final_nord <- TRAIN_Final_nord[order(as.Date(TRAIN_Final_nord$DT_STA_LIV_PSG, format="%d/%m/%Y")),]
TRAIN_Final_nord$DAY_QTE_lag1 <- c(NA, head(TRAIN_Final_nord$DAY_QTE, -1))
TRAIN_Final_nord$DAY_QTE_lag2<- c(NA, head(TRAIN_Final_nord$DAY_QTE_lag1, -1))
TRAIN_Final_nord$DAY_QTE_lag3<- c(NA, head(TRAIN_Final_nord$DAY_QTE_lag2, -1))
TRAIN_Final_nord$DAY_QTE_lag4<- c(NA, head(TRAIN_Final_nord$DAY_QTE_lag3, -1))
TRAIN_Final_nord$DAY_QTE <- NULL

TRAIN_Final_nord$direct_lag1 <- c(NA, head(TRAIN_Final_nord$direct, -1))
TRAIN_Final_nord$direct_lag2<- c(NA, head(TRAIN_Final_nord$direct_lag1, -1))
TRAIN_Final_nord$direct_lag3<- c(NA, head(TRAIN_Final_nord$direct_lag2, -1))
TRAIN_Final_nord$direct_lag4<- c(NA, head(TRAIN_Final_nord$direct_lag3, -1))

TRAIN_Final_nord$marguerite_lag1 <- c(NA, head(TRAIN_Final_nord$marguerite, -1))
TRAIN_Final_nord$marguerite_lag2<- c(NA, head(TRAIN_Final_nord$marguerite_lag1, -1))
TRAIN_Final_nord$marguerite_lag3<- c(NA, head(TRAIN_Final_nord$marguerite_lag2, -1))
TRAIN_Final_nord$marguerite_lag4<- c(NA, head(TRAIN_Final_nord$marguerite_lag3, -1))

TRAIN_Final_nord$third_party_lag1 <- c(NA, head(TRAIN_Final_nord$third_party, -1))
TRAIN_Final_nord$third_party_lag2<- c(NA, head(TRAIN_Final_nord$third_party_lag1, -1))
TRAIN_Final_nord$third_party_lag3<- c(NA, head(TRAIN_Final_nord$third_party_lag2, -1))
TRAIN_Final_nord$third_party_lag4<- c(NA, head(TRAIN_Final_nord$third_party_lag3, -1))
TRAIN_Final_nord <- TRAIN_Final_nord[-c(1:4), ]

#Final ouest Trainning Files
TRAIN_Final_ouest <- TRAIN_Final[TRAIN_Final$zone == "ouest",]
TRAIN_Final_ouest <- TRAIN_Final_ouest[order(as.Date(TRAIN_Final_ouest$DT_STA_LIV_PSG, format="%d/%m/%Y")),]
TRAIN_Final_ouest$DAY_QTE_lag1 <- c(NA, head(TRAIN_Final_ouest$DAY_QTE, -1))
TRAIN_Final_ouest$DAY_QTE_lag2<- c(NA, head(TRAIN_Final_ouest$DAY_QTE_lag1, -1))
TRAIN_Final_ouest$DAY_QTE_lag3<- c(NA, head(TRAIN_Final_ouest$DAY_QTE_lag2, -1))
TRAIN_Final_ouest$DAY_QTE_lag4<- c(NA, head(TRAIN_Final_ouest$DAY_QTE_lag3, -1))
TRAIN_Final_ouest$DAY_QTE <- NULL

TRAIN_Final_ouest$direct_lag1 <- c(NA, head(TRAIN_Final_ouest$direct, -1))
TRAIN_Final_ouest$direct_lag2<- c(NA, head(TRAIN_Final_ouest$direct_lag1, -1))
TRAIN_Final_ouest$direct_lag3<- c(NA, head(TRAIN_Final_ouest$direct_lag2, -1))
TRAIN_Final_ouest$direct_lag4<- c(NA, head(TRAIN_Final_ouest$direct_lag3, -1))

TRAIN_Final_ouest$marguerite_lag1 <- c(NA, head(TRAIN_Final_ouest$marguerite, -1))
TRAIN_Final_ouest$marguerite_lag2<- c(NA, head(TRAIN_Final_ouest$marguerite_lag1, -1))
TRAIN_Final_ouest$marguerite_lag3<- c(NA, head(TRAIN_Final_ouest$marguerite_lag2, -1))
TRAIN_Final_ouest$marguerite_lag4<- c(NA, head(TRAIN_Final_ouest$marguerite_lag3, -1))

TRAIN_Final_ouest$third_party_lag1 <- c(NA, head(TRAIN_Final_ouest$third_party, -1))
TRAIN_Final_ouest$third_party_lag2<- c(NA, head(TRAIN_Final_ouest$third_party_lag1, -1))
TRAIN_Final_ouest$third_party_lag3<- c(NA, head(TRAIN_Final_ouest$third_party_lag2, -1))
TRAIN_Final_ouest$third_party_lag4<- c(NA, head(TRAIN_Final_ouest$third_party_lag3, -1))
TRAIN_Final_ouest <- TRAIN_Final_ouest[-c(1:4), ]

rm(TRAIN.c, TRAIN.m, client_referential, fdm_orders_timed_train, product_referential, TRAIN, TRAIN_Final, truck_amount,
   truck_amount.c, truck_amount.m)

#-----------------------------------------END OF TRAIN DATA PREP------------------------------------------------------

#-------------------------------------------TEST DATA PREP------------------------------------------------------------
#Importing and preparing variables test sets
for (i in 1:5) {
  trucks = paste("truck_amount_test_day",i,".csv",sep="")
  orders = paste("orders_test_day",i,".csv",sep="")
  truck_amount_test_dayi <- read.csv(trucks, sep=";")
  truck_amount_test_dayi$DT_STA_LIV_PSG <- as.Date(truck_amount_test_dayi$DT_STA_LIV_PSG, format = "%d/%m/%Y")
  orders_test_dayi <- read.csv(orders, sep=";")
  orders_test_dayi$DT_STA_LIV_PSG <- as.Date(orders_test_dayi$DT_STA_LIV_PSG, format = "%d/%m/%Y")
  orders_test_dayi$before_10 <- as.logical(orders_test_dayi$before_10)
  TEST <- orders_test_dayi
  colnames(TEST)[4] <- "CAI_CODE"
  client_referential <- read.csv("client_referential.csv", sep=";")
  product_referential <- read.csv("product_referential.csv", sep=";")
  TEST <- merge(TEST, client_referential, by = "CLT_C", all.x = TRUE)
  TEST <- merge(TEST, product_referential, by = "CAI_CODE", all.x = TRUE)
  TEST$TOTAL_VOL <- TEST$ENG_QT * TEST$VOL
  
  #Pivot the TEST
  TEST.m <- melt(TEST, id=c(1:14), measure=c(15))
  TEST.c <- cast(TEST.m, DT_STA_LIV_PSG + zone ~ before_10, sum)
  colnames(TEST.c)[3] <- "after_10"
  colnames(TEST.c)[4] <- "before_10"
  
  #Add truck_amount_test_dayi, pivoting...
  truck_amount_test_dayi.m <- melt(truck_amount_test_dayi, id=c(2:4), measure=c(1))
  truck_amount_test_dayi.c <- cast(truck_amount_test_dayi.m, DT_STA_LIV_PSG + zone ~ type, sum)
  
  TEST_Final <- merge(TEST.c, truck_amount_test_dayi.c, by = c("DT_STA_LIV_PSG", "zone"), all.x = TRUE)
  TEST_Final$DAY <- as.factor(weekdays(as.Date(TEST_Final$DT_STA_LIV_PSG)))
  TEST_Final$YEAR <- as.numeric(format(TEST_Final$DT_STA_LIV_PSG,"%Y"))
  TEST_Final$MONTH <- as.numeric(format(TEST_Final$DT_STA_LIV_PSG,"%m"))
  #TEST_Final$DT_STA_LIV_PSG <- as.numeric(TEST_Final$DT_STA_LIV_PSG)
  colnames(TEST_Final)[4] <- "before_10"
  colnames(TEST_Final)[3] <- "after_10"
  TEST_Final$DAY_QTE <- TEST_Final$after_10 + TEST_Final$before_10
  TEST_Final$after_10 <- NULL
  
  #Final IDF TESTning Files
  TEST_Final_IDF <- TEST_Final[TEST_Final$zone == "IDF",]
  TEST_Final_IDF <- TEST_Final_IDF[order(as.Date(TEST_Final_IDF$DT_STA_LIV_PSG, format="%d/%m/%Y")),]
  TEST_Final_IDF$DAY_QTE_lag1 <- c(NA, head(TEST_Final_IDF$DAY_QTE, -1))
  TEST_Final_IDF$DAY_QTE_lag2<- c(NA, head(TEST_Final_IDF$DAY_QTE_lag1, -1))
  TEST_Final_IDF$DAY_QTE_lag3<- c(NA, head(TEST_Final_IDF$DAY_QTE_lag2, -1))
  TEST_Final_IDF$DAY_QTE_lag4<- c(NA, head(TEST_Final_IDF$DAY_QTE_lag3, -1))
  TEST_Final_IDF$DAY_QTE <- NULL
  
  TEST_Final_IDF$direct_lag1 <- c(NA, head(TEST_Final_IDF$direct, -1))
  TEST_Final_IDF$direct_lag2<- c(NA, head(TEST_Final_IDF$direct_lag1, -1))
  TEST_Final_IDF$direct_lag3<- c(NA, head(TEST_Final_IDF$direct_lag2, -1))
  TEST_Final_IDF$direct_lag4<- c(NA, head(TEST_Final_IDF$direct_lag3, -1))
  
  TEST_Final_IDF$marguerite_lag1 <- c(NA, head(TEST_Final_IDF$marguerite, -1))
  TEST_Final_IDF$marguerite_lag2<- c(NA, head(TEST_Final_IDF$marguerite_lag1, -1))
  TEST_Final_IDF$marguerite_lag3<- c(NA, head(TEST_Final_IDF$marguerite_lag2, -1))
  TEST_Final_IDF$marguerite_lag4<- c(NA, head(TEST_Final_IDF$marguerite_lag3, -1))
  
  TEST_Final_IDF$third_party_lag1 <- c(NA, head(TEST_Final_IDF$third_party, -1))
  TEST_Final_IDF$third_party_lag2<- c(NA, head(TEST_Final_IDF$third_party_lag1, -1))
  TEST_Final_IDF$third_party_lag3<- c(NA, head(TEST_Final_IDF$third_party_lag2, -1))
  TEST_Final_IDF$third_party_lag4<- c(NA, head(TEST_Final_IDF$third_party_lag3, -1))
  assign(paste("TEST_Final_IDF_day",i,sep=""),TEST_Final_IDF[-c(1:4), ])
  
  
  #Final nord TESTning Files
  TEST_Final_nord <- TEST_Final[TEST_Final$zone == "nord",]
  TEST_Final_nord <- TEST_Final_nord[order(as.Date(TEST_Final_nord$DT_STA_LIV_PSG, format="%d/%m/%Y")),]
  TEST_Final_nord$DAY_QTE_lag1 <- c(NA, head(TEST_Final_nord$DAY_QTE, -1))
  TEST_Final_nord$DAY_QTE_lag2<- c(NA, head(TEST_Final_nord$DAY_QTE_lag1, -1))
  TEST_Final_nord$DAY_QTE_lag3<- c(NA, head(TEST_Final_nord$DAY_QTE_lag2, -1))
  TEST_Final_nord$DAY_QTE_lag4<- c(NA, head(TEST_Final_nord$DAY_QTE_lag3, -1))
  TEST_Final_nord$DAY_QTE <- NULL
  
  TEST_Final_nord$direct_lag1 <- c(NA, head(TEST_Final_nord$direct, -1))
  TEST_Final_nord$direct_lag2<- c(NA, head(TEST_Final_nord$direct_lag1, -1))
  TEST_Final_nord$direct_lag3<- c(NA, head(TEST_Final_nord$direct_lag2, -1))
  TEST_Final_nord$direct_lag4<- c(NA, head(TEST_Final_nord$direct_lag3, -1))
  
  TEST_Final_nord$marguerite_lag1 <- c(NA, head(TEST_Final_nord$marguerite, -1))
  TEST_Final_nord$marguerite_lag2<- c(NA, head(TEST_Final_nord$marguerite_lag1, -1))
  TEST_Final_nord$marguerite_lag3<- c(NA, head(TEST_Final_nord$marguerite_lag2, -1))
  TEST_Final_nord$marguerite_lag4<- c(NA, head(TEST_Final_nord$marguerite_lag3, -1))
  
  TEST_Final_nord$third_party_lag1 <- c(NA, head(TEST_Final_nord$third_party, -1))
  TEST_Final_nord$third_party_lag2<- c(NA, head(TEST_Final_nord$third_party_lag1, -1))
  TEST_Final_nord$third_party_lag3<- c(NA, head(TEST_Final_nord$third_party_lag2, -1))
  TEST_Final_nord$third_party_lag4<- c(NA, head(TEST_Final_nord$third_party_lag3, -1))
  assign(paste("TEST_Final_nord_day",i,sep=""),TEST_Final_nord[-c(1:4), ])
  
  #Final ouest TESTning Files
  TEST_Final_ouest <- TEST_Final[TEST_Final$zone == "ouest",]
  TEST_Final_ouest <- TEST_Final_ouest[order(as.Date(TEST_Final_ouest$DT_STA_LIV_PSG, format="%d/%m/%Y")),]
  TEST_Final_ouest$DAY_QTE_lag1 <- c(NA, head(TEST_Final_ouest$DAY_QTE, -1))
  TEST_Final_ouest$DAY_QTE_lag2<- c(NA, head(TEST_Final_ouest$DAY_QTE_lag1, -1))
  TEST_Final_ouest$DAY_QTE_lag3<- c(NA, head(TEST_Final_ouest$DAY_QTE_lag2, -1))
  TEST_Final_ouest$DAY_QTE_lag4<- c(NA, head(TEST_Final_ouest$DAY_QTE_lag3, -1))
  TEST_Final_ouest$DAY_QTE <- NULL
  
  TEST_Final_ouest$direct_lag1 <- c(NA, head(TEST_Final_ouest$direct, -1))
  TEST_Final_ouest$direct_lag2<- c(NA, head(TEST_Final_ouest$direct_lag1, -1))
  TEST_Final_ouest$direct_lag3<- c(NA, head(TEST_Final_ouest$direct_lag2, -1))
  TEST_Final_ouest$direct_lag4<- c(NA, head(TEST_Final_ouest$direct_lag3, -1))
  
  TEST_Final_ouest$marguerite_lag1 <- c(NA, head(TEST_Final_ouest$marguerite, -1))
  TEST_Final_ouest$marguerite_lag2<- c(NA, head(TEST_Final_ouest$marguerite_lag1, -1))
  TEST_Final_ouest$marguerite_lag3<- c(NA, head(TEST_Final_ouest$marguerite_lag2, -1))
  TEST_Final_ouest$marguerite_lag4<- c(NA, head(TEST_Final_ouest$marguerite_lag3, -1))
  
  TEST_Final_ouest$third_party_lag1 <- c(NA, head(TEST_Final_ouest$third_party, -1))
  TEST_Final_ouest$third_party_lag2<- c(NA, head(TEST_Final_ouest$third_party_lag1, -1))
  TEST_Final_ouest$third_party_lag3<- c(NA, head(TEST_Final_ouest$third_party_lag2, -1))
  TEST_Final_ouest$third_party_lag4<- c(NA, head(TEST_Final_ouest$third_party_lag3, -1))
  assign(paste("TEST_Final_ouest_day",i,sep=""),TEST_Final_ouest[-c(1:4), ])
}

JOINT <- rbind(TEST_Final_ouest_day1,TEST_Final_ouest_day2,TEST_Final_ouest_day3,TEST_Final_ouest_day4,TEST_Final_ouest_day5,TRAIN_Final_ouest)
rm(TEST_Final_ouest)
TEST_Final_ouest <- JOINT[is.na(JOINT$direct),]
rm(JOINT)

JOINT <- rbind(TEST_Final_nord_day1,TEST_Final_nord_day2,TEST_Final_nord_day3,TEST_Final_nord_day4,TEST_Final_nord_day5,TRAIN_Final_nord)
rm(TEST_Final_nord)
TEST_Final_nord <- JOINT[is.na(JOINT$direct),]
rm(JOINT)

JOINT <- rbind(TEST_Final_IDF_day1,TEST_Final_IDF_day2,TEST_Final_IDF_day3,TEST_Final_IDF_day4,TEST_Final_IDF_day5,TRAIN_Final_IDF)
rm(TEST_Final_IDF)
TEST_Final_IDF <- JOINT[is.na(JOINT$direct),]
rm(JOINT)

rm(client_referential, orders_test_dayi, product_referential, TEST, TEST_Final, TEST_Final_IDF_day1, TEST_Final_IDF_day2, TEST_Final_IDF_day3,
   TEST_Final_IDF_day4, TEST_Final_IDF_day5, TEST_Final_nord_day1, TEST_Final_nord_day2, TEST_Final_nord_day3, TEST_Final_nord_day4,
   TEST_Final_nord_day5, TEST_Final_ouest_day1, TEST_Final_ouest_day2, TEST_Final_ouest_day3, TEST_Final_ouest_day4, TEST_Final_ouest_day5,
   TEST.c, TEST.m, truck_amount_test_dayi, truck_amount_test_dayi.c, truck_amount_test_dayi.m, i, orders, trucks)

#-----------------------------------------END OF TEST DATA PREP------------------------------------------------------

#IDF
third_party_IDF <- randomForest(third_party ~ before_10 + DAY + YEAR + MONTH + DAY_QTE_lag1 + DAY_QTE_lag2 + DAY_QTE_lag3 + 
                                  DAY_QTE_lag4 + direct_lag1 + direct_lag2 + direct_lag3 + direct_lag4 + marguerite_lag1 + 
                                  marguerite_lag2 + marguerite_lag3 + marguerite_lag4 + third_party_lag1 + third_party_lag2 + 
                                  third_party_lag3 + third_party_lag4 - DAY_QTE_lag1, data=TRAIN_Final_IDF,
                                proximity=TRUE, ntree=500)

direct_IDF <- randomForest(direct ~ before_10 + DAY + YEAR + MONTH + DAY_QTE_lag1 + DAY_QTE_lag2 + DAY_QTE_lag3 + 
                             DAY_QTE_lag4 + direct_lag1 + direct_lag2 + direct_lag3 + direct_lag4 + marguerite_lag1 + 
                             marguerite_lag2 + marguerite_lag3 + marguerite_lag4 + third_party_lag1 + third_party_lag2 + 
                             third_party_lag3 + third_party_lag4 - DAY_QTE_lag1, data=TRAIN_Final_IDF,
                           proximity=TRUE, ntree=500)

#nord
marguerite_nord <- randomForest(marguerite ~ before_10 + DAY + YEAR + MONTH + DAY_QTE_lag1 + DAY_QTE_lag2 + DAY_QTE_lag3 + 
                                  DAY_QTE_lag4 + direct_lag1 + direct_lag2 + direct_lag3 + direct_lag4 + marguerite_lag1 + 
                                  marguerite_lag2 + marguerite_lag3 + marguerite_lag4 + third_party_lag1 + third_party_lag2 + 
                                  third_party_lag3 + third_party_lag4 - DAY_QTE_lag1, data=TRAIN_Final_nord,
                                proximity=TRUE, ntree=500)

direct_nord <- randomForest(direct ~ before_10 + DAY + YEAR + MONTH + DAY_QTE_lag1 + DAY_QTE_lag2 + DAY_QTE_lag3 + 
                              DAY_QTE_lag4 + direct_lag1 + direct_lag2 + direct_lag3 + direct_lag4 + marguerite_lag1 + 
                              marguerite_lag2 + marguerite_lag3 + marguerite_lag4 + third_party_lag1 + third_party_lag2 + 
                              third_party_lag3 + third_party_lag4 - DAY_QTE_lag1, data=TRAIN_Final_nord,
                            proximity=TRUE, ntree=500)

#ouest
third_party_ouest <- randomForest(third_party ~ before_10 + DAY + YEAR + MONTH + DAY_QTE_lag1 + DAY_QTE_lag2 + DAY_QTE_lag3 + 
                                    DAY_QTE_lag4 + direct_lag1 + direct_lag2 + direct_lag3 + direct_lag4 + marguerite_lag1 + 
                                    marguerite_lag2 + marguerite_lag3 + marguerite_lag4 + third_party_lag1 + third_party_lag2 + 
                                    third_party_lag3 + third_party_lag4 - DAY_QTE_lag1, data=TRAIN_Final_ouest,
                                  proximity=TRUE, ntree=500)

direct_ouest <- randomForest(direct ~ before_10 + DAY + YEAR + MONTH + DAY_QTE_lag1 + DAY_QTE_lag2 + DAY_QTE_lag3 + 
                               DAY_QTE_lag4 + direct_lag1 + direct_lag2 + direct_lag3 + direct_lag4 + marguerite_lag1 + 
                               marguerite_lag2 + marguerite_lag3 + marguerite_lag4 + third_party_lag1 + third_party_lag2 + 
                               third_party_lag3 + third_party_lag4 - DAY_QTE_lag1, data=TRAIN_Final_ouest,
                             proximity=TRUE, ntree=500)




#(predict(third_party_IDF, TEST_Final_IDF))
#round(predict(direct_IDF, TEST_Final_IDF))

#round(predict(marguerite_nord, TEST_Final_nord))
#round(predict(direct_nord, TEST_Final_nord))

#round(predict(third_party_ouest, TEST_Final_ouest))
#round(predict(direct_ouest, TEST_Final_ouest))

CSV_Final_IDF_direct <- TEST_Final_IDF[c(1,2)]
CSV_Final_IDF_direct$TYPE <- "direct"
CSV_Final_IDF_direct$QUANTITY <-  round(predict(direct_IDF, TEST_Final_IDF))
colnames(CSV_Final_IDF_direct)[1] <- "DATE_ORDER"
colnames(CSV_Final_IDF_direct)[2] <- "REGION"

CSV_Final_IDF_third_party <- TEST_Final_IDF[c(1,2)]
CSV_Final_IDF_third_party$TYPE <- "third_party"
CSV_Final_IDF_third_party$QUANTITY <-  round(predict(third_party_IDF, TEST_Final_IDF))
colnames(CSV_Final_IDF_third_party)[1] <- "DATE_ORDER"
colnames(CSV_Final_IDF_third_party)[2] <- "REGION"

CSV_Final_ouest_direct <- TEST_Final_ouest[c(1,2)]
CSV_Final_ouest_direct$TYPE <- "direct"
CSV_Final_ouest_direct$QUANTITY <-  round(predict(direct_ouest, TEST_Final_ouest))
colnames(CSV_Final_ouest_direct)[1] <- "DATE_ORDER"
colnames(CSV_Final_ouest_direct)[2] <- "REGION"

CSV_Final_ouest_third_party <- TEST_Final_ouest[c(1,2)]
CSV_Final_ouest_third_party$TYPE <- "third_party"
CSV_Final_ouest_third_party$QUANTITY <-  round(predict(third_party_ouest, TEST_Final_ouest))
colnames(CSV_Final_ouest_third_party)[1] <- "DATE_ORDER"
colnames(CSV_Final_ouest_third_party)[2] <- "REGION"

CSV_Final_nord_direct <- TEST_Final_nord[c(1,2)]
CSV_Final_nord_direct$TYPE <- "direct"
CSV_Final_nord_direct$QUANTITY <-  round(predict(direct_nord, TEST_Final_nord))
colnames(CSV_Final_nord_direct)[1] <- "DATE_ORDER"
colnames(CSV_Final_nord_direct)[2] <- "REGION"

CSV_Final_nord_marguerite <- TEST_Final_nord[c(1,2)]
CSV_Final_nord_marguerite$TYPE <- "marguerite"
CSV_Final_nord_marguerite$QUANTITY <-  round(predict(marguerite_nord, TEST_Final_nord))
colnames(CSV_Final_nord_marguerite)[1] <- "DATE_ORDER"
colnames(CSV_Final_nord_marguerite)[2] <- "REGION"

CSV_Final_nord_third_party <- TEST_Final_nord[c(1,2)]
CSV_Final_nord_third_party$TYPE <- "third_party"
CSV_Final_nord_third_party$QUANTITY <-  0
colnames(CSV_Final_nord_third_party)[1] <- "DATE_ORDER"
colnames(CSV_Final_nord_third_party)[2] <- "REGION"

CSV_Final_IDF_marguerite <- TEST_Final_IDF[c(1,2)]
CSV_Final_IDF_marguerite$TYPE <- "marguerite"
CSV_Final_IDF_marguerite$QUANTITY <-  0
colnames(CSV_Final_IDF_marguerite)[1] <- "DATE_ORDER"
colnames(CSV_Final_IDF_marguerite)[2] <- "REGION"

CSV_Final_ouest_marguerite <- TEST_Final_ouest[c(1,2)]
CSV_Final_ouest_marguerite$TYPE <- "marguerite"
CSV_Final_ouest_marguerite$QUANTITY <-  0
colnames(CSV_Final_ouest_marguerite)[1] <- "DATE_ORDER"
colnames(CSV_Final_ouest_marguerite)[2] <- "REGION"

CSV_FINAL <- rbind(CSV_Final_IDF_direct, CSV_Final_IDF_third_party, CSV_Final_ouest_direct, CSV_Final_ouest_third_party ,
                   CSV_Final_nord_direct, CSV_Final_nord_marguerite, CSV_Final_ouest_marguerite, CSV_Final_IDF_marguerite,
                   CSV_Final_nord_third_party)

rm(CSV_Final_IDF_direct, CSV_Final_IDF_marguerite, CSV_Final_IDF_third_party, CSV_Final_nord_direct, CSV_Final_nord_marguerite,
   CSV_Final_nord_third_party, CSV_Final_ouest_direct, CSV_Final_ouest_marguerite, CSV_Final_ouest_third_party)

write.csv2(CSV_FINAL, "RF_Model.csv", row.names = FALSE)
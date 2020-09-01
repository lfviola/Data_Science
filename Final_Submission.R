#-------------------------------------------EVAL DATA PREP------------------------------------------------------------
#Importing and preparing variables test sets
for (i in 1:5) {
  trucks = paste("truck_amount_eval_day",i,".csv",sep="")
  orders = paste("orders_eval_day",i,".csv",sep="")
  truck_amount_eval_dayi <- read.csv(trucks, sep=";")
  truck_amount_eval_dayi$DT_STA_LIV_PSG <- as.Date(truck_amount_eval_dayi$DT_STA_LIV_PSG, format = "%d/%m/%Y")
  orders_eval_dayi <- read.csv(orders, sep=";")
  orders_eval_dayi$DT_STA_LIV_PSG <- as.Date(orders_eval_dayi$DT_STA_LIV_PSG, format = "%d/%m/%Y")
  orders_eval_dayi$before_10 <- as.logical(orders_eval_dayi$before_10)
  EVAL <- orders_eval_dayi
  colnames(EVAL)[4] <- "CAI_CODE"
  client_referential <- read.csv("client_referential.csv", sep=";")
  product_referential <- read.csv("product_referential.csv", sep=";")
  EVAL <- merge(EVAL, client_referential, by = "CLT_C", all.x = TRUE)
  EVAL <- merge(EVAL, product_referential, by = "CAI_CODE", all.x = TRUE)
  EVAL$TOTAL_VOL <- EVAL$ENG_QT * EVAL$VOL
  
  #Pivot the EVAL
  EVAL.m <- melt(EVAL, id=c(1:14), measure=c(15))
  EVAL.c <- cast(EVAL.m, DT_STA_LIV_PSG + zone ~ before_10, sum)
  colnames(EVAL.c)[3] <- "after_10"
  colnames(EVAL.c)[4] <- "before_10"
  
  #Add truck_amount_eval_dayi, pivoting...
  truck_amount_eval_dayi.m <- melt(truck_amount_eval_dayi, id=c(2:4), measure=c(1))
  truck_amount_eval_dayi.c <- cast(truck_amount_eval_dayi.m, DT_STA_LIV_PSG + zone ~ type, sum)
  
  EVAL_Final <- merge(EVAL.c, truck_amount_eval_dayi.c, by = c("DT_STA_LIV_PSG", "zone"), all.x = TRUE)
  EVAL_Final$DAY <- as.factor(weekdays(as.Date(EVAL_Final$DT_STA_LIV_PSG)))
  EVAL_Final$YEAR <- as.numeric(format(EVAL_Final$DT_STA_LIV_PSG,"%Y"))
  EVAL_Final$MONTH <- as.numeric(format(EVAL_Final$DT_STA_LIV_PSG,"%m"))
  #EVAL_Final$DT_STA_LIV_PSG <- as.numeric(EVAL_Final$DT_STA_LIV_PSG)
  colnames(EVAL_Final)[4] <- "before_10"
  colnames(EVAL_Final)[3] <- "after_10"
  EVAL_Final$DAY_QTE <- EVAL_Final$after_10 + EVAL_Final$before_10
  EVAL_Final$after_10 <- NULL
  
  #Final IDF EVALning Files
  EVAL_Final_IDF <- EVAL_Final[EVAL_Final$zone == "IDF",]
  EVAL_Final_IDF <- EVAL_Final_IDF[order(as.Date(EVAL_Final_IDF$DT_STA_LIV_PSG, format="%d/%m/%Y")),]
  EVAL_Final_IDF$DAY_QTE_lag1 <- c(NA, head(EVAL_Final_IDF$DAY_QTE, -1))
  EVAL_Final_IDF$DAY_QTE_lag2<- c(NA, head(EVAL_Final_IDF$DAY_QTE_lag1, -1))
  EVAL_Final_IDF$DAY_QTE_lag3<- c(NA, head(EVAL_Final_IDF$DAY_QTE_lag2, -1))
  EVAL_Final_IDF$DAY_QTE_lag4<- c(NA, head(EVAL_Final_IDF$DAY_QTE_lag3, -1))
  EVAL_Final_IDF$DAY_QTE <- NULL
  
  EVAL_Final_IDF$direct_lag1 <- c(NA, head(EVAL_Final_IDF$direct, -1))
  EVAL_Final_IDF$direct_lag2<- c(NA, head(EVAL_Final_IDF$direct_lag1, -1))
  EVAL_Final_IDF$direct_lag3<- c(NA, head(EVAL_Final_IDF$direct_lag2, -1))
  EVAL_Final_IDF$direct_lag4<- c(NA, head(EVAL_Final_IDF$direct_lag3, -1))
  
  EVAL_Final_IDF$marguerite_lag1 <- c(NA, head(EVAL_Final_IDF$marguerite, -1))
  EVAL_Final_IDF$marguerite_lag2<- c(NA, head(EVAL_Final_IDF$marguerite_lag1, -1))
  EVAL_Final_IDF$marguerite_lag3<- c(NA, head(EVAL_Final_IDF$marguerite_lag2, -1))
  EVAL_Final_IDF$marguerite_lag4<- c(NA, head(EVAL_Final_IDF$marguerite_lag3, -1))
  
  EVAL_Final_IDF$third_party_lag1 <- c(NA, head(EVAL_Final_IDF$third_party, -1))
  EVAL_Final_IDF$third_party_lag2<- c(NA, head(EVAL_Final_IDF$third_party_lag1, -1))
  EVAL_Final_IDF$third_party_lag3<- c(NA, head(EVAL_Final_IDF$third_party_lag2, -1))
  EVAL_Final_IDF$third_party_lag4<- c(NA, head(EVAL_Final_IDF$third_party_lag3, -1))
  assign(paste("EVAL_Final_IDF_day",i,sep=""),EVAL_Final_IDF[-c(1:4), ])
  
  
  #Final nord EVALning Files
  EVAL_Final_nord <- EVAL_Final[EVAL_Final$zone == "nord",]
  EVAL_Final_nord <- EVAL_Final_nord[order(as.Date(EVAL_Final_nord$DT_STA_LIV_PSG, format="%d/%m/%Y")),]
  EVAL_Final_nord$DAY_QTE_lag1 <- c(NA, head(EVAL_Final_nord$DAY_QTE, -1))
  EVAL_Final_nord$DAY_QTE_lag2<- c(NA, head(EVAL_Final_nord$DAY_QTE_lag1, -1))
  EVAL_Final_nord$DAY_QTE_lag3<- c(NA, head(EVAL_Final_nord$DAY_QTE_lag2, -1))
  EVAL_Final_nord$DAY_QTE_lag4<- c(NA, head(EVAL_Final_nord$DAY_QTE_lag3, -1))
  EVAL_Final_nord$DAY_QTE <- NULL
  
  EVAL_Final_nord$direct_lag1 <- c(NA, head(EVAL_Final_nord$direct, -1))
  EVAL_Final_nord$direct_lag2<- c(NA, head(EVAL_Final_nord$direct_lag1, -1))
  EVAL_Final_nord$direct_lag3<- c(NA, head(EVAL_Final_nord$direct_lag2, -1))
  EVAL_Final_nord$direct_lag4<- c(NA, head(EVAL_Final_nord$direct_lag3, -1))
  
  EVAL_Final_nord$marguerite_lag1 <- c(NA, head(EVAL_Final_nord$marguerite, -1))
  EVAL_Final_nord$marguerite_lag2<- c(NA, head(EVAL_Final_nord$marguerite_lag1, -1))
  EVAL_Final_nord$marguerite_lag3<- c(NA, head(EVAL_Final_nord$marguerite_lag2, -1))
  EVAL_Final_nord$marguerite_lag4<- c(NA, head(EVAL_Final_nord$marguerite_lag3, -1))
  
  EVAL_Final_nord$third_party_lag1 <- c(NA, head(EVAL_Final_nord$third_party, -1))
  EVAL_Final_nord$third_party_lag2<- c(NA, head(EVAL_Final_nord$third_party_lag1, -1))
  EVAL_Final_nord$third_party_lag3<- c(NA, head(EVAL_Final_nord$third_party_lag2, -1))
  EVAL_Final_nord$third_party_lag4<- c(NA, head(EVAL_Final_nord$third_party_lag3, -1))
  assign(paste("EVAL_Final_nord_day",i,sep=""),EVAL_Final_nord[-c(1:4), ])
  
  #Final ouest EVALning Files
  EVAL_Final_ouest <- EVAL_Final[EVAL_Final$zone == "ouest",]
  EVAL_Final_ouest <- EVAL_Final_ouest[order(as.Date(EVAL_Final_ouest$DT_STA_LIV_PSG, format="%d/%m/%Y")),]
  EVAL_Final_ouest$DAY_QTE_lag1 <- c(NA, head(EVAL_Final_ouest$DAY_QTE, -1))
  EVAL_Final_ouest$DAY_QTE_lag2<- c(NA, head(EVAL_Final_ouest$DAY_QTE_lag1, -1))
  EVAL_Final_ouest$DAY_QTE_lag3<- c(NA, head(EVAL_Final_ouest$DAY_QTE_lag2, -1))
  EVAL_Final_ouest$DAY_QTE_lag4<- c(NA, head(EVAL_Final_ouest$DAY_QTE_lag3, -1))
  EVAL_Final_ouest$DAY_QTE <- NULL
  
  EVAL_Final_ouest$direct_lag1 <- c(NA, head(EVAL_Final_ouest$direct, -1))
  EVAL_Final_ouest$direct_lag2<- c(NA, head(EVAL_Final_ouest$direct_lag1, -1))
  EVAL_Final_ouest$direct_lag3<- c(NA, head(EVAL_Final_ouest$direct_lag2, -1))
  EVAL_Final_ouest$direct_lag4<- c(NA, head(EVAL_Final_ouest$direct_lag3, -1))
  
  EVAL_Final_ouest$marguerite_lag1 <- c(NA, head(EVAL_Final_ouest$marguerite, -1))
  EVAL_Final_ouest$marguerite_lag2<- c(NA, head(EVAL_Final_ouest$marguerite_lag1, -1))
  EVAL_Final_ouest$marguerite_lag3<- c(NA, head(EVAL_Final_ouest$marguerite_lag2, -1))
  EVAL_Final_ouest$marguerite_lag4<- c(NA, head(EVAL_Final_ouest$marguerite_lag3, -1))
  
  EVAL_Final_ouest$third_party_lag1 <- c(NA, head(EVAL_Final_ouest$third_party, -1))
  EVAL_Final_ouest$third_party_lag2<- c(NA, head(EVAL_Final_ouest$third_party_lag1, -1))
  EVAL_Final_ouest$third_party_lag3<- c(NA, head(EVAL_Final_ouest$third_party_lag2, -1))
  EVAL_Final_ouest$third_party_lag4<- c(NA, head(EVAL_Final_ouest$third_party_lag3, -1))
  assign(paste("EVAL_Final_ouest_day",i,sep=""),EVAL_Final_ouest[-c(1:4), ])
}

JOINT <- rbind(EVAL_Final_ouest_day1,EVAL_Final_ouest_day2,EVAL_Final_ouest_day3,EVAL_Final_ouest_day4,EVAL_Final_ouest_day5,TRAIN_Final_ouest)
rm(EVAL_Final_ouest)
EVAL_Final_ouest <- JOINT[is.na(JOINT$direct),]
rm(JOINT)

JOINT <- rbind(EVAL_Final_nord_day1,EVAL_Final_nord_day2,EVAL_Final_nord_day3,EVAL_Final_nord_day4,EVAL_Final_nord_day5,TRAIN_Final_nord)
rm(EVAL_Final_nord)
EVAL_Final_nord <- JOINT[is.na(JOINT$direct),]
rm(JOINT)

JOINT <- rbind(EVAL_Final_IDF_day1,EVAL_Final_IDF_day2,EVAL_Final_IDF_day3,EVAL_Final_IDF_day4,EVAL_Final_IDF_day5,TRAIN_Final_IDF)
rm(EVAL_Final_IDF)
EVAL_Final_IDF <- JOINT[is.na(JOINT$direct),]
rm(JOINT)

rm(client_referential, orders_eval_dayi, product_referential, EVAL, EVAL_Final, EVAL_Final_IDF_day1, EVAL_Final_IDF_day2, EVAL_Final_IDF_day3,
   EVAL_Final_IDF_day4, EVAL_Final_IDF_day5, EVAL_Final_nord_day1, EVAL_Final_nord_day2, EVAL_Final_nord_day3, EVAL_Final_nord_day4,
   EVAL_Final_nord_day5, EVAL_Final_ouest_day1, EVAL_Final_ouest_day2, EVAL_Final_ouest_day3, EVAL_Final_ouest_day4, EVAL_Final_ouest_day5,
   EVAL.c, EVAL.m, truck_amount_eval_dayi, truck_amount_eval_dayi.c, truck_amount_eval_dayi.m, i, orders, trucks)

#-----------------------------------------END OF TEST DATA PREP------------------------------------------------------


CSV_Final_IDF_direct <- EVAL_Final_IDF[c(1,2)]
CSV_Final_IDF_direct$TYPE <- "direct"
CSV_Final_IDF_direct$QUANTITY <-  round(predict(direct_IDF, EVAL_Final_IDF))
colnames(CSV_Final_IDF_direct)[1] <- "DATE_ORDER"
colnames(CSV_Final_IDF_direct)[2] <- "REGION"

CSV_Final_IDF_third_party <- EVAL_Final_IDF[c(1,2)]
CSV_Final_IDF_third_party$TYPE <- "third_party"
CSV_Final_IDF_third_party$QUANTITY <-  round(predict(third_party_IDF, EVAL_Final_IDF))
colnames(CSV_Final_IDF_third_party)[1] <- "DATE_ORDER"
colnames(CSV_Final_IDF_third_party)[2] <- "REGION"

CSV_Final_ouest_direct <- EVAL_Final_ouest[c(1,2)]
CSV_Final_ouest_direct$TYPE <- "direct"
CSV_Final_ouest_direct$QUANTITY <-  round(predict(direct_ouest, EVAL_Final_ouest))
colnames(CSV_Final_ouest_direct)[1] <- "DATE_ORDER"
colnames(CSV_Final_ouest_direct)[2] <- "REGION"

CSV_Final_ouest_third_party <- EVAL_Final_ouest[c(1,2)]
CSV_Final_ouest_third_party$TYPE <- "third_party"
CSV_Final_ouest_third_party$QUANTITY <-  round(predict(third_party_ouest, EVAL_Final_ouest))
colnames(CSV_Final_ouest_third_party)[1] <- "DATE_ORDER"
colnames(CSV_Final_ouest_third_party)[2] <- "REGION"

CSV_Final_nord_direct <- EVAL_Final_nord[c(1,2)]
CSV_Final_nord_direct$TYPE <- "direct"
CSV_Final_nord_direct$QUANTITY <-  round(predict(direct_nord, EVAL_Final_nord))
colnames(CSV_Final_nord_direct)[1] <- "DATE_ORDER"
colnames(CSV_Final_nord_direct)[2] <- "REGION"

CSV_Final_nord_marguerite <- EVAL_Final_nord[c(1,2)]
CSV_Final_nord_marguerite$TYPE <- "marguerite"
CSV_Final_nord_marguerite$QUANTITY <-  round(predict(marguerite_nord, EVAL_Final_nord))
colnames(CSV_Final_nord_marguerite)[1] <- "DATE_ORDER"
colnames(CSV_Final_nord_marguerite)[2] <- "REGION"

CSV_Final_nord_third_party <- EVAL_Final_nord[c(1,2)]
CSV_Final_nord_third_party$TYPE <- "third_party"
CSV_Final_nord_third_party$QUANTITY <-  0
colnames(CSV_Final_nord_third_party)[1] <- "DATE_ORDER"
colnames(CSV_Final_nord_third_party)[2] <- "REGION"

CSV_Final_IDF_marguerite <- EVAL_Final_IDF[c(1,2)]
CSV_Final_IDF_marguerite$TYPE <- "marguerite"
CSV_Final_IDF_marguerite$QUANTITY <-  0
colnames(CSV_Final_IDF_marguerite)[1] <- "DATE_ORDER"
colnames(CSV_Final_IDF_marguerite)[2] <- "REGION"

CSV_Final_ouest_marguerite <- EVAL_Final_ouest[c(1,2)]
CSV_Final_ouest_marguerite$TYPE <- "marguerite"
CSV_Final_ouest_marguerite$QUANTITY <-  0
colnames(CSV_Final_ouest_marguerite)[1] <- "DATE_ORDER"
colnames(CSV_Final_ouest_marguerite)[2] <- "REGION"

CSV_EVAL <- rbind(CSV_Final_IDF_direct, CSV_Final_IDF_third_party, CSV_Final_ouest_direct, CSV_Final_ouest_third_party ,
                  CSV_Final_nord_direct, CSV_Final_nord_marguerite, CSV_Final_ouest_marguerite, CSV_Final_IDF_marguerite,
                  CSV_Final_nord_third_party)

rm(CSV_Final_IDF_direct, CSV_Final_IDF_marguerite, CSV_Final_IDF_third_party, CSV_Final_nord_direct, CSV_Final_nord_marguerite,
   CSV_Final_nord_third_party, CSV_Final_ouest_direct, CSV_Final_ouest_marguerite, CSV_Final_ouest_third_party)

write.csv2(CSV_EVAL, "RF_Model_EVAL.csv", row.names = FALSE)
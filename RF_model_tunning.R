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


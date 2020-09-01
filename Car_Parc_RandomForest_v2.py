#http://mariofilho.com/how-to-predict-multiple-time-series-with-scikit-learn-with-sales-forecasting-example/

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import os
import glob
from sklearn import preprocessing
from sklearn.metrics import mean_squared_log_error
from sklearn.ensemble import RandomForestRegressor
pd.options.mode.chained_assignment = None

# Importing and preparing the dataset
os.chdir("C:/Users/F376267/Documents/Data Science/Car Park/ETRMA")
files = glob.glob("ETRMA-*.csv")
dfs = [pd.read_csv(f, header=None, sep=";") for f in files]
mkt_data = pd.concat(dfs,ignore_index=True)
del(dfs, files)

headers = pd.read_excel('2016 Libellé Fichier Marches ETRma_MO_modif HdV.xlsx')
Seat_Inches = pd.read_excel('Seat_Inches.xlsx', dtype={'Seat': str, 'Seat in inch': str})
headers = list(headers.columns.values)
mkt_data.columns = headers
del(headers)

mkt_data.drop(mkt_data.iloc[:, 26:36], inplace=True, axis=1)
mkt_data.drop(mkt_data.iloc[:, 17:22], inplace=True, axis=1)     
mkt_data.drop(mkt_data.iloc[:, 3:5], inplace=True, axis=1)
mkt_data.drop(mkt_data.iloc[:, 1:2], inplace=True, axis=1)
mkt_data = mkt_data.drop(['na','Brand'], axis=1)  
mkt_data.rename(columns={'Seat Ø':'Seat'}, inplace=True)
mkt_data.rename(columns={'record Type':'record_Type'}, inplace=True)
mkt_data.rename(columns={'Country code':'Country_Code'}, inplace=True)
mkt_data.rename(columns={'Qty month':'Qty_month'}, inplace=True)
mkt_data.rename(columns={'Qty YTD':'Qty_YTD'}, inplace=True)
mkt_data = pd.merge(mkt_data, Seat_Inches, on='Seat', how='left')
mkt_data.rename(columns={'Seat in inch':'Seat_in'}, inplace=True)
mkt_data['Sgt_ETRma_LB'] = mkt_data['Sgt ETRma n°'].apply(str).str[:1]
mkt_data['Sgt ETRma n°'] = mkt_data['Sgt ETRma n°'].apply(str)
mkt_data = mkt_data[mkt_data.Sgt_ETRma_LB == '1']

del(Seat_Inches)

mkt_data["Pneu"] = mkt_data["Width"].astype(str) + "_" + mkt_data["Ratio"].astype(str) + "_" + mkt_data["Seat_in"].astype(str)
#mkt_data["Sgt ETRma n°"].astype(str) + '_' + 
mkt_data_OE = mkt_data[(mkt_data['record_Type'] == 'OE') & (mkt_data['Country_Code'] == 'EU')]
mkt_data_OE_melt = mkt_data_OE.groupby(['Pneu','Year'])['Qty_month'].sum().to_frame(name=None)
mkt_data_OE_melt.reset_index(inplace=True)
mkt_data_OE_melt.rename(columns={'Qty_month':'QTY_OE'}, inplace=True)

mkt_data_RT = mkt_data[mkt_data.record_Type == 'RE']
mkt_data_RT = pd.pivot_table(mkt_data_RT, index=['Country_Code', 'Pneu'], columns = 'Year', values = 'Qty_month')
#mkt_data_RT.fillna(0, inplace=True)  
mkt_data_RT.reset_index(inplace=True)
mkt_data_RT_melt = mkt_data_RT.melt(id_vars=['Country_Code', 'Pneu'], var_name='Year', value_name='QTY_RT')

mkt_data_RT_melt = pd.merge(mkt_data_RT_melt, mkt_data_OE_melt, on=['Pneu', 'Year'], how='left')
#mkt_data_RT_melt.fillna(0, inplace=True)
mkt_data_RT_melt['QTY_OE'] = mkt_data_RT_melt['QTY_OE'].apply(int)

del(mkt_data, mkt_data_OE, mkt_data_OE_melt, mkt_data_RT)
#################### Features #############################
mkt_data_RT_melt2 = mkt_data_RT_melt.copy()
mkt_data_RT_melt2[mkt_data_RT_melt2['QTY_RT'] < 0] = 0 #Remove negative values - what does it means?
mkt_data_RT_melt2['QTY_RT_1'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT'].shift()
mkt_data_RT_melt2['QTY_RT_2'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_1'].shift()
mkt_data_RT_melt2['QTY_RT_3'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_2'].shift()
#mkt_data_RT_melt2['QTY_RT_4'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_3'].shift()
#mkt_data_RT_melt2['QTY_RT_5'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_4'].shift()
#mkt_data_RT_melt2['QTY_RT_6'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_5'].shift()
#mkt_data_RT_melt2['QTY_RT_7'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_6'].shift()
#mkt_data_RT_melt2['QTY_RT_8'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_7'].shift()
#mkt_data_RT_melt2['QTY_RT_9'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_8'].shift()
#mkt_data_RT_melt2['QTY_RT_10'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_9'].shift()

mkt_data_RT_melt2['QTY_RT_diff_1'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_1'].diff()
mkt_data_RT_melt2['QTY_RT_diff_2'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_1'].diff()
mkt_data_RT_melt2['QTY_RT_diff_3'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_2'].diff()
#mkt_data_RT_melt2['QTY_RT_diff_4'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_3'].diff()
#mkt_data_RT_melt2['QTY_RT_diff_5'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_4'].diff()
#mkt_data_RT_melt2['QTY_RT_diff_6'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_5'].diff()
#mkt_data_RT_melt2['QTY_RT_diff_7'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_6'].diff()
#mkt_data_RT_melt2['QTY_RT_diff_8'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_7'].diff()
#mkt_data_RT_melt2['QTY_RT_diff_9'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_8'].diff()
#mkt_data_RT_melt2['QTY_RT_diff_10'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_9'].diff()

mkt_data_RT_melt2['QTY_OE_1'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE'].shift()
mkt_data_RT_melt2['QTY_OE_2'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_1'].shift()
mkt_data_RT_melt2['QTY_OE_3'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_2'].shift()
mkt_data_RT_melt2['QTY_OE_4'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_3'].shift()
mkt_data_RT_melt2['QTY_OE_5'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_4'].shift()
mkt_data_RT_melt2['QTY_OE_6'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_5'].shift()
mkt_data_RT_melt2['QTY_OE_7'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_6'].shift()
mkt_data_RT_melt2['QTY_OE_8'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_7'].shift()
#mkt_data_RT_melt2['QTY_OE_9'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_8'].shift()
#mkt_data_RT_melt2['QTY_OE_10'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_9'].shift()

#mkt_data_RT_melt2['QTY_OE_diff_1'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_1'].diff()
#mkt_data_RT_melt2['QTY_OE_diff_2'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_1'].diff()
#mkt_data_RT_melt2['QTY_OE_diff_3'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_2'].diff()
#mkt_data_RT_melt2['QTY_OE_diff_4'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_3'].diff()
#mkt_data_RT_melt2['QTY_OE_diff_5'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_4'].diff()
#mkt_data_RT_melt2['QTY_OE_diff_6'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_5'].diff()
#mkt_data_RT_melt2['QTY_OE_diff_7'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_6'].diff()
#mkt_data_RT_melt2['QTY_OE_diff_8'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_7'].diff()
#mkt_data_RT_melt2['QTY_OE_diff_9'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_8'].diff()
#mkt_data_RT_melt2['QTY_OE_diff_10'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_9'].diff()

#mkt_data_RT_melt2.fillna(0, inplace=True)
    #mkt_data_RT_melt2 = mkt_data_RT_melt2.dropna()

#mkt_data_RT_melt2.head()

def rmsle(ytrue, ypred):
    return np.sqrt(mean_squared_log_error(ytrue, ypred))

mean_error = []
for year in range(2016,2019):
    train = mkt_data_RT_melt2[mkt_data_RT_melt2['Year'] < year]
    val = mkt_data_RT_melt2[mkt_data_RT_melt2['Year'] == year]
    error = rmsle(val['QTY_RT'].values, val['QTY_RT_1'].values)
    print('Year %d - Error %.5f' % (year, error))
    mean_error.append(error)
print('Mean Error = %.5f' % np.mean(mean_error))
del(error, val, train, year)

#Model  
mkt_data_RT_Model2 = mkt_data_RT_melt2.copy()
le1 = preprocessing.LabelEncoder()
le2 = preprocessing.LabelEncoder()

mkt_data_RT_Model2['Pneu'] = le1.fit_transform(mkt_data_RT_Model2['Pneu'].astype(str))
mkt_data_RT_Model2['Country_Code'] = le2.fit_transform(mkt_data_RT_Model2['Country_Code'].astype(str)) 

train = mkt_data_RT_Model2[mkt_data_RT_Model2['Year'] < 2016]
val = mkt_data_RT_Model2[mkt_data_RT_Model2['Year'] == 2016]

mkt_data_RT_Model2['Pneu'] = le1.inverse_transform(mkt_data_RT_Model2['Pneu'])
mkt_data_RT_Model2['Country_Code'] = le2.inverse_transform(mkt_data_RT_Model2['Country_Code']) 

#Year = 2017
Eval = pd.DataFrame(columns=['Country_Code','Pneu','Year','Actual','Prev'])
for Year in range(2016,2019):
 
    mkt_data_RT_Model2['Pneu'] = le1.fit_transform(mkt_data_RT_Model2['Pneu'].astype(str))
    mkt_data_RT_Model2['Country_Code'] = le2.fit_transform(mkt_data_RT_Model2['Country_Code'].astype(str)) 

    train = train[train['Year'] < Year]
    val = mkt_data_RT_Model2[mkt_data_RT_Model2['Year'] == Year]
    
    xtr, xts = train.drop(['QTY_RT'], axis=1), val.drop(['QTY_RT'], axis=1)
    ytr, yts = train['QTY_RT'].values, val['QTY_RT'].values
    
    mdl = RandomForestRegressor(n_estimators=1, n_jobs=-1, random_state=0)

    mdl.fit(xtr, ytr)
    
    p = mdl.predict(xts)
    
    error = rmsle(yts, p)
    print('Year %d - Error %.5f' % (Year, error))
    mean_error.append(error)
       
    xts['Actual'] = val['QTY_RT']
    xts['Prev'] = p
    xts['Pneu'] = le1.inverse_transform(xts['Pneu'])
    xts['Country_Code'] = le2.inverse_transform(xts['Country_Code'])
    output = xts[['Country_Code','Pneu','Year','Actual','Prev']]
    Eval = Eval.append(xts[['Country_Code','Pneu','Year','Actual','Prev']])
    
    xts['Pneu'] = le1.fit_transform(xts['Pneu'].astype(str))
    xts['Country_Code'] = le2.fit_transform(xts['Country_Code'].astype(str)) 
    xts = xts.drop(['Actual'], axis=1)
    xts.rename(columns={'Prev':'QTY_RT'}, inplace=True)
    xts['QTY_RT'] = xts['QTY_RT'].round(decimals=0,).apply(int)
    
    #train['Year'].unique()
    train = train.append(xts, sort=False)
    
    mkt_data_RT_Model2['Pneu'] = le1.inverse_transform(mkt_data_RT_Model2['Pneu'])
    mkt_data_RT_Model2['Country_Code'] = le2.inverse_transform(mkt_data_RT_Model2['Country_Code']) 
    
print('Mean Error = %.5f' % np.mean(mean_error))

#Eval

Eval_Year = Eval[Eval.Year == 2018]
Eval_Year['Prev'] = Eval_Year['Prev'].round(decimals=0,).apply(int)
Eval_Year['Actual'] = Eval_Year['Actual'].apply(int)

Eval_Year['Width'], Eval_Year['Ratio'] = Eval_Year['Pneu'].str.split('_', 1).str
Eval_Year['Ratio'], Eval_Year['Seat_in'] = Eval_Year['Ratio'].str.split('_', 1).str

Eval_Seat = Eval_Year[Eval_Year.Seat_in == '19']
Eval_Year['Prev'] = Eval_Year['Prev'].round(decimals=0,).apply(int)
Eval_Year['Actual'] = Eval_Year['Actual'].apply(int)

mkt_data_RT_melt3 = mkt_data_RT_melt2[mkt_data_RT_melt2.Pneu == '255_40_19']

val.loc[:, 'Prediction'] = np.round(p)
val.plot.scatter(x='Prediction', y='QTY_RT', figsize=(15,10), title='Prediction vs Actuals', 
                 ylim=(0,1000000), xlim=(0,1000000))

Eval_Seat.plot.scatter(x='Prev', y='Actual', figsize=(15,10), title='Prediction vs Actuals', 
                 ylim=(0,10000), xlim=(0,10000))

#################### SANDBOX #############################

sample = mkt_data[mkt_data.Qty_YTD == 'nan'].sample(n=500, random_state=1)
sample = mkt_data_RT_melt.sample(n=500, random_state=1)
mkt_data_RT_melt
sample2 = mkt_data_RT_melt[(mkt_data_RT_melt['Country_Code'] == 'IE') & (mkt_data_RT_melt['Pneu'] == '175_55_15')]

mkt_data_ = mkt_data[mkt_data.Width == 'na']

print(mkt_data_RT_melt.info())
print(mkt_data_RT_melt2.info())
Paises = Eval['Country_Code'].unique()
print(Paises)

mkt_data.columns.values
mkt_data_OE.head

os.chdir("C:/Users/F376267/Documents/Data Science/Car Park/Python Scripts")
pd.DataFrame(pneus).to_csv("pneus.csv", index = False)


OE_check = mkt_data_OE[pd.isnull(mkt_data_OE["Ratio"])]
OE_check = mkt_data_OE[mkt_data_OE.Sgt_ETRma_LB == "1131"]
mkt_data = mkt_data[mkt_data.Sgt_ETRma_LB == '1']

mkt_data_RT_melt2 = mkt_data_RT_melt2[mkt_data_RT_melt2.Pneu == '205_55_16']
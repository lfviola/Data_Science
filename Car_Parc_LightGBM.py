#http://mariofilho.com/how-to-predict-multiple-time-series-with-scikit-learn-with-sales-forecasting-example/

# Importing the libraries
import numpy as np
"""import matplotlib.pyplot as plt"""
import pandas as pd
import os
import glob
from sklearn import preprocessing
from sklearn.metrics import mean_squared_log_error
from sklearn.ensemble import RandomForestRegressor
import lightgbm as lgb

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
mkt_data = pd.merge(mkt_data, Seat_Inches, on='Seat', how='left')
mkt_data.rename(columns={'Seat in inch':'Seat_in'}, inplace=True)
mkt_data['Sgt_ETRma_LB'] = mkt_data['Sgt ETRma n°'].apply(str).str[:1]
mkt_data['Sgt ETRma n°'] = mkt_data['Sgt ETRma n°'].apply(str)
mkt_data = mkt_data[mkt_data.Sgt_ETRma_LB == '1']
del(Seat_Inches)

"""mkt_data["Pneu"] = mkt_data["Sgt ETRma n°"].astype(str) + '_' + mkt_data["Width"].astype(str) + '_' + mkt_data["Ratio"].astype(str) \
+ '_' + mkt_data["Seat_in"].astype(str)  + '_' + mkt_data["Structure"].astype(str) + '_' + mkt_data["Reinforced code"].astype(str) \
+ '_' + mkt_data["TL_TT"].astype(str) + '_' + mkt_data["Speed Index"].astype(str) + '_' + mkt_data["Load index"].astype(str) """

mkt_data["Pneu"] = mkt_data["Sgt ETRma n°"].astype(str) + '_' + mkt_data["Width"].astype(str) + "_" + mkt_data["Ratio"].astype(str) + "_" + mkt_data["Seat_in"].astype(str)

mkt_data_RT = mkt_data[mkt_data.record_Type == 'RE']
mkt_data_OE = mkt_data[(mkt_data['record_Type'] == 'OE') & (mkt_data['Country_Code'] == 'EU')]

mkt_data_RT_melt = mkt_data_RT.groupby(['Country_Code','Pneu','Year'])['Qty_month'].sum().to_frame(name=None)
mkt_data_RT_melt.reset_index(inplace=True)
mkt_data_RT_melt.rename(columns={'Qty_month':'QTY_RT'}, inplace=True)

mkt_data_OE_melt = mkt_data_OE.groupby(['Pneu','Year'])['Qty_month'].sum().to_frame(name=None)
mkt_data_OE_melt.reset_index(inplace=True)
mkt_data_OE_melt.rename(columns={'Qty_month':'QTY_OE'}, inplace=True)

mkt_data_RT_melt = pd.merge(mkt_data_RT_melt, mkt_data_OE_melt, on=['Pneu', 'Year'], how='left')

mkt_data_RT_melt.fillna(0, inplace=True)
mkt_data_RT_melt['QTY_OE'] = mkt_data_RT_melt['QTY_OE'].apply(int)

#sample = mkt_data_RT_melt2.sample(n=50, random_state=1)

#################### Adding features #############################
mkt_data_RT_melt2 = mkt_data_RT_melt.copy()
#country = 'FR'
#mkt_data_RT_melt2 = mkt_data_RT_melt[mkt_data_RT_melt.Country_Code == country]
#del(country)
#mkt_data_RT_melt2 = mkt_data_RT_melt2.drop(['Country_Code'], axis=1)  
mkt_data_RT_melt2[mkt_data_RT_melt2['QTY_RT'] < 0] = 0 #Remove negative values - what does it means?

mkt_data_RT_melt2['QTY_RT_1'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT'].shift()
mkt_data_RT_melt2['QTY_RT_2'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_1'].shift()
mkt_data_RT_melt2['QTY_RT_3'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_2'].shift()
mkt_data_RT_melt2['QTY_RT_4'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_3'].shift()
mkt_data_RT_melt2['QTY_RT_5'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_4'].shift()
mkt_data_RT_melt2['QTY_RT_6'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_5'].shift()
mkt_data_RT_melt2['QTY_RT_7'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_6'].shift()
mkt_data_RT_melt2['QTY_RT_8'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_7'].shift()
mkt_data_RT_melt2['QTY_RT_9'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_8'].shift()
mkt_data_RT_melt2['QTY_RT_10'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_9'].shift()

mkt_data_RT_melt2['QTY_RT_diff_1'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_1'].diff()
mkt_data_RT_melt2['QTY_RT_diff_2'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_1'].diff()
mkt_data_RT_melt2['QTY_RT_diff_3'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_2'].diff()
mkt_data_RT_melt2['QTY_RT_diff_4'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_3'].diff()
mkt_data_RT_melt2['QTY_RT_diff_5'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_4'].diff()
mkt_data_RT_melt2['QTY_RT_diff_6'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_5'].diff()
mkt_data_RT_melt2['QTY_RT_diff_7'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_6'].diff()
mkt_data_RT_melt2['QTY_RT_diff_8'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_7'].diff()
mkt_data_RT_melt2['QTY_RT_diff_9'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_8'].diff()
mkt_data_RT_melt2['QTY_RT_diff_10'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_RT_diff_9'].diff()

mkt_data_RT_melt2['QTY_OE_1'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE'].shift()
mkt_data_RT_melt2['QTY_OE_2'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_1'].shift()
mkt_data_RT_melt2['QTY_OE_3'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_2'].shift()
mkt_data_RT_melt2['QTY_OE_4'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_3'].shift()
mkt_data_RT_melt2['QTY_OE_5'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_4'].shift()
mkt_data_RT_melt2['QTY_OE_6'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_5'].shift()
mkt_data_RT_melt2['QTY_OE_7'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_6'].shift()
mkt_data_RT_melt2['QTY_OE_8'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_7'].shift()
mkt_data_RT_melt2['QTY_OE_9'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_8'].shift()
mkt_data_RT_melt2['QTY_OE_10'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_9'].shift()

mkt_data_RT_melt2['QTY_OE_diff_1'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_1'].diff()
mkt_data_RT_melt2['QTY_OE_diff_2'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_1'].diff()
mkt_data_RT_melt2['QTY_OE_diff_3'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_2'].diff()
mkt_data_RT_melt2['QTY_OE_diff_4'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_3'].diff()
mkt_data_RT_melt2['QTY_OE_diff_5'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_4'].diff()
mkt_data_RT_melt2['QTY_OE_diff_6'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_5'].diff()
mkt_data_RT_melt2['QTY_OE_diff_7'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_6'].diff()
mkt_data_RT_melt2['QTY_OE_diff_8'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_7'].diff()
mkt_data_RT_melt2['QTY_OE_diff_9'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_8'].diff()
mkt_data_RT_melt2['QTY_OE_diff_10'] = mkt_data_RT_melt2.groupby(['Pneu','Country_Code'])['QTY_OE_diff_9'].diff()

mkt_data_RT_melt2.fillna(0, inplace=True)
    #mkt_data_RT_melt2 = mkt_data_RT_melt2.dropna()

#mkt_data_RT_melt2.head()

#################### rmsle #############################

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

#################### LightGBM #############################

"""Transformando Pais e Id do produto em Category"""
mkt_data_RT_melt2['Country_Code'] = mkt_data_RT_melt2['Country_Code'].astype('category')
mkt_data_RT_melt2['Pneu'] = mkt_data_RT_melt2['Pneu'].astype('category')

mean_error = []
Eval = pd.DataFrame(columns=['Country_Code','Pneu','QTY_RT_3','QTY_RT_2','QTY_RT_1','Prev','Actual'])
for Year in range(2017,2018):
    train = mkt_data_RT_melt2[mkt_data_RT_melt2['Year'] < Year]
    val = mkt_data_RT_melt2[mkt_data_RT_melt2['Year'] == Year]
    
    xtr, xts = train.drop(['QTY_RT', 'Year'], axis=1), val.drop(['QTY_RT','Year'], axis=1)
    ytr, yts = train['QTY_RT'].values, val['QTY_RT'].values
    
    lgb_train = lgb.Dataset(xtr, ytr)
    lgb_eval = lgb.Dataset(xts, yts, reference=lgb_train)
    
    params = {
    'max_depth': 10,
    'bagging_fraction': 0.5,
    'bagging_freq': 5,
    'feature_fraction': 0.75,
    'max_bin': 10,
    'save_binary': 'true',
    'boosting_type': 'dart',
    'objective': 'regression',
    'metric': 'mse',
    'num_leaves': 30,
    'learning_rate': 0.05,
    'num_iterations': 1000,
    'bagging_freq': 5
    }
 
    gbm = lgb.train(params, lgb_train, 300, verbose_eval=50)
    
    p = gbm.predict(xts)
    p[p < 0] = 0
    
    xts['Actual'] = val['QTY_RT']
    xts['Prev'] = p

    Eval = Eval.append(xts[['Country_Code','Pneu','QTY_RT_3','QTY_RT_2','QTY_RT_1','Prev','Actual']])
    
    error = rmsle(yts, p)
    print('Year %d - Error %.5f' % (Year, error))
    mean_error.append(error)
print('Mean Error = %.5f' % np.mean(mean_error))

#################### Evaluation #############################

Eval_Year = Eval[Eval.Year == 2017]
Eval_Year['Prev'] = Eval_Year['Prev'].round(decimals=0,).apply(int)
Eval_Year['Actual'] = Eval_Year['Actual'].apply(int)
Eval_Year['QTY_RT_3'] = Eval_Year['QTY_RT_3'].apply(int)
Eval_Year['QTY_RT_2'] = Eval_Year['QTY_RT_2'].apply(int)
Eval_Year['QTY_RT_1'] = Eval_Year['QTY_RT_1'].apply(int)

Eval_Year['Sgt_ETRma'], Eval_Year['Ratio'] = Eval_Year['Pneu'].str.split('_', 1).str
Eval_Year['Width'], Eval_Year['Ratio'] = Eval_Year['Ratio'].str.split('_', 1).str
Eval_Year['Ratio'], Eval_Year['Seat_in'] = Eval_Year['Ratio'].str.split('_', 1).str
Eval_Year = Eval_Year.drop(['Pneu'], axis=1)
season = pd.read_excel('Rercherches V_2017-03.xlsx', sheet_name = 'Hierarchie_produit TCRE', header = 2 )
season.rename(columns={'code Segment ETRMA':'Sgt_ETRma'}, inplace=True)
season['Sgt_ETRma'] = season['Sgt_ETRma'].apply(str)
Eval_Year = pd.merge(Eval_Year, season, on='Sgt_ETRma', how='left')

"""Seat"""
Eval_Seat = Eval_Year[Eval_Year.Seat_in == '19']
Eval_Seat = Eval_Seat.groupby(['Country_Code','Seat_in','Year'])['QTY_RT_3','QTY_RT_2','QTY_RT_1','Prev','Actual'].sum()
Eval_Seat.reset_index(inplace=True)
Eval_Seat['Error %'] = (Eval_Seat['Prev']/Eval_Seat['Actual']-1)*100


"""Season_A_S_3W"""
Eval_Season = Eval_Year[Eval_Year.Seat_in == '19']
Eval_Season = Eval_Season.groupby(['Country_Code','Season_A_S_3W','Year'])['QTY_RT_3','QTY_RT_2','QTY_RT_1','Prev','Actual'].sum()
Eval_Season.reset_index(inplace=True)
Eval_Season['Error %'] = (Eval_Season['Prev']/Eval_Season['Actual']-1)*100

val.loc[:, 'Prediction'] = np.round(p)
val.plot.scatter(x='Prediction', y='QTY_RT', figsize=(15,10), title='Prediction vs Actuals', 
                 ylim=(0,1000000), xlim=(0,1000000))

Eval_Seat.plot.scatter(x='Prev', y='Actual', figsize=(15,10), title='Prediction vs Actuals', 
                 ylim=(0,10000), xlim=(0,10000))

#################### SANDBOX #############################

mkt_data_ = mkt_data[mkt_data.Width == 'na']

print(mkt_data_RT_melt.info())
print(mkt_data_RT_melt2.info())
Paises = Eval['Country_Code'].unique()
print(Paises)

mkt_data_RT.head
mkt_data_OE.head
xts.columns.values

os.chdir("C:/Users/F376267/Documents/Data Science/Car Park/Python Scripts")
pd.DataFrame(Eval_Year).to_csv("Eval_Year.csv", index = False)

mkt_data_.isnull().sum()

mkt_data_RT_melt2 = mkt_data_RT_melt2[mkt_data_RT_melt2.Pneu == '205_55_16']

sample = mkt_data.sample(n=50, random_state=1)

############################################################################

def bias(ytrue, ypred):
    return np.sqrt(mean_squared_log_error(ytrue, ypred))




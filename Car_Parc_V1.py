# Importing the libraries
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import os

# Importing and preparing the dataset
os.chdir("C:/Users/F376267/Documents/Data Science/Car Park/Python Scripts")
MKT_DF = pd.read_csv('h.devillepin-REZEU-S-200101-201512-42449.492679919.csv', sep=';',low_memory=False)
#MKT_DF = pd.read_csv('testCSV.csv', sep=';', low_memory=False)
Seat_Inches = pd.read_excel('Seat_Inches.xlsx', dtype={'Seat': str, 'Seat in inch': float})
headers = pd.read_excel('2016 Libellé Fichier Marches ETRma_MO_modif HdV.xlsx')
headers = list(headers.columns.values)
MKT_DF.columns = headers
del(headers)
MKT_DF.drop(MKT_DF.iloc[:, 26:36], inplace=True, axis=1)
MKT_DF.drop(MKT_DF.iloc[:, 17:22], inplace=True, axis=1)     
MKT_DF.drop(MKT_DF.iloc[:, 3:8], inplace=True, axis=1)
MKT_DF.drop(MKT_DF.iloc[:, 0:2], inplace=True, axis=1)  
MKT_DF.rename(columns={'Seat Ø':'Seat'}, inplace=True)
MKT_DF.rename(columns={'Country code':'Country_Code'}, inplace=True)
MKT_DF = pd.merge(MKT_DF, Seat_Inches, on='Seat', how='left')
MKT_DF.rename(columns={'Seat in inch':'Seat_in'}, inplace=True)
MKT_DF.rename(columns={'Qty month':'Qty_month'}, inplace=True)
del(Seat_Inches)

#################### EDA #############################

MKT_DF_PVT = MKT_DF[MKT_DF['Country_Code']=='FR']
MKT_DF_PVT = MKT_DF_PVT[MKT_DF_PVT['Seat_in'] < 25]
MKT_DF_PVT = MKT_DF_PVT[MKT_DF_PVT['Seat_in'] > 10]
MKT_DF_PVT = pd.pivot_table(MKT_DF_PVT,index='Year',values='Qty_month',columns='Seat_in',aggfunc=[np.sum])
MKT_DF_PVT.columns = MKT_DF_PVT.columns.droplevel(0)
MKT_DF_PVT.reset_index(inplace=True)

#Spaghetti plot
plt.style.use('seaborn-darkgrid')
my_dpi=96
plt.figure(figsize=(800/my_dpi, 540/my_dpi), dpi=my_dpi)
for column in MKT_DF_PVT.drop('Year', axis=1):
   plt.plot(MKT_DF_PVT['Year'], MKT_DF_PVT[column], marker='', linewidth=2, alpha=0.7)
plt.xlim(2000,2016)
#plt.ylim(0,1000)
num=0
for i in MKT_DF_PVT.values[len(MKT_DF_PVT.index)-1][1:]:
   num+=1
   name=list(MKT_DF_PVT)[num]
   plt.text(2015.4, i, name, horizontalalignment='center', size='small', color='black')
   
#Spaghetti up
size1 = 14.0
size2 = 18.0
plt.style.use('seaborn-darkgrid')
my_dpi=96
plt.figure(figsize=(800/my_dpi, 540/my_dpi), dpi=my_dpi)
for column in MKT_DF_PVT.drop('Year', axis=1):
    plt.plot(MKT_DF_PVT['Year'], MKT_DF_PVT[column], marker='', color='grey', linewidth=1, alpha=0.4)
plt.plot(MKT_DF_PVT['Year'], MKT_DF_PVT[size1], marker='', color='blue', linewidth=4, alpha=0.7)
plt.plot(MKT_DF_PVT['Year'], MKT_DF_PVT[size2], marker='', color='orange', linewidth=4, alpha=0.7)
plt.xlim(2001,2016)
num=0
for i in MKT_DF_PVT.values[len(MKT_DF_PVT.index)-1][1:]:
   num+=1
   name=list(MKT_DF_PVT)[num]
   if name == size1 :
       plt.text(2015.5, i, name, horizontalalignment='center', size='large', color='blue')
   elif name == size2 :
       plt.text(2015.5, i, name, horizontalalignment='center', size='large', color='orange')
      
#################### SANDBOX #############################

a = 200
b = 33
if b > a:
  print("b is greater than a")
elif a == b:
  print("a and b are equal")
else:
  print("a is greater than b")

MKT_DF_PVT.head
MKT_DF.isnull().sum()


MKT_DF.dtypes

print(list(MKT_DF_PVT)[2])
print(MKT_DF_PVT.info())

print(MKT_DF_PVT.values[len(MKT_DF_PVT.index)-1][1:])




# Saving the CSV file 
pd.DataFrame(MKT_DF_PVT).to_csv("file.csv", index = False)

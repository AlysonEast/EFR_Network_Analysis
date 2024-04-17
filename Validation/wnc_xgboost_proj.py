
#conda activate xgboost_env
import seaborn as sns
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import warnings
import xgboost as xgb


warnings.filterwarnings("ignore")

model = xgb.Booster()
model.load_model("wnc_model.json")


df = pd.read_csv('./map_for_GPP_conversion_pheno', sep= " ")
df['year'] = 2023
df['product'] = 5

print(df.head())
print(df.shape)

print(df[['FW3', 'pheno', 'year', 'product']].head())
test = df[['FW3', 'pheno', 'year', 'product']]

dtest_reg = xgb.DMatrix(test)

#X, y = df.drop('GPP', axis=1), df[['GPP']]

preds = model.predict(dtest_reg)

df["GPP_pred"] = preds

print(df.head())

df.to_csv('./GPP_converted_pheno.csv', index=False)


df = pd.read_csv('./map_for_GPP_conversion_S3', sep= " ")
df['year'] = 2023
df['product'] = 5

test = df[['FW3', 'pheno', 'year', 'product']]

dtest_reg = xgb.DMatrix(test)
preds = model.predict(dtest_reg)

df["GPP_pred"] = preds

print(df.head())

df.to_csv('./GPP_converted_S3.csv', index=False)

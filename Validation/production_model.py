
#conda activate xgboost_env
import seaborn as sns
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import warnings
import xgboost as xgb
import sys

warnings.filterwarnings("ignore")

model = xgb.Booster()
model.load_model("./models_10chunk/Seq/samples_Seq_chunk1_model.json")

print(sys.argv[0])

df = pd.read_csv('./tmp_map_for_GPP_conversion_pheno', sep= " ")
df['week'] = pd.to_numeric(sys.argv[1])
df['pct'] = pd.to_numeric(sys.argv[2])

print(df.head())
print(df.shape)


test = df[['FW3', 'pheno', 'minint', 'week', 'pct']]
test['pheno'] = test['pheno'].astype('category')


print(test.describe())

dtest_reg = xgb.DMatrix(test, enable_categorical=True)
preds = model.predict(dtest_reg)

df["GPP_pred"] = preds

df.to_csv('./GPP_converted_pheno.csv', index=False)

df = pd.read_csv('./tmp_map_for_GPP_conversion_S3', sep= " ")
df['week'] = sys.argv[1]
df['pct'] = sys.argv[2]

test = df[['FW3', 'minint', 'pheno', 'week']]
test['pheno'] = test['pheno'].astype('category')

dtest_reg = xgb.DMatrix(test, enable_categorical=True)
preds = model.predict(dtest_reg)

df["GPP_pred"] = preds

df.to_csv('./GPP_converted_S3.csv', index=False)

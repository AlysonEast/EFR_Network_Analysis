#conda activate xgboost_env
import seaborn as sns
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import warnings
import xgboost as xgb
import sys

warnings.filterwarnings("ignore")

# Assuming 10 models, one for each range of pheno values
model_paths = [
    "./models_10chunk/Seq/samples_Seq_chunk1_model.json",
    "./models_10chunk/Seq/samples_Seq_chunk2_model.json",
    "./models_10chunk/Seq/samples_Seq_chunk3_model.json",
    "./models_10chunk/Seq/samples_Seq_chunk4_model.json",
    "./models_10chunk/Seq/samples_Seq_chunk5_model.json",
    "./models_10chunk/Seq/samples_Seq_chunk6_model.json",
    "./models_10chunk/Seq/samples_Seq_chunk7_model.json",
    "./models_10chunk/Seq/samples_Seq_chunk8_model.json",
    "./models_10chunk/Seq/samples_Seq_chunk9_model.json",
    "./models_10chunk/Seq/samples_Seq_chunk10_model.json",
]

df = pd.read_csv('./tmp_map_for_GPP_conversion_pheno', sep=" ")
df['week'] = pd.to_numeric(sys.argv[1])
df['pct'] = pd.to_numeric(sys.argv[2])

print(df.head())
print(df.shape)

# List to store filtered and predicted dataframes
results_pheno = []

# Loop over the model paths and the corresponding pheno value ranges
for i, model_path in enumerate(model_paths):
    # Load the model
    model = xgb.Booster()
    model.load_model(model_path)
    
    # Define the pheno range for the current model
    pheno_start = i * 10 + 1
    pheno_end = (i + 1) * 10
    
    # Filter the dataset for the current pheno range
    df_filtered = df[(df['pheno'] >= pheno_start) & (df['pheno'] <= pheno_end)]
    
    if df_filtered.empty:
        continue
    
    test = df_filtered[['FW3', 'pheno', 'minint', 'week', 'pct']]
    test['pheno'] = test['pheno'].astype('category')
    
    print(test.describe())
    
    dtest_reg = xgb.DMatrix(test, enable_categorical=True)
    preds = model.predict(dtest_reg)
    
    df_filtered["GPP_pred"] = preds
    
    # Append the dataframe to the list
    results_pheno.append(df_filtered)

# Concatenate all dataframes in the list and save as a single CSV
final_df_pheno = pd.concat(results_pheno)
final_df_pheno.to_csv('./GPP_converted_pheno.csv', index=False)

# Similarly, process the second dataset
df_s3 = pd.read_csv('./tmp_map_for_GPP_conversion_S3', sep=" ")
df_s3['week'] = pd.to_numeric(sys.argv[1])
df_s3['pct'] = pd.to_numeric(sys.argv[2])

results_s3 = []

for i, model_path in enumerate(model_paths):
    model = xgb.Booster()
    model.load_model(model_path)
    
    pheno_start = i * 10 + 1
    pheno_end = (i + 1) * 10
    
    df_filtered = df_s3[(df_s3['pheno'] >= pheno_start) & (df_s3['pheno'] <= pheno_end)]
    
    if df_filtered.empty:
        continue
    
    test = df_filtered[['FW3', 'pheno', 'minint', 'week', 'pct']]
    test['pheno'] = test['pheno'].astype('category')
    
    dtest_reg = xgb.DMatrix(test, enable_categorical=True)
    preds = model.predict(dtest_reg)
    
    df_filtered["GPP_pred"] = preds
    
    results_s3.append(df_filtered)

final_df_s3 = pd.concat(results_s3)
final_df_s3.to_csv('./GPP_converted_S3.csv', index=False)

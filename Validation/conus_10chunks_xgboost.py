
#conda activate xgboost_env
import seaborn as sns
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import warnings
import xgboost as xgb
import os

from sklearn.metrics import mean_squared_error

import matplotlib.pyplot as plt
from sklearn.metrics import r2_score
from scipy.stats import gaussian_kde

from sklearn.model_selection import train_test_split

warnings.filterwarnings("ignore")

# Get list of files in directory
file_directory = "./xgboost_samples/"
file_list = os.listdir(file_directory)

# Iterate over each file
for file_name in file_list:
    if file_name.endswith('.csv'):
        # Load data from file
        df = pd.read_csv(os.path.join(file_directory, file_name))

        # Convert "pheno" column to categorical
        df['pheno'] = df['pheno'].astype('category')

        print(df.head())
        print(df.shape)
        print(df.describe())
        #print(df.describe(exclude=np.number))


        # Extract feature and target arrays
        X, y = df.drop('GPP', axis=1), df[['GPP']]

        # Extract text features
        #cats = X.select_dtypes(exclude=np.number).columns.tolist()
        
        # Convert to Pandas category
        #for col in cats:
        #   X[col] = X[col].astype('category')

        # Split the data
        X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=1)


        # Create regression matrices
        dtrain_reg = xgb.DMatrix(X_train, y_train, enable_categorical=True)
        dtest_reg = xgb.DMatrix(X_test, y_test, enable_categorical=True)


        #mse = np.mean((actual - predicted) ** 2)
        #rmse = np.sqrt(mse)
        
        # Define hyperparameters
        params = {"objective": "reg:squarederror"}

        n = 100
        model = xgb.train(
           params=params,
           dtrain=dtrain_reg,
           num_boost_round=n,
        )



        # Save model file with unique name
        model_filename = os.path.splitext(file_name)[0] + "_model.json"
        model.save_model(os.path.join('./models_10chunk/', model_filename))

        preds = model.predict(dtest_reg)

        rmse = mean_squared_error(y_test, preds, squared=False)
        print(f"RMSE of the base model: {rmse:.3f}")

        # Calculate R-squared value
        r_squared = r2_score(y_test, preds)

        plt.figure(figsize=(10, 5))
        plt.scatter(y_test, preds)
        plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], color='red', linewidth=2)
        plt.xlabel('True Values')
        plt.ylabel('Predicted Values')
        plt.title('True vs Predicted Values')
        plt.annotate(f'R-squared = {r_squared:.2f}', xy=(0.05, 0.85), xycoords='axes fraction', fontsize=12)
        plt.savefig(os.path.join('./figures_10chunk/', os.path.splitext(file_name)[0] + '_true_vs_predicted_values.png'))
        plt.close()

        preds=preds.reshape(len(y_test), 1)
        residuals = y_test - preds
        
        plt.figure(figsize=(10, 5))
        plt.hist(residuals, bins=50)
        plt.xlabel('Residual')
        plt.ylabel('Frequency')
        plt.title('Distribution of Residuals')
        plt.xlim(-40000,40000)
        plt.savefig(os.path.join('./figures_10chunk/', os.path.splitext(file_name)[0] + '_distribution_of_residuals.png'))
        plt.close()

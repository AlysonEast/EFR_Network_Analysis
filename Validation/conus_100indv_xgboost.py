
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
from xgboost import plot_importance

warnings.filterwarnings("ignore")

# Create an empty DataFrame to store model output values
results_df = pd.DataFrame(columns=['file_name', 'sample_size', 'r_squared', 'rmse', 'variable_importance'])

# Get list of files in directory
file_directory = "./xgboost_samples/indv100/"
file_list = os.listdir(file_directory)

# Iterate over each file
for file_name in file_list:
    if file_name.endswith('.csv'):
        # Load data from file
        df = pd.read_csv(os.path.join(file_directory, file_name))

        print(df.head())
        print(df.shape)
        print(df.describe())
        #print(df.describe(exclude=np.number))

        df = df.drop('product', axis=1)
        print(df.head())

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
        model.save_model(os.path.join('./models_100indv/', model_filename))

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
        plt.savefig(os.path.join('./figures_100indv/', os.path.splitext(file_name)[0] + '_true_vs_predicted_values.png'))
        plt.close()

        preds = preds.reshape(len(y_test), 1)
        residuals = y_test - preds
        
        plt.figure(figsize=(10, 5))
        plt.hist(residuals, bins=50)
        plt.xlabel('Residual')
        plt.ylabel('Frequency')
        plt.title('Distribution of Residuals')
        plt.xlim(-40000, 40000)
        plt.savefig(os.path.join('./figures_100indv/', os.path.splitext(file_name)[0] + '_distribution_of_residuals.png'))
        plt.close()

        plt.figure(figsize=(10, 5))
        ax = plot_importance(model)
        plt.savefig(os.path.join('./figures_100indv/', os.path.splitext(file_name)[0] + 'Var_Loadings.png'))
        plt.close()

        # Get the feature importances from the model
        importance_dict = model.get_score(importance_type='weight')
        sorted_importance = sorted(importance_dict.items(), key=lambda x: x[1], reverse=True)
        variable_importance = ', '.join([f'{k}: {v}' for k, v in sorted_importance])

        # Append a new row to the results DataFrame
        new_row = pd.DataFrame({
            'file_name': [file_name],
            'sample_size': [df.shape[0]],
            'r_squared': [r_squared],
            'rmse': [rmse],
            'variable_importance': [variable_importance]
        })

        results_df = pd.concat([results_df, new_row], ignore_index=True)
# Save the results DataFrame to a CSV file
results_df.to_csv('./model_100inv_results.csv', index=False)

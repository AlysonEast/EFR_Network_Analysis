
#conda activate xgboost_env
import seaborn as sns
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import warnings


warnings.filterwarnings("ignore")


df = pd.read_csv('./samples_wnc.csv')

print(df.head())
print(df.shape)
print(df.describe())
#print(df.describe(exclude=np.number))

from sklearn.model_selection import train_test_split

# Extract feature and target arrays
X, y = df.drop('GPP', axis=1), df[['GPP']]

# Extract text features
#cats = X.select_dtypes(exclude=np.number).columns.tolist()

# Convert to Pandas category
#for col in cats:
#   X[col] = X[col].astype('category')

# Split the data
X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=1)


import xgboost as xgb

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

model.save_model("wnc_model.json")

from sklearn.metrics import mean_squared_error

preds = model.predict(dtest_reg)


rmse = mean_squared_error(y_test, preds, squared=False)
print(f"RMSE of the base model: {rmse:.3f}")

#mae = mean_absolute_error(y_test, preds)
#print('Mean Absolute Error:', mae)

import matplotlib.pyplot as plt
from sklearn.metrics import r2_score
from scipy.stats import gaussian_kde

plt.figure(figsize=(10, 5))
plt.scatter(y_test, preds)
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], color='red', linewidth=2)
plt.xlabel('True Values')
plt.ylabel('Predicted Values')
plt.title('True vs Predicted Values')
plt.savefig('true_vs_predicted_values.png')

preds=preds.reshape(310163,1)
residuals = y_test - preds

plt.figure(figsize=(10, 5))
plt.hist(residuals, bins=50)
plt.xlabel('Residual')
plt.ylabel('Frequency')
plt.title('Distribution of Residuals')
plt.ylim(-40000,40000)
plt.savefig('Distribution_of_Residuals.png')

#ChatGPT 
# Create a figure with two subplots
fig, axs = plt.subplots(2, 1, figsize=(10, 12))

# Calculate R-squared value
r_squared = r2_score(y_test, preds)

# Calculate point density
xy = np.vstack([y_test, preds])
z = gaussian_kde(xy)(xy)

# Create a figure with two subplots
fig, axs = plt.subplots(2, 1, figsize=(10, 12))

# Plot True vs Predicted Values on the first subplot with colored points by density
sc = axs[0].scatter(y_test, preds, c=z, cmap='viridis')
axs[0].plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], color='red', linewidth=2)
axs[0].set_xlabel('True Values')
axs[0].set_ylabel('Predicted Values')
axs[0].set_title('True vs Predicted Values')

# Add colorbar
fig.colorbar(sc, ax=axs[0], label='Density')

# Annotate with R-squared value
axs[0].annotate(f'R-squared = {r_squared:.2f}', xy=(0.05, 0.85), xycoords='axes fraction', fontsize=12)

# Calculate residuals
preds = preds.reshape(310163,1)
residuals = y_test - preds

# Plot Distribution of Residuals on the second subplot
axs[1].hist(residuals, bins=50)
axs[1].set_xlabel('Residual')
axs[1].set_ylabel('Frequency')
axs[1].set_title('Distribution of Residuals')
axs[1].set_xlim(-40000, 40000)  # Constrain y-axis to the specified range

# Adjust layout to prevent overlap
plt.tight_layout()

# Save the figure
plt.savefig('combined_plots.png')

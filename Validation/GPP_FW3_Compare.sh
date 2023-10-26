
## 
week=03.16, 05.17, 07.28, 10.08, 12.19
year_list=20, 19, 18, 22, 21, 21, 19, 18, 20, 22, 22, 18, 21, 19, 20, 18, 20, 21, 19, 22, 21, 20, 19, 22, 18
product=5,5,5,5,5,4,4,4,4,4,3,3,3,3,3,2,2,2,2,2,1,1,1,1,1

r.stats -1gn input= MODIS_5yr_AUC_wk2020.03.06_2020,/
MODIS_5yr_AUC_wk2019.05.17_2019,/
MODIS_5yr_AUC_wk2018.07.28_2018,/
MODIS_5yr_AUC_wk2022.10.08_2022,/
MODIS_5yr_AUC_wk2021.12.19_2021,/
MODIS_4yr_AUC_wk2021.03.06_2021,/
MODIS_4yr_AUC_wk2019.05.17_2019,/
MODIS_4yr_AUC_wk2018.07.28_2018,/
MODIS_4yr_AUC_wk2020.10.08_2020,/
MODIS_4yr_AUC_wk2022.12.19_2022,/
MODIS_3yr_AUC_wk2022.03.06_2022,/
MODIS_3yr_AUC_wk2018.05.17_2018,/
MODIS_3yr_AUC_wk2021.07.28_2021,/
MODIS_3yr_AUC_wk2019.10.08_2019,/
MODIS_3yr_AUC_wk2020.12.19_2020,/
MODIS_2yr_AUC_wk2018.03.06_2018,/
MODIS_2yr_AUC_wk2020.05.17_2020,/
MODIS_2yr_AUC_wk2021.07.28_2021,/
MODIS_2yr_AUC_wk2019.10.08_2019,/
MODIS_2yr_AUC_wk2022.12.19_2022,/
MODIS_1yr_AUC_wk2021.03.06_2021,/
MODIS_1yr_AUC_wk2020.05.17_2020,/
MODIS_1yr_AUC_wk2019.07.28_2019,/
MODIS_1yr_AUC_wk2022.10.08_2022,/
MODIS_1yr_AUC_wk2018.12.19_2018,/
pheno>GPP_data.out



# 25 Phenoregion classes

# Paired samples of GPP and FW3 & Phenoregion at different points for each combo

# Classify all samples as S3 or MODIS

# GLM GPP ~ FW3 * Pheno
# GLM GPP ~ FW3 * Pheno + DataClass

# AIC model1 and model2

# ANOVA on Model 2 - is Data Class significant, if so, we have a problem.



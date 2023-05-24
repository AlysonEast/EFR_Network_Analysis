#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

GEE_FILES_IN=1
FW3_REPROJECT=0

#############################################################                                                       
if [ $GEE_FILES_IN -eq 1 ]
then

 g.region rast=wc2.0_bio_30s_01_ann_temp
 g.region res=00:00:15

r.in.gdal input=./data/terraAquaCombined_1yr_auc_2014.tif output=terraAquaCombined_1yr_auc_2014

r.in.gdal input=./data/terraAquaCombined_1yr_auc_2016.tif output=terraAquaCombined_1yr_auc_2016
r.in.gdal input=./data/terraAquaCombined_1yr_auc_2017.tif output=terraAquaCombined_1yr_auc_2017
r.in.gdal input=./data/terraAquaCombined_1yr_auc_2018.tif output=terraAquaCombined_1yr_auc_2018
r.in.gdal input=./data/terraAquaCombined_1yr_auc_2019.tif output=terraAquaCombined_1yr_auc_2019
r.in.gdal input=./data/terraAquaCombined_1yr_auc_2020.tif output=terraAquaCombined_1yr_auc_2020
r.in.gdal input=./data/terraAquaCombined_1yr_auc_2021.tif output=terraAquaCombined_1yr_auc_2021
r.in.gdal input=./data/terraAquaCombined_1yr_auc_2022.tif output=terraAquaCombined_1yr_auc_2022
r.in.gdal input=./data/terraAquaCombined_1yr_auc_2023.tif output=terraAquaCombined_1yr_auc_2023

fi
#############################################################                                                       
if [ $FW3_REPROJECT -eq 1 ]
then
 input=2023.trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45 location=CONUS_Phenology_LAEA mapset=FW_auc -g
 g.region n=48:20:42.302206N s=22:13:42.383255N w=119:32:21.484587W e=62:33:16.177794W rows=14276 cols=20170 -p

 r.proj input=2023.trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45 location=CONUS_Phenology_LAEA mapset=FW_auc
 r.proj input=2022.trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45 location=CONUS_Phenology_LAEA mapset=FW_auc
 r.proj input=2021.trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45 location=CONUS_Phenology_LAEA mapset=FW_auc
 r.proj input=2020.trueS3.S3?-NT.napolygon.maxndvi.LAEA.rseriessum.45 location=CONUS_Phenology_LAEA mapset=FW_auc
 
 r.proj input=fakeS3laea.maxMODIS.2019.std.rseriessum.45 location=CONUS_Phenology_LAEA mapset=FW_auc
 r.proj input=fakeS3laea.maxMODIS.2018.std.rseriessum.45 location=CONUS_Phenology_LAEA mapset=FW_auc
 r.proj input=fakeS3laea.maxMODIS.2017.std.rseriessum.45 location=CONUS_Phenology_LAEA mapset=FW_auc
 r.proj input=fakeS3laea.maxMODIS.2016.std.rseriessum.45 location=CONUS_Phenology_LAEA mapset=FW_auc
 r.proj input=fakeS3laea.maxMODIS.2015.std.rseriessum.45 location=CONUS_Phenology_LAEA mapset=FW_auc
 r.proj input=fakeS3laea.maxMODIS.2014.std.rseriessum.45 location=CONUS_Phenology_LAEA mapset=FW_auc


fi

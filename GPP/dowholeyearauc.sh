#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

year=2015

g.region rast=MODIS_wholeyear_AUC_2023 --o
r.mask -r

#make sure this still works after date changes 
g.mlist type=rast mapset=aly_east pattern="MODIS_max_${year}*" separator="newline" | sort --version-sort >temp

applicable_files=`awk -v start=1 'NR >= start && NR <=45' temp | tr "\n" "+" | rev | cut -c2- | rev`

r.mapcalc "MODIS_wholeyear_AUC_${year} = ${applicable_files}"

r.out.gdal input=MODIS_wholeyear_AUC_${year} output=/tmp/MODIS_wholeyear_AUC_${year}.tif format=GTiff type=Int32

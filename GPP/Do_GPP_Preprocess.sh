#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

FIND_DATEWISE_MAX=1
DO_ANNUAL_AUC_AND_RECLAC_DATEWISEMAX=1

year=2022

export year

./Terra_Preprocess.sh & Aqua_Preprocess.sh

##############################################################
if [ $FIND_DATEWISE_MAX -eq 1 ]
then
for((n=1; n<46; n++)) do
r.mapcalc "MODIS_max_${year}_$((n)) = max(MODIS_terra_${year}_$((n)), MODIS_aqua_${year}_$((n)))"
g.mremove rast=MODIS_terra_${year}_$((n)),MODIS_aqua_${year}_$((n)) -f
done
fi
####################################################################
if [ $DO_ANNUAL_AUC_AND_RECLAC_DATEWISEMAX -eq 1 ]
then
r.mask -r
r.mapcalc "MODIS_CalYear_AUC_${year} = `g.mlist type=rast pattern="MODIS_max_${year}*" separator="+"`"
fi

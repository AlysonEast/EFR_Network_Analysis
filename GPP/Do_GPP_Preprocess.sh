#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

FIND_DATEWISE_MAX=1
#DO_ANNUAL_AUC_AND_RECLAC_DATEWISEMAX=1

year=2021

export year

./Terra_Preprocess.sh
./Aqua_Preprocess.sh

##############################################################
if [ $FIND_DATEWISE_MAX -eq 1 ]
then
num=`wc -l tmp | awk '{print $1}'`

for((n=1; n<${num}; n++)) do
r.null map=MODIS_aqua_${year}_$((n)) null=-1
r.null map=MODIS_terra_${year}_$((n)) null=-1
r.mapcalc "MODIS_max_${year}_$((n)) = max(MODIS_terra_${year}_$((n)), MODIS_aqua_${year}_$((n)))"
r.null map=MODIS_max_${year}_$((n)) setnull=-1
g.mremove rast=MODIS_terra_${year}_$((n)),MODIS_aqua_${year}_$((n)) -f
done
fi
####################################################################
if [ $num -eq 45 ]
then
r.mask -r
r.mapcalc "MODIS_CalYear_AUC_${year} = `g.mlist type=rast pattern="MODIS_max_${year}*" separator="+"`"
fi

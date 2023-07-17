#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

PROCESS_HDF_FILES=0
MOSAIC_BY_DATES=1
FIND_DATEWISE_MAX=1
DO_ANNUAL_AUC_AND_RECLAC_DATEWISEMAX=1

year=2019
version=aqua
code=MOD17A2H

if [ $PROCESS_HDF_FILES -eq 1 ]
then

for  f in ./${version}/${year}/*.hdf
do
echo "Processing $f file..."
 
 gdal_translate -of GTiff HDF4_EOS:EOS_GRID:"$f":MOD_Grid_${code}:Gpp_500m ${f}_step.tif
 gdalwarp -of GTIFF -s_srs '+proj=sinu +R=6371007.181 +nadgrids=@null +wktext' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${f}_step.tif ${f}.tif

rm ${f}_step.tif

done
fi
#####################################################################3
if [ $MOSAIC_BY_DATES -eq 1 ]
then
r.mask -r

for myfile in `ls ./${version}/${year}/*.tif | awk 'BEGIN {FS="/"} {print $4}'`
do
#read files into grass
r.external input=./${version}/${year}/${myfile} output=${version}_${myfile} --o
done

#make list of dates
ls ./${version}/${year}/*.tif | grep "A${year}" | awk 'BEGIN {FS="."} {print $3}' | sort -u >tmp

#loop over list of dates to make mosaics
for ((n=1; n<46; n++)) do
date=`sed -n "$((n))"p tmp`
echo "mosaicing ${date}"

r.patch input=`g.mlist type=rast pattern="${version}*${date}*" separator=","` output=MODIS_${version}_${year}_$((n)) --o
r.null map=MODIS_${version}_${year}_$((n)) setnull=32767,32766,32765,32764,32763,32762,32761

#r.reclass input=MODIS_${version}_${year}_tmp output=temp_mask rules=./reclass --o

#r.mask input=temp_mask --o
#r.mapcalc "MODIS_${version}_${year}_$((n)) = MODIS_${version}_${year}_tmp"

g.mremove rast=`g.mlist type=rast pattern="${version}*${date}*" separator=","` -f
done
fi
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


#r.reclass input=MODIS_CalYear_AUC_${year} output=MODIS_mask_${year} rules=./reclass_annual --o

#r.mask MODIS_mask_${year} --o

#for((n=1; n<46; n++)) do
#r.mapcalc "MODIS_max_${year}_$((n)) = max(MODIS_terra_${year}_$((n)), MODIS_aqua_${year}_$((n)))" 
#done

fi

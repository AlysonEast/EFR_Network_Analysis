#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

PROCESS_HDF_FILES=0
MOSAIC_BY_DATES=0
FIND_DATEWISE_MAX=0



year=2020
version=aqua

if [ $PROCESS_HDF_FILES -eq 1 ]
then

for  f in ./${version}/${year}/*.hdf
do
echo "Processing $f file..."
 
 gdal_translate -a_srs "+init=epsg:4326" -a_nodata 0 \
 -a_ullr -180 90 180 -90 -co "COMPRESS=PACKBITS" \
    HDF4_SDS:UNKNOWN:"$f":1  ${f}_prep.tif
done
fi
#####################################################################3
if [ $MOSAIC_BY_DATES -eq 1 ]
then

for myfile in `ls ./${version}/${year}/*.tif | awk 'BEGIN {FS="/"} {print $4}'`
do
#read files into grass
r.external input=./${version}/${year}/${myfile} output=${version}_${myfile}
done

#make list of dates
dates=`ls ./${version}/${year}/*.tif | grep A${year} | awk 'BEGIN {FS="."} {print $3}' | sort -u`

#loop over list of dates to make mosaics
for ((n=1; n<46; n++)) do
date=`${dates} | sed -n "$((n))"p`
r.patch input=`g.mlist type=rast pattern="${version}*${date}*" separator=","` output=MODIS_${version}_${year}_$((n))
done

#g.mremove

fi
##############################################################
if [ $FIND_DATEWISE_MAX -eq 1 ]
then
for ((n=1: n<46: n++)) do
r.mapcalc "MODIS_max_${year}_$((n)) = max(MODIS_terra_${year}_$((n)), MODIS_aqua_${year}_$((n)))"
done

fi


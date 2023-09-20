#!/bin/bash                                                                                                                                                                                                                                                 

export GISRC=/home/1te/.grassrc6.data

PROCESS_HDF_FILES=1

#year=2021

code=MOD17A2H

if [ $PROCESS_HDF_FILES -eq 1 ]
then

for  f in ./aqua/${year}/*.hdf
do
echo "Processing $f file..."

 gdal_translate -of GTiff HDF4_EOS:EOS_GRID:"$f":MOD_Grid_${code}:Gpp_500m ${f}_step.tif
 gdalwarp -of GTIFF -s_srs '+proj=sinu +R=6371007.181 +nadgrids=@null +wktext' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${f}_step.tif ${f}.tif

rm ${f}_step.tif
rm ${f}

done

for  f in ./terra/${year}/*.hdf
do
echo "Processing $f file..."

 gdal_translate -of GTiff HDF4_EOS:EOS_GRID:"$f":MOD_Grid_${code}:Gpp_500m ${f}_step.tif
 gdalwarp -of GTIFF -s_srs '+proj=sinu +R=6371007.181 +nadgrids=@null +wktext' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${f}_step.tif ${f}.tif

rm ${f}_step.tif
rm ${f}

done
fi


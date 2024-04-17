#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

INGEST_FW3=0
EXTRACT_DATA=1


data_path_a=../../../forwarn/net_ecological_impact/hnw_notprod/WNC2/



if [ $INGEST_FW3 -eq 1 ]
then
 cd ../../../forwarn/
 mkdir ./proj/
 r.mask -r
 g.region rast=MODIS_EOY_AUC_2022
 g.region n=54:10:30N  s=20:44N  e=62:57:30W  w=129:50W
	for  f in *.S3.wholeyear.conus.partialsum.tif
	do
		echo "Processing $f file..."
		gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${f} ./proj/${f} -overwrite
		r.in.gdal input=./proj/${f} output=${f} --o
	done
 cd /mnt/poseidon/remotesensing/1te/FW3/Validation
fi


if [ $EXTRACT_DATA -eq 1 ]
then
 r.mask -r
 g.region rast=MODIS_EOY_AUC_2022
 g.region n=54:10:30N  s=20:44N  e=62:57:30W  w=129:50W
 for ((y=0; y<6; y++)) do
	cal_year=$((2023-$((y))))
	echo "year is ${cal_year}"
	
	r.stats -1gn input=${cal_year}.S3.wholeyear.conus.partialsum.tif,MODIS_wholeyear_AUC_${cal_year}>./wholeyears/${cal_year}_compare	
	sed -i "1s/^/Lat Lon FW3 GPP\n/" ./wholeyears/${cal_year}_compare


	done
fi

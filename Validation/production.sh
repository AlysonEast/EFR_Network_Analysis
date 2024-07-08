#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

MOVE_DATA_TO_MAPSET=1
EXTRACT_DATA_FOR_FIT=0
RUN_PYTHON=0
FIT_TO_MAP=1


data_path_a=../../../forwarn/net_ecological_impact/hnw_notprod/newconus/

regionName=napolygon

currYEAR=2023
currYEAR3=2023

currint=24
#pct=$(($((2020-$((${year}-${product}))))/$((${product}+1))))

currint=`echo $line | awk -F"|" '{print $1}'`

BEGIN3=`echo $line | awk -F"|" '{print substr($4,1,2)"-"substr($4,3,2)}'` 

END3=`echo $line | awk -F"|" '{print substr($5,1,2)"-"substr($5,3,2)}'` 


# set output phenosum filenames
aucdeparturephenosum0yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc0yrdeparture.phenosum.LAEA"
echo "aucdeparturephenosum0yrfile is" $aucdeparturephenosum0yrfile

aucdeparturephenosum1yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc1yrdeparture.phenosum.LAEA"
echo "aucdeparturephenosum1yrfile is" $aucdeparturephenosum1yrfile

aucdeparturephenosum2yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc2yrdeparture.phenosum.LAEA"
echo "aucdeparturephenosum2yrfile is" $aucdeparturephenosum2yrfile

aucdeparturephenosum3yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc3yrdeparture.phenosum.LAEA"
echo "aucdeparturephenosum3yrfile is" $aucdeparturephenosum3yrfile

aucdeparturephenosum4yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc4yrdeparture.phenosum.LAEA"
echo "aucdeparturephenosum4yrfile is" $aucdeparturephenosum4yrfile

aucdeparturephenosum5yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc5yrdeparture.phenosum.LAEA"
echo "aucdeparturephenosum5yrfile is" $aucdeparturephenosum5yrfile



# set output S3sum filenames
aucdepartureS3sum0yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc0yrdeparture.S3sum.LAEA"
echo "aucdepartureS3sum0yrfile is" $aucdepartureS3sum0yrfile

aucdepartureS3sum1yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc1yrdeparture.S3sum.LAEA"
echo "aucdepartureS3sum1yrfile is" $aucdepartureS3sum1yrfile

aucdepartureS3sum2yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc2yrdeparture.S3sum.LAEA"
echo "aucdepartureS3sum2yrfile is" $aucdepartureS3sum2yrfile

aucdepartureS3sum3yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc3yrdeparture.S3sum.LAEA"
echo "aucdepartureS3sum3yrfile is" $aucdepartureS3sum3yrfile

aucdepartureS3sum4yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc4yrdeparture.S3sum.LAEA"
echo "aucdepartureS3sum4yrfile is" $aucdepartureS3sum4yrfile

aucdepartureS3sum5yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc5yrdeparture.S3sum.LAEA"
echo "aucdepartureS3sum5yrfile is" $aucdepartureS3sum5yrfile


# set dateskipper flags appropriately for this interval
if [[ $[ $currint % 2] == 0 ]]; then
  do2yrflag=1
fi

if [[ $[ $currint % 5] == 0 ]]; then
  do3yrflag=1
fi

if [ $currint -eq 24 ] || [ $currint -eq 35 ] || [ $currint -eq 1 ] || [ $currint -eq 13 ]; then
  do45yrflag=1
fi



if [ $MOVE_DATA_TO_MAPSET -eq 1 ]
then
 r.mask -r
 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdeparturephenosum0yrfile} ./proj/${aucdeparturephenosum0yrfile} -overwrite
 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdepartureS3sum0yrfile} ./proj/${aucdepartureS3sum0yrfile} -overwrite
 r.in.gdal input=./proj/${aucdepartureS3sum0yrfile} output=${aucdepartureS3sum0yrfile} --o
 r.in.gdal input=./proj/${aucdeparturephenosum0yrfile} output=${aucdeparturephenosum0yrfile} --o

 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdeparturephenosum1yrfile} ./proj/${aucdeparturephenosum1yrfile} -overwrite
 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdepartureS3sum1yrfile} ./proj/${aucdepartureS3sum1yrfile} -overwrite
 r.in.gdal input=./proj/${aucdepartureS3sum1yrfile} output=${aucdepartureS3sum1yrfile} --o
 r.in.gdal input=./proj/${aucdeparturephenosum1yrfile} output=${aucdeparturephenosum1yrfile} --o

	if [ $do2yrflag -eq 1 ]
	then
	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdeparturephenosum2yrfile} ./proj/${aucdeparturephenosum2yrfile} -overwrite
 	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdepartureS3sum2yrfile} ./proj/${aucdepartureS3sum2yrfile} -overwrite
	 r.in.gdal input=./proj/${aucdepartureS3sum2yrfile} output=${aucdepartureS3sum2yrfile} --o
	 r.in.gdal input=./proj/${aucdeparturephenosum2yrfile} output=${aucdeparturephenosum2yrfile} --o
	fi

	if [ $do3yrflag -eq 1 ]
	then
	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdeparturephenosum3yrfile} ./proj/${aucdeparturephenosum3yrfile} -overwrite
 	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdepartureS3sum3yrfile} ./proj/${aucdepartureS3sum3yrfile} -overwrite
	 r.in.gdal input=./proj/${aucdepartureS3sum3yrfile} output=${aucdepartureS3sum3yrfile} --o
	 r.in.gdal input=./proj/${aucdeparturephenosum3yrfile} output=${aucdeparturephenosum3yrfile} --o
	fi

	if [ $do45yrflag -eq 1 ]
	then
	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdeparturephenosum4yrfile} ./proj/${aucdeparturephenosum4yrfile} -overwrite
 	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdepartureS3sum4yrfile} ./proj/${aucdepartureS3sum4yrfile} -overwrite
	 r.in.gdal input=./proj/${aucdepartureS3sum4yrfile} output=${aucdepartureS3sum4yrfile} --o
	 r.in.gdal input=./proj/${aucdeparturephenosum4yrfile} output=${aucdeparturephenosum4yrfile} --o

	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdeparturephenosum5yrfile} ./proj/${aucdeparturephenosum5yrfile} -overwrite
 	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdepartureS3sum5yrfile} ./proj/${aucdepartureS3sum5yrfile} -overwrite
	 r.in.gdal input=./proj/${aucdepartureS3sum5yrfile} output=${aucdepartureS3sum5yrfile} --o
	 r.in.gdal input=./proj/${aucdeparturephenosum5yrfile} output=${aucdeparturephenosum5yrfile} --o
	fi
fi

if [ $EXTRACT_DATA_FOR_FIT -eq 1 ]
then
 r.mask -r
 g.region rast=${aucdeparturephenosum0yrfile}


 r.stats -1gn input=${map_pheno},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_pheno
 r.stats -1gn input=${map_S3},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_S3
 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_pheno
 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_S3

 conda activate 
 python ./production_model_v2.py ${currint} ${pct}
fi


if [ $FIT_TO_MAP -eq 1 ]
then

 date=2023.07.04
 r.mask -r
 g.region rast=${map_S3}

 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_pheno.csv | sed '1d' >temp
 r.in.xyz in=temp out=${date}_GPP_converted_pheno x=1 y=2 z=3 type=CELL fs=space --o

 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_S3.csv | sed '1d' >temp
 r.in.xyz in=temp out=${date}_GPP_converted_S3 x=1 y=2 z=3 type=CELL fs=space --o

 r.mapcalc "${date}_GPP_diff = ${date}_GPP_converted_S3 - ${date}_GPP_converted_pheno"
 
 d.mon x2
 d.rast ${date}_GPP_diff
# r.out.gdal in=${date}_GPP_converted_pheno out=./export/${date}_GPP_converted_pheno.tif type=Float64 format=GTiff --o
# r.out.gdal in=${date}_GPP_converted_S3 out=./export/${date}_GPP_converted_S3.tif type=Float64 format=GTiff --o
r.out.gdal in=${date}_GPP_diff out=./export/${date}_GPP_converted_diff.tif type=Float64 format=GTiff --o


fi


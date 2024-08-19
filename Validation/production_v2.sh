#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

exec > logfile.txt

date

MOVE_DATA_TO_MAPSET=1
EXTRACT_DATA_FOR_FIT=1


data_path_a=../../../forwarn/net_ecological_impact/hnw_notprod/newconus/

regionName=napolygon

currYEAR=2023
currYEAR3=2023

currint=35
line=${currint}
#pct=$(($((2020-$((${year}-${product}))))/$((${product}+1))))

line=`cat reglookup3.txt | awk -v var="${currint}" 'NR==var'`

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



g.region rast=${aucdeparturephenosum0yrfile}
if [ $MOVE_DATA_TO_MAPSET -eq 1 ]
then
 r.mask -r
 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdeparturephenosum0yrfile}.tiff ./proj/${aucdeparturephenosum0yrfile}.tiff -overwrite
 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdepartureS3sum0yrfile}.tiff ./proj/${aucdepartureS3sum0yrfile}.tiff -overwrite
 r.in.gdal input=./proj/${aucdepartureS3sum0yrfile}.tiff output=${aucdepartureS3sum0yrfile} --o
 r.in.gdal input=./proj/${aucdeparturephenosum0yrfile}.tiff output=${aucdeparturephenosum0yrfile} --o

 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdeparturephenosum1yrfile}.tiff ./proj/${aucdeparturephenosum1yrfile}.tiff -overwrite
 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdepartureS3sum1yrfile}.tiff ./proj/${aucdepartureS3sum1yrfile}.tiff -overwrite
 r.in.gdal input=./proj/${aucdepartureS3sum1yrfile}.tiff output=${aucdepartureS3sum1yrfile} --o
 r.in.gdal input=./proj/${aucdeparturephenosum1yrfile}.tiff output=${aucdeparturephenosum1yrfile} --o

	if [ $do2yrflag -eq 1 ]
	then
	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdeparturephenosum2yrfile}.tiff ./proj/${aucdeparturephenosum2yrfile}.tiff -overwrite
 	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdepartureS3sum2yrfile}.tiff ./proj/${aucdepartureS3sum2yrfile}.tiff -overwrite
	 r.in.gdal input=./proj/${aucdepartureS3sum2yrfile}.tiff output=${aucdepartureS3sum2yrfile} --o
	 r.in.gdal input=./proj/${aucdeparturephenosum2yrfile}.tiff output=${aucdeparturephenosum2yrfile} --o
	fi

	if [ $do3yrflag -eq 1 ]
	then
	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdeparturephenosum3yrfile}.tiff ./proj/${aucdeparturephenosum3yrfile}.tiff -overwrite
 	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdepartureS3sum3yrfile}.tiff ./proj/${aucdepartureS3sum3yrfile}.tiff -overwrite
	 r.in.gdal input=./proj/${aucdepartureS3sum3yrfile}.tiff output=${aucdepartureS3sum3yrfile} --o
	 r.in.gdal input=./proj/${aucdeparturephenosum3yrfile}.tiff output=${aucdeparturephenosum3yrfile} --o
	fi

	if [ $do45yrflag -eq 1 ]
	then
	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdeparturephenosum4yrfile}.tiff ./proj/${aucdeparturephenosum4yrfile}.tiff -overwrite
 	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdepartureS3sum4yrfile}.tiff ./proj/${aucdepartureS3sum4yrfile}.tiff -overwrite
	 r.in.gdal input=./proj/${aucdepartureS3sum4yrfile}.tiff output=${aucdepartureS3sum4yrfile} --o
	 r.in.gdal input=./proj/${aucdeparturephenosum4yrfile}.tiff output=${aucdeparturephenosum4yrfile} --o

	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdeparturephenosum5yrfile}.tiff ./proj/${aucdeparturephenosum5yrfile}.tiff -overwrite
 	 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${data_path_a}${aucdepartureS3sum5yrfile}.tiff ./proj/${aucdepartureS3sum5yrfile}.tiff -overwrite
	 r.in.gdal input=./proj/${aucdepartureS3sum5yrfile}.tiff output=${aucdepartureS3sum5yrfile} --o
	 r.in.gdal input=./proj/${aucdeparturephenosum5yrfile}.tiff output=${aucdeparturephenosum5yrfile} --o
	fi
fi

if [ $EXTRACT_DATA_FOR_FIT -eq 1 ]
then
 r.mask -r
 g.region rast=${aucdeparturephenosum0yrfile}

 # set output S3sum filenames
 GPPaucS3sum0yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc0yr.S3sum.GPP"
 GPPaucS3sum1yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc1yr.S3sum.GPP"
 GPPaucS3sum2yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc2yr.S3sum.GPP"
 GPPaucS3sum3yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc3yr.S3sum.GPP"
 GPPaucS3sum4yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc4yr.S3sum.GPP"
 GPPaucS3sum5yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc5yr.S3sum.GPP"
 # set output pheno sum filenames
 GPPaucphenosum0yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc0yr.phenosum.GPP"
 GPPaucphenosum1yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc1yr.phenosum.GPP"
 GPPaucphenosum2yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc2yr.phenosum.GPP"
 GPPaucphenosum3yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc3yr.phenosum.GPP"
 GPPaucphenosum4yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc4yr.phenosum.GPP"
 GPPaucphenosum5yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc5yr.phenosum.GPP"
 # set output pheno sum filenames
 GPPaucdiff0yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc0yrdeparture.GPP"
 GPPaucdiff1yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc1yrdeparture.GPP"
 GPPaucdiff2yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc2yrdeparture.GPP"
 GPPaucdiff3yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc3yrdeparture.GPP"
 GPPaucdiff4yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc4yrdeparture.GPP"
 GPPaucdiff5yrfile=$currYEAR3"-"$BEGIN3"_"$currYEAR3"-"$END3"."$regionName".auc5yrdeparture.GPP"


 #_______________________________________________0 Year product conversion___________________________________________________________
 r.stats -1gn input=${aucdeparturephenosum0yrfile},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_pheno
 r.stats -1gn input=${aucdepartureS3sum0yrfile},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_S3
 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_pheno
 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_S3

 pct=1 #update later

 #Run the python script to convert
 # conda activate xgboost_env 
 python ./production_model_v2.py ${currint} ${pct}

 r.mask -r
 g.region rast=${aucdeparturephenosum0yrfile}

 #Convert Python outputs to GRASS Maps 
 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_pheno.csv | sed '1d' >temp
 r.in.xyz in=temp out=${GPPaucphenosum0yrfile} x=1 y=2 z=3 type=CELL fs=space --o

 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_S3.csv | sed '1d' >temp
 r.in.xyz in=temp out=${GPPaucS3sum0yrfile} x=1 y=2 z=3 type=CELL fs=space --o

 #Mapcalc the divergence product
 r.mapcalc "'${GPPaucdiff0yrfile}' = '${GPPaucS3sum0yrfile}' - '${GPPaucphenosum0yrfile}'"
 #write out to tiff
 r.colors map=${GPPaucdiff0yrfile} rules=GPP_Color
 r.out.gdal in=${GPPaucdiff0yrfile} out=./export/${GPPaucdiff0yrfile}.tif type=Float64 format=GTiff --o

 #_______________________________________________1 Year product conversion_________________________________________________________
 r.stats -1gn input=${aucdeparturephenosum1yrfile},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_pheno
 r.stats -1gn input=${aucdepartureS3sum1yrfile},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_S3
 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_pheno
 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_S3

 pct=1 #update later

 #Run the python script to convert
 python ./production_model_v2.py ${currint} ${pct}

 #Convert Python outputs to GRASS Maps 
 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_pheno.csv | sed '1d' >temp
 r.in.xyz in=temp out=${GPPaucphenosum1yrfile} x=1 y=2 z=3 type=CELL fs=space --o

 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_S3.csv | sed '1d' >temp
 r.in.xyz in=temp out=${GPPaucS3sum1yrfile} x=1 y=2 z=3 type=CELL fs=space --o

 #Mapcalc the divergence product
 r.mapcalc "'${GPPaucdiff1yrfile}' = '${GPPaucS3sum1yrfile}' - '${GPPaucphenosum1yrfile}'"
 #write out to tiff
 r.colors map=${GPPaucdiff1yrfile} rules=GPP_Color
 r.out.gdal in=${GPPaucdiff1yrfile} out=./export/${GPPaucdiff1yrfile}.tif type=Float64 format=GTiff --o


	if [ $do2yrflag -eq 1 ]
        then
	 r.stats -1gn input=${aucdeparturephenosum2yrfile},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_pheno
	 r.stats -1gn input=${aucdepartureS3sum2yrfile},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_S3
	 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_pheno
	 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_S3

	 pct=1 #update later

	 #Run the python script to convert
	 python ./production_model_v2.py ${currint} ${pct}

	 #Convert Python outputs to GRASS Maps 
	 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_pheno.csv | sed '1d' >temp
	 r.in.xyz in=temp out=${GPPaucphenosum2yrfile} x=1 y=2 z=3 type=CELL fs=space --o

	 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_S3.csv | sed '1d' >temp
	 r.in.xyz in=temp out=${GPPaucS3sum2yrfile} x=1 y=2 z=3 type=CELL fs=space --o

	 #Mapcalc the divergence product
	 r.mapcalc "'${GPPaucdiff2yrfile}' = '${GPPaucS3sum2yrfile}' - '${GPPaucphenosum2yrfile}'"
	 #write out to tiff
	 r.colors map=${GPPaucdiff2yrfile} rules=GPP_Color
	 r.out.gdal in=${GPPaucdiff2yrfile} out=./export/${GPPaucdiff2yrfile}.tif type=Float64 format=GTiff --o
	fi


	if [ $do3yrflag -eq 1 ]
        then
	 r.stats -1gn input=${aucdeparturephenosum3yrfile},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_pheno
	 r.stats -1gn input=${aucdepartureS3sum3yrfile},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_S3
	 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_pheno
	 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_S3

	 pct=0.75 #update later

	 #Run the python script to convert
	 python ./production_model_v2.py ${currint} ${pct}

	 #Convert Python outputs to GRASS Maps 
	 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_pheno.csv | sed '1d' >temp
	 r.in.xyz in=temp out=${GPPaucphenosum3yrfile} x=1 y=2 z=3 type=CELL fs=space --o

	 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_S3.csv | sed '1d' >temp
	 r.in.xyz in=temp out=${GPPaucS3sum3yrfile} x=1 y=2 z=3 type=CELL fs=space --o

	 #Mapcalc the divergence product
	 r.mapcalc "'${GPPaucdiff3yrfile}' = '${GPPaucS3sum3yrfile}' - '${GPPaucphenosum3yrfile}'"
	 #write out to tiff
	 r.colors map=${GPPaucdiff3yrfile} rules=GPP_Color
	 r.out.gdal in=${GPPaucdiff3yrfile} out=./export/${GPPaucdiff3yrfile}.tif type=Float64 format=GTiff --o
	fi

	if [ $do45yrflag -eq 1 ]
        then
	 r.stats -1gn input=${aucdeparturephenosum4yrfile},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_pheno
	 r.stats -1gn input=${aucdepartureS3sum4yrfile},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_S3
	 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_pheno
	 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_S3

	 pct=0.6 #update later

	 #Run the python script to convert
	 python ./production_model_v2.py ${currint} ${pct}

	 #Convert Python outputs to GRASS Maps 
	 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_pheno.csv | sed '1d' >temp
	 r.in.xyz in=temp out=${GPPaucphenosum4yrfile} x=1 y=2 z=3 type=CELL fs=space --o

	 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_S3.csv | sed '1d' >temp
	 r.in.xyz in=temp out=${GPPaucS3sum4yrfile} x=1 y=2 z=3 type=CELL fs=space --o

	 #Mapcalc the divergence product
	 r.mapcalc "'${GPPaucdiff4yrfile}' = '${GPPaucS3sum4yrfile}' - '${GPPaucphenosum4yrfile}'"
	 #write out to tiff
	 r.colors map=${GPPaucdiff4yrfile} rules=GPP_Color
	 r.out.gdal in=${GPPaucdiff4yrfile} out=./export/${GPPaucdiff4yrfile}.tif type=Float64 format=GTiff --o

	 r.stats -1gn input=${aucdeparturephenosum5yrfile},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_pheno
	 r.stats -1gn input=${aucdepartureS3sum5yrfile},phenology_2000-2016.100.maxmode,minint>./tmp_map_for_GPP_conversion_S3
	 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_pheno
	 sed -i "1s/^/Lat Lon FW3 pheno minint\n/" tmp_map_for_GPP_conversion_S3

	 pct=0.5 #update later

	 #Run the python script to convert
	 conda activate xgboost_env 
	 python ./production_model_v2.py ${currint} ${pct}

	 #Convert Python outputs to GRASS Maps 
	 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_pheno.csv | sed '1d' >temp
	 r.in.xyz in=temp out=${GPPaucphenosum5yrfile} x=1 y=2 z=3 type=CELL fs=space --o

	 awk 'BEGIN {FS=","}; {print $1" "$2" "$8}' GPP_converted_S3.csv | sed '1d' >temp
	 r.in.xyz in=temp out=${GPPaucS3sum5yrfile} x=1 y=2 z=3 type=CELL fs=space --o

	 #Mapcalc the divergence product
	 r.mapcalc "'${GPPaucdiff5yrfile}' = '${GPPaucS3sum5yrfile}' - '${GPPaucphenosum5yrfile}'"
	 #write out to tiff
	 r.colors map=${GPPaucdiff5yrfile} rules=GPP_Color
	 r.out.gdal in=${GPPaucdiff5yrfile} out=./export/${GPPaucdiff5yrfile}.tif type=Float64 format=GTiff --o
	fi

fi

date

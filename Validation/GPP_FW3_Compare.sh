#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

MOVE_FW_DATA=0
INGEST_FW3=0
EXTRACT_DATA=0
EXTRACT_DATA_FOR_FIT=0
FIT_TO_MAP=1

year0_weeks=( 30 1 23 15 38 8 )
year1_weeks=( 8 30 1 38 15 23 )
year2_weeks=( 14 36 30 44 6 22 )
year3_weeks=( 45 20 40 5 30 10 )
year4_weeks=( 1 35 24 13 1 35 )
year5_weeks=( 35 24 24 35 1 13 )

data_path_a=../../../forwarn/net_ecological_impact/hnw_notprod/WNC2/
data_path_b=../../../forwarn/net_ecological_impact/hnw_notprod2/WNC2/


if [ $MOVE_FW_DATA -eq 1 ]
then
 for ((y=0; y<6; y++)) do
        cal_year=$((2023-$((y))))
        echo "-------------------------------------year is ${cal_year}--------------------------------------------------------"

        for ((p=0; p<6; p++)) do
		echo "${p} year"
                name=year$((p))_weeks
                w=$((${name}[$((y))]+1))
                week=`cat ../GPP/keys/date_key_${cal_year}.txt | awk 'BEGIN {FS="|";} {print $3}' | sed -n "$((${w}))"p | tr "." "-"`
                                  
		file=`ls ${data_path_a} ${data_path_b} | grep ${week} | grep auc$((p))yrdeparture.S3sum.LAEA.tiff`
		echo "copying ${file}"
		cp ${data_path_a}${file} ../../../forwarn/GPP_Comparison/ 
		cp ${data_path_b}${file} ../../../forwarn/GPP_Comparison/ 
		file_rename=`echo ${file} | tr "-" "."`
		cd ../../../forwarn/GPP_Comparison/
		mv ${file} ${file_rename}
                cd /mnt/poseidon/remotesensing/1te/FW3/Validation/
	done
 done
 cp ${data_path_b}2020-12-11_2020-12-18.napolygon.auc2yrdeparture.S3sum.LAEA.tiff ../../../forwarn/GPP_Comparison/
 mv ../../../forwarn/GPP_Comparison/2020-12-11_2020-12-18.napolygon.auc2yrdeparture.S3sum.LAEA.tiff ../../../forwarn/GPP_Comparison/2020.12.10_2020.12.18.napolygon.auc2yrdeparture.S3sum.LAEA.tiff

 cp ${data_path_a}2020-04-07_2020-04-14.napolygon.auc4yrdeparture.S3sum.LAEA.tiff ../../../forwarn/GPP_Comparison/
 mv ../../../forwarn/GPP_Comparison/2020-04-07_2020-04-14.napolygon.auc4yrdeparture.S3sum.LAEA.tiff ../../../forwarn/GPP_Comparison/2020.04.06_2020.04.14.napolygon.auc4yrdeparture.S3sum.LAEA.tiff

 cp ${data_path_b}2020-09-30_2020-10-07.napolygon.auc5yrdeparture.S3sum.LAEA.tiff ../../../forwarn/GPP_Comparison/
 mv ../../../forwarn/GPP_Comparison/2020-09-30_2020-10-07.napolygon.auc5yrdeparture.S3sum.LAEA.tiff ../../../forwarn/GPP_Comparison/2020.09.29_2020.10.07.napolygon.auc5yrdeparture.S3sum.LAEA.tiff

 ls ../../../forwarn/GPP_Comparison/ -lah
fi


if [ $INGEST_FW3 -eq 1 ]
then
 cd ../../../forwarn/GPP_Comparison
 mkdir ./proj/
 r.mask -r
 g.region rast=MODIS_EOY_AUC_2022
 g.region n=52:20:25.224106N s=18:15:45.899015N e=61:45:33.03282W w=130:39:52.018747W
	for  f in *.tiff
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
 g.region n=35:58:09.842772N s=34:37:09.473326N e=82:23:16.830797W w=84:34:16.48182W
 for ((y=0; y<6; y++)) do
	cal_year=$((2023-$((y))))
	echo "year is ${cal_year}"

	for ((p=0; p<6; p++)) do
		echo "${p} year"
		name=year$((p))_weeks
		w=$((${name}[$((y))]+1))
		week=`cat ../GPP/keys/date_key_${cal_year}.txt | awk 'BEGIN {FS="|";} {print $3}' | sed -n "$((${w}))"p`
		echo "week number ${name[2]} is ${week}"
		
		#get FW name
		FW=`ls ../../../forwarn/GPP_Comparison/ | grep ${week} | grep auc$((p))yrdeparture.S3sum.LAEA.tiff`	

		#r.stats -1gn input= MODIS_${p}yr_AUC_wk${week}_${cal_year},${FW},phenology_2000-2016.100.maxmode | sort -R | head -n 100000>./samples/samples_${cal_year}_${p}yr_${week}
		r.stats -1gn input=MODIS_${p}yr_AUC_wk${week}_${cal_year},${FW},phenology_2000-2016.100.maxmode>./samples/samples_${cal_year}_${p}yr_${week}
	done
 done
fi

if [ $EXTRACT_DATA_FOR_FIT -eq 1 ]
then
 r.mask -r

 map_pheno=2023-07-04_2023-07-11.napolygon.auc5yrdeparture.phenosum.LAEA.tiff
 map_S3=2023-07-04_2023-07-11.napolygon.auc5yrdeparture.S3sum.LAEA.tiff

 cp ${data_path_a}${map_pheno} ./
 cp ${data_path_a}${map_S3} ./
 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${map_pheno} ./${map_pheno}_proj -overwrite
 gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${map_S3} ./${map_S3}_proj -overwrite
 r.in.gdal input=./${map_pheno}_proj output=${map_pheno} --o
 r.in.gdal input=./${map_S3}_proj output=${map_S3} --o

 g.region rast=${map_S3}
 r.stats -1gn input=${map_pheno},phenology_2000-2016.100.maxmode>./map_for_GPP_conversion_pheno
 r.stats -1gn input=${map_S3},phenology_2000-2016.100.maxmode>./map_for_GPP_conversion_S3
 sed -i "1s/^/Lat Lon FW3 pheno\n/" map_for_GPP_conversion_pheno
 sed -i "1s/^/Lat Lon FW3 pheno\n/" map_for_GPP_conversion_S3

fi


if [ $FIT_TO_MAP -eq 1 ]
then
 map_S3=2023-07-04_2023-07-11.napolygon.auc5yrdeparture.S3sum.LAEA.tiff
 map_pheno=2023-07-04_2023-07-11.napolygon.auc5yrdeparture.phenosum.LAEA.tiff
 date=2023.07.04
 r.mask -r
 g.region rast=${map_S3}


 awk 'BEGIN {FS=","}; {print $1" "$2" "$7}' GPP_converted_pheno.csv | sed '1d' >temp
 r.in.xyz in=temp out=${date}_GPP_converted_pheno x=1 y=2 z=3 type=CELL fs=space --o

 awk 'BEGIN {FS=","}; {print $1" "$2" "$7}' GPP_converted_S3.csv | sed '1d' >temp
 r.in.xyz in=temp out=${date}_GPP_converted_S3 x=1 y=2 z=3 type=CELL fs=space --o

 r.mapcalc "${date}_GPP_converted_diff = ${date}_GPP_converted_S3 - ${date}_GPP_converted_pheno"
 
 r.out.gdal in=${date}_GPP_converted_pheno out=./export/${date}_GPP_converted_pheno.tif type=Float64 format=GTiff --o
 r.out.gdal in=${date}_GPP_converted_S3 out=./export/${date}_GPP_converted_S3.tif type=Float64 format=GTiff --o
 r.out.gdal in=${date}_GPP_converted_diff out=./export/${date}_GPP_converted_diff.tif type=Float64 format=GTiff --o

 r.out.gdal in=${map_S3} out=./export/${map_S3}.tif type=Float64 format=GTiff --o
 r.out.gdal in=${map_pheno} out=./export/${map_pheno}.tif type=Float64 format=GTiff --o

fi


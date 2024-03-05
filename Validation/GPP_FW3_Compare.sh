#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

MOVE_FW_DATA=1
INGEST_FW3=0
EXTRACT_DATA=0

year0_weeks=( 30 1 23 15 38 8 )
year1_weeks=( 8 30 1 38 15 23 )
year2_weeks=( 14 36 30 44 6 22 )
year3_weeks=( 45 20 40 5 30 10 )
year4_weeks=( 1 35 24 13 1 35 )
year5_weeks=( 35 24 24 35 1 13 )

if [ $MOVE_FW_DATA -eq 1 ]
then
 for ((y=0; y<6; y++)) do
        cal_year=$((2023-$((y))))
        echo "year is ${cal_year}"

        for ((p=0; p<6; p++)) do
                echo "${p} year"
                name=year$((p))_weeks
                w=$((${name}[$((y))]+1))
                week=`cat ../GPP/keys/date_key_${cal_year}.txt | awk 'BEGIN {FS="|";} {print $3}' | sed -n "$((${w}))"p | tr "." "-"`
                                  
		file=`ls ../../../forwarn/net_ecological_impact/hnw_notprod ../../../forwarn/net_ecological_impact/hnw_notprod2 | grep ${week} | grep auc$((p))yrdeparture.S3sum.LAEA.tiff`
		echo "copying ${file}"
		cp ../../../forwarn/net_ecological_impact/hnw_notprod/${file} ../../../forwarn/GPP_Comparison/ 
		cp ../../../forwarn/net_ecological_impact/hnw_notprod2/${file} ../../../forwarn/GPP_Comparison/ 
		file_rename=`echo ${file} | tr "-" "."`
		mv ../../../forwarn/GPP_Comparison/${file} ../../../forwarn/GPP_Comparison/${file_rename}
	done
 done
fi


if [ $INGEST_FW3 -eq 1 ]
then
 cd ../../../forwarn/GPP_Comparison
	for  f in ./*.tiff
	do
		echo "Processing $f file..."
		gdalwarp -of GTIFF -s_srs '+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs' -r near -t_srs '+proj=longlat +datum=WGS84 +no_defs' ${f} ./proj/${f}
		r.in.gdal input=./proj/${f} output=${f} --o
	done
 cd /mnt/poseidon/remotesensing/1te/FW3/Validation
fi


if [ $EXTRACT_DATA -eq 1 ]
then
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

		r.stats -1gn input= MODIS_${p}yr_AUC_wk${week}_${cal_year},${FW},phenology_2000-2016.100.maxmode | sort -R | head -n 100000>./samples/samples_${cal_year}_${p}yr_${week}
	done
 done
fi




# 25 Phenoregion classes

# Paired samples of GPP and FW3 & Phenoregion at different points for each combo

# Classify all samples as S3 or MODIS

# GLM GPP ~ FW3 * Pheno
# GLM GPP ~ FW3 * Pheno + DataClass

# AIC model1 and model2

# ANOVA on Model 2 - is Data Class significant, if so, we have a problem.



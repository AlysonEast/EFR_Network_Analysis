#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

ZONAL=0
MAP_PHENO_CHUNKS=0
EXPORT_PHENO_CHUNKS=1



if [ $ZONAL -eq 1 ]
then
 r.mask -r
 r.mask ESA_GLOBCOVER maskcats=210 -i --o
 g.region rast=2021.pheno.wholeyear.partialsum

 r.univar -t map=2021.pheno.wholeyear.partialsum zones=phenology_2000-2016.100.maxmode output=pheno100_univar.vect.out
fi


if [ $MAP_PHENO_CHUNKS -eq 1 ]
then
 r.mask -r
 r.mask ESA_GLOBCOVER maskcats=210 -i --o
 g.region rast=2021.pheno.wholeyear.partialsum

 r.mapcalc "'phenology_2000-2016.100.maxmode_nowater' = 'phenology_2000-2016.100.maxmode'"
 
 list=`awk 'BEGIN { FS="|"; } {print $8" "$1}' pheno100_univar.vect.out | sort -n | awk '{print $2}' | sed '1d' | sed -n '1,10p' | tr '\n' ' ' | sed 's/.$//'`
 r.mask phenology_2000-2016.100.maxmode_nowater maskcats="${list}" --o
 r.mapcalc "pheno_chunk1 = 'phenology_2000-2016.100.maxmode_nowater'"

 list=`awk 'BEGIN { FS="|"; } {print $8" "$1}' pheno100_univar.vect.out | sort -n | awk '{print $2}' | sed '1d' | sed -n '11,20p' | tr '\n' ' ' | sed 's/.$//'`
 r.mask phenology_2000-2016.100.maxmode_nowater maskcats="${list}" --o
 r.mapcalc "pheno_chunk2 = 'phenology_2000-2016.100.maxmode_nowater'"

 list=`awk 'BEGIN { FS="|"; } {print $8" "$1}' pheno100_univar.vect.out | sort -n | awk '{print $2}' | sed '1d' | sed -n '21,30p' | tr '\n' ' ' | sed 's/.$//'`
 r.mask phenology_2000-2016.100.maxmode_nowater maskcats="${list}" --o
 r.mapcalc "pheno_chunk3 = 'phenology_2000-2016.100.maxmode_nowater'"

 list=`awk 'BEGIN { FS="|"; } {print $8" "$1}' pheno100_univar.vect.out | sort -n | awk '{print $2}' | sed '1d' | sed -n '31,40p' | tr '\n' ' ' | sed 's/.$//'`
 r.mask phenology_2000-2016.100.maxmode_nowater maskcats="${list}" --o
 r.mapcalc "pheno_chunk4 = 'phenology_2000-2016.100.maxmode_nowater'"

 list=`awk 'BEGIN { FS="|"; } {print $8" "$1}' pheno100_univar.vect.out | sort -n | awk '{print $2}' | sed '1d' | sed -n '41,50p' | tr '\n' ' ' | sed 's/.$//'`
 r.mask phenology_2000-2016.100.maxmode_nowater maskcats="${list}" --o
 r.mapcalc "pheno_chunk5 = 'phenology_2000-2016.100.maxmode_nowater'"

 list=`awk 'BEGIN { FS="|"; } {print $8" "$1}' pheno100_univar.vect.out | sort -n | awk '{print $2}' | sed '1d' | sed -n '51,60p' | tr '\n' ' ' | sed 's/.$//'`
 r.mask phenology_2000-2016.100.maxmode_nowater maskcats="${list}" --o
 r.mapcalc "pheno_chunk6 = 'phenology_2000-2016.100.maxmode_nowater'"

 list=`awk 'BEGIN { FS="|"; } {print $8" "$1}' pheno100_univar.vect.out | sort -n | awk '{print $2}' | sed '1d' | sed -n '61,70p' | tr '\n' ' ' | sed 's/.$//'`
 r.mask phenology_2000-2016.100.maxmode_nowater maskcats="${list}" --o
 r.mapcalc "pheno_chunk7 = 'phenology_2000-2016.100.maxmode_nowater'"

 list=`awk 'BEGIN { FS="|"; } {print $8" "$1}' pheno100_univar.vect.out | sort -n | awk '{print $2}' | sed '1d' | sed -n '71,80p' | tr '\n' ' ' | sed 's/.$//'`
 r.mask phenology_2000-2016.100.maxmode_nowater maskcats="${list}" --o
 r.mapcalc "pheno_chunk8 = 'phenology_2000-2016.100.maxmode_nowater'"

 list=`awk 'BEGIN { FS="|"; } {print $8" "$1}' pheno100_univar.vect.out | sort -n | awk '{print $2}' | sed '1d' | sed -n '81,90p' | tr '\n' ' ' | sed 's/.$//'`
 r.mask phenology_2000-2016.100.maxmode_nowater maskcats="${list}" --o
 r.mapcalc "pheno_chunk9 = 'phenology_2000-2016.100.maxmode_nowater'"

 list=`awk 'BEGIN { FS="|"; } {print $8" "$1}' pheno100_univar.vect.out | sort -n | awk '{print $2}' | sed '1d' | sed -n '91,100p' | tr '\n' ' ' | sed 's/.$//'`
 r.mask phenology_2000-2016.100.maxmode_nowater maskcats="${list}" --o
 r.mapcalc "pheno_chunk10 = 'phenology_2000-2016.100.maxmode_nowater'"

fi

if [ $EXPORT_PHENO_CHUNKS -eq 1 ]
then
 r.mask -r
 g.region rast=2021.pheno.wholeyear.partialsum

 for((v=1; v<11; v++)) do
	r.out.gdal in=pheno_chunk$((v)) out=./export/pheno_chunk$((v)).tif type=Byte format=GTiff --o
 done
fi


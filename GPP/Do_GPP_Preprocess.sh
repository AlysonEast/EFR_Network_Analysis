#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

FIND_DATEWISE_MAX=1

year=2014

export year

./Aqua_Preprocess.sh

./Terra_Preprocess.sh

##############################################################
if [ $FIND_DATEWISE_MAX -eq 1 ]
then
g.region rast=MODIS_CalYear_AUC_2017
r.mask -r
 Rscript combine_keys.R ${year}
 sed -i 's/"//g' ./keys/date_key_${year}.txt
 n=`wc -l ./keys/date_key_${year}.txt | awk '{print $1}'`
 num=$((${n}-1))
 echo $num

 for((n=1; n<${num}; n++)) do
 date_format=`sed -n "$((n+1))"p ./keys/date_key_${year}.txt | awk 'BEGIN {FS="|";} {print $3}'`
 echo "${date_format} :"

 TEST=`g.mlist type=rast pattern="MODIS_*${year}_${date_format}" exclude="MODIS_max_*" | wc -l`
  if [ $TEST -eq 2 ]
  then 
   echo "taking max of ${date_format}"
   r.null map=MODIS_aqua_${year}_${date_format} null=-1
   r.null map=MODIS_terra_${year}_${date_format} null=-1
   r.mapcalc "'MODIS_max_${year}_${date_format}' = max('MODIS_terra_${year}_${date_format}', 'MODIS_aqua_${year}_${date_format}')"
   r.null map=MODIS_max_${year}_${date_format} setnull=-1
  fi

  if [ $TEST -lt 2 ]
  then 
  echo "Atleast one Terra or Aqua Missing"
  TEST_TERRA=`g.mlist type=rast pattern="MODIS_terra_${year}_${date_format}" | wc -l`
    if [ $TEST_TERRA -eq 1 ]
    then
    echo "using terra for ${date_format}"
    r.mapcalc "'MODIS_max_${year}_${date_format}' = 'MODIS_terra_${year}_${date_format}'"
    else
    echo "using aqua for ${date_format}"
    r.mapcalc "'MODIS_max_${year}_${date_format}' = 'MODIS_aqua_${year}_${date_format}'"
    fi
  fi
g.mremove rast=MODIS_terra_${year}_${date_format},MODIS_aqua_${year}_${date_format} -f
done
fi
####################################################################
if [ $num -ge 45 ]
then
r.mask -r
r.mapcalc "MODIS_CalYear_AUC_${year} = `g.mlist type=rast pattern="MODIS_max_${year}*" separator="+"`"
./doEOYauc.sh
fi

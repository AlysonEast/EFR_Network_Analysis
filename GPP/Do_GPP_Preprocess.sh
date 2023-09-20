#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

FIND_DATEWISE_MAX=1

year=2022

export year

./Terra_Preprocess.sh
./Aqua_Preprocess.sh

##############################################################
if [ $FIND_DATEWISE_MAX -eq 1 ]
then
 Rscript date_key.R ${year}
 sed -i 's/"//g' ./keys/date_key_${year}.txt
 n=`wc -l ./keys/date_key_${year}.txt | awk '{print $1}'`
 num=$((${n}-1))
 echo $num

 for((n=1; n<${num}; n++)) do
 date_format=`sed -n "$((n+1))"p ./keys/date_key_aqua_${year}.txt | awk 'BEGIN {FS="|";} {print $3}'`

test=`g.mlist type=rast pattern="MODIS_*${year}_${date_format}" | wc -l`

  if [ $test -eq 2 ]
  then 
   r.null map=MODIS_aqua_${year}_${date_format} null=-1
   r.null map=MODIS_terra_${year}_${date_format} null=-1
   r.mapcalc "'MODIS_max_${year}_${date_format}' = max('MODIS_terra_${year}_${date_format}', 'MODIS_aqua_${year}_${date_format}')"
   r.null map=MODIS_max_${year}_${date_format} setnull=-1
  else
   eval `g.findfile element=cell file=MODIS_terra_${year}_${date_format}`
   if [ -n $name]
   then
    r.mapcalc "'MODIS_max_${year}_${date_format}' = 'MODIS_terra_${year}_${date_format}'"
   else
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

#!/bin/bash

export GISRC=/home/1te/.grassrc6.data


year=2020
week=45

files=`g.mlist type=rast mapset=aly_east pattern="MODIS_max_${year}*" separator=" + "`

for ((n=1: n<46: n++)) do
 r.mask   maskcats=$(n)

applicable_files=`files | awk -v start=$((n)) 'BEGIN {FS=" + "} {for(i=start;i<=NF;i++) printf $i" + "; print ""}'`

r.mapcalc "MODIS_AUC_${year}_minint_$(n) = ${applicable_files}"
r.mask -r
r.null MODIS_AUC_${year}_minint_$(n) null=0

done

minint_steps=`g.mlist type=rast mapset=aly_east pattern="MODIS_max_${year}*" separator=" + "`

r.mapcalc "MODIS_AUC_${year} = ${minint_steps}"


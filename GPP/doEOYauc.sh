#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

week=45

r.mask -r

#make sure this still works after date changes 
g.mlist type=rast mapset=aly_east pattern="MODIS_max_${year}*" separator="newline" | sort --version-sort >temp

for((n=1; n<46; n++)) do
echo "processing week $((n))"
r.mask minint maskcats=$((n)) --o

 applicable_files=`awk -v start=$((n)) 'NR >= start && NR <=45' temp | tr "\n" "+" | rev | cut -c2- | rev`

r.mapcalc "MODIS_AUC_${year}_minint_$((n)) = ${applicable_files}"
r.mask -r
r.null MODIS_AUC_${year}_minint_$((n)) null=0
done

minint_steps=`g.mlist type=rast mapset=aly_east pattern="MODIS_AUC_${year}_minint*" separator="+"`

r.mapcalc "MODIS_EOY_AUC_${year} = ${minint_steps}"
r.null map=MODIS_EOY_AUC_${year} setnull=0

g.mremove rast=`g.mlist type=rast mapset=aly_east pattern="MODIS_AUC_${year}_minint*" separator=","` -f

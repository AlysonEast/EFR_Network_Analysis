#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

currYEAR=2023
currint=5

year1ago=$((${currYEAR}-1))
year2ago=$((${currYEAR}-2))
year3ago=$((${currYEAR}-3))
year4ago=$((${currYEAR}-4))
year5ago=$((${currYEAR}-5))
nextint=$((${currint}+1))

echo ${year1ago}

#if currint=45 run doEOYauc.sh, else, do below 

r.mask -r

g.mlist type=rast mapset=aly_east pattern="MODIS_max_${curYEAR}*" separator="newline" | sort --version-sort >temp
year_to_date=`awk -v end=${currint} 'NR >= 1 && NR <= end' temp | tr "\n" "+" | rev | cut -c2- | rev`

#minint < currint
r.mask minint maskcats="1 thru ${currint}" --o
r.mapcalc "MODIS_1yr_AUC_wk${currint}_${currYEAR}_step1 = ${year_to_date}"
r.null MODIS_1yr_AUC_wk${currint}_${currYEAR}_step1 null=0

r.mapcalc "MODIS_3yr_AUC_wk${currint}_${currYEAR}_step1 = ${year_to_date} + MODIS_CalYear_AUC_${year1ago} + MODIS_EOY_AUC_${year2ago}"
r.null MODIS_3yr_AUC_wk${currint}_${currYEAR}_step1 null=0

r.mapcalc "MODIS_5yr_AUC_wk${currint}_${currYEAR}_step1 = ${year_to_date} + MODIS_CalYear_AUC_${year1ago} + MODIS_CalYear_AUC_${year2ago} + MODIS_CalYear_AUC_${year3ago} + MODIS_EOY_AUC_${year4ago}"
r.null MODIS_5yr_AUC_wk${currint}_${currYEAR}_step1 null=0

#minint > currint
r.mask minint maskcats="${nextint} thru 45" --o
r.mapcalc "MODIS_1yr_AUC_wk${currint}_${currYEAR}_step2 = ${year_to_date} + MODIS_EOY_AUC_${year1ago}"
r.null MODIS_1yr_AUC_wk${currint}_${currYEAR}_step2 null=0

r.mapcalc "MODIS_3yr_AUC_wk${currint}_${currYEAR}_step2 = ${year_to_date} + MODIS_CalYear_AUC_${year1ago} + MODIS_CalYear_AUC_${year2ago} + MODIS_EOY_AUC_${year3ago}"
r.null MODIS_3yr_AUC_wk${currint}_${currYEAR}_step2 null=0

r.mapcalc "MODIS_5yr_AUC_wk${currint}_${currYEAR}_step2 = ${year_to_date} + MODIS_CalYear_AUC_${year1ago} + MODIS_CalYear_AUC_${year2ago} + MODIS_CalYear_AUC_${year3ago} +  MODIS_CalYear_AUC_${year4ago} + MODIS_EOY_AUC_${year5ago}"
r.null MODIS_5yr_AUC_wk${currint}_${currYEAR}_step2 null=0

#Put it all together
r.mask -r
r.mapcalc "MODIS_1yr_AUC_wk${currint}_${currYEAR} = MODIS_1yr_AUC_wk${currint}_${currYEAR}_step1 + MODIS_1yr_AUC_wk${currint}_${currYEAR}_step2"
r.mapcalc "MODIS_3yr_AUC_wk${currint}_${currYEAR} = MODIS_3yr_AUC_wk${currint}_${currYEAR}_step1 + MODIS_3yr_AUC_wk${currint}_${currYEAR}_step2"
r.mapcalc "MODIS_5yr_AUC_wk${currint}_${currYEAR} = MODIS_5yr_AUC_wk${currint}_${currYEAR}_step1 + MODIS_5yr_AUC_wk${currint}_${currYEAR}_step2"

r.null map=MODIS_1yr_AUC_wk${currint}_${currYEAR} setnull=0
r.null map=MODIS_3yr_AUC_wk${currint}_${currYEAR} setnull=0
r.null map=MODIS_5yr_AUC_wk${currint}_${currYEAR} setnull=0

g.mremove rast=MODIS_1yr_AUC_wk${currint}_${currYEAR}_step1,MODIS_1yr_AUC_wk${currint}_${currYEAR}_step2 -f
g.mremove rast=MODIS_3yr_AUC_wk${currint}_${currYEAR}_step1,MODIS_3yr_AUC_wk${currint}_${currYEAR}_step2 -f
g.mremove rast=MODIS_5yr_AUC_wk${currint}_${currYEAR}_step1,MODIS_5yr_AUC_wk${currint}_${currYEAR}_step2 -f

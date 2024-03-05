#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

currYEAR=2019
#currint=5
currdate=`sed -n "$((${currint}+1))"p ./keys/date_key_${currYEAR}.txt | awk 'BEGIN {FS="|";} {print $3}'`
echo "year: $currYEAR"
echo "currint: $currint"
echo "current date is $currdate"


year1ago=$((${currYEAR}-1))
year2ago=$((${currYEAR}-2))
year3ago=$((${currYEAR}-3))
year4ago=$((${currYEAR}-4))
year5ago=$((${currYEAR}-5))
year6ago=$((${currYEAR}-6))

nextint=$((${currint}+1))

#if currint=45 run doEOYauc.sh, else, do below 

g.region rast=MODIS_CalYear_AUC_2017
g.region n=50:58N s=23:34N w=130:30W e=63:26W
g.region -p 
r.mask -r

rm temp
g.mremove rast=year_to_date -f
g.mlist type=rast mapset=aly_east pattern="MODIS_max_${currYEAR}*" separator="newline" | sort --version-sort>temp
year_to_date=`awk -v end=${currint} 'NR >= 1 && NR <= end' temp | tr "\n" "+" | rev | cut -c2- | rev`
echo "year to date is $year_to_date"
r.mapcalc "year_to_date =  ${year_to_date}"

#minint < currint

for((n=1; n<${nextint}; n++)) do
echo "processing week $((n))"
 r.mask minint maskcats=$((n)) --o

 applicable_files=`awk -v start=$((n)) -v end=${currint} 'NR >= start && NR <=end' temp | tr "\n" "+" | rev | cut -c2- | rev`
 echo "adding $applicable_files"
 r.mapcalc "MODIS_AUC_${currYEAR}_minint_$((n)) = ${applicable_files}"
 r.mask -r
 r.null MODIS_AUC_${currYEAR}_minint_$((n)) null=0
done
minint_steps=`g.mlist type=rast mapset=aly_east pattern="MODIS_AUC_${currYEAR}_minint*" separator="+"`
echo "minint steps are $minint_steps"

 r.mask minint maskcats="1 thru ${currint}" --o

echo "Calculating 0yr for 1 thru ${currint} cells"
r.mapcalc "MODIS_0yr_AUC_wk${currint}_${currYEAR}_step1 = ${minint_steps}"
g.mremove rast=`g.mlist type=rast mapset=aly_east pattern="MODIS_AUC_${currYEAR}_minint*" separator=","` -f

echo "Calculating 1yr for 1 thru ${currint} cells"
r.mapcalc "MODIS_1yr_AUC_wk${currint}_${currYEAR}_step1 = year_to_date + MODIS_EOY_AUC_${year1ago}"
echo "Calculating 2yr for 1 thru ${currint} cells"
r.mapcalc "MODIS_2yr_AUC_wk${currint}_${currYEAR}_step1 = year_to_date + MODIS_CalYear_AUC_${year1ago} + MODIS_EOY_AUC_${year2ago}"
echo "Calculating 3yr for 1 thru ${currint} cells"
r.mapcalc "MODIS_3yr_AUC_wk${currint}_${currYEAR}_step1 = year_to_date + MODIS_CalYear_AUC_${year1ago} + MODIS_CalYear_AUC_${year2ago} + MODIS_EOY_AUC_${year3ago}"
echo "Calculating 4yr for 1 thru ${currint} cells"
r.mapcalc "MODIS_4yr_AUC_wk${currint}_${currYEAR}_step1 = year_to_date + MODIS_CalYear_AUC_${year1ago} + MODIS_CalYear_AUC_${year2ago} + MODIS_CalYear_AUC_${year3ago} + MODIS_EOY_AUC_${year4ago}"
echo "Calculating 5yr for 1 thru ${currint} cells"
r.mapcalc "MODIS_5yr_AUC_wk${currint}_${currYEAR}_step1 = year_to_date + MODIS_CalYear_AUC_${year1ago} + MODIS_CalYear_AUC_${year2ago} + MODIS_CalYear_AUC_${year3ago} + MODIS_CalYear_AUC_${year4ago} + MODIS_EOY_AUC_${year5ago}"

 r.mask minint maskcats="${nextint} thru 45" --o

echo "Calculating 0yr for ${nextint} thru 45 cells"
r.mapcalc "MODIS_0yr_AUC_wk${currint}_${currYEAR}_step2 = year_to_date + MODIS_EOY_AUC_${year1ago}"
echo "Calculating 1yr for ${nextint} thru 45 cells"
r.mapcalc "MODIS_1yr_AUC_wk${currint}_${currYEAR}_step2 = year_to_date + MODIS_CalYear_AUC_${year1ago} + MODIS_EOY_AUC_${year2ago}"
echo "Calculating 2yr for ${nextint} thru 45 cells"
r.mapcalc "MODIS_2yr_AUC_wk${currint}_${currYEAR}_step2 = year_to_date + MODIS_CalYear_AUC_${year1ago} + MODIS_CalYear_AUC_${year2ago} + MODIS_EOY_AUC_${year3ago}"
echo "Calculating 3yr for ${nextint} thru 45 cells"
r.mapcalc "MODIS_3yr_AUC_wk${currint}_${currYEAR}_step2 = year_to_date + MODIS_CalYear_AUC_${year1ago} + MODIS_CalYear_AUC_${year2ago} + MODIS_CalYear_AUC_${year3ago} + MODIS_EOY_AUC_${year4ago}"
echo "Calculating 4yr for ${nextint} thru 45 cells"
r.mapcalc "MODIS_4yr_AUC_wk${currint}_${currYEAR}_step2 = year_to_date + MODIS_CalYear_AUC_${year1ago} + MODIS_CalYear_AUC_${year2ago} + MODIS_CalYear_AUC_${year3ago} +  MODIS_CalYear_AUC_${year4ago} + MODIS_EOY_AUC_${year5ago}"
echo "Calculating 5yr for ${nextint} thru 45 cells"
r.mapcalc "MODIS_5yr_AUC_wk${currint}_${currYEAR}_step2 = year_to_date + MODIS_CalYear_AUC_${year1ago} + MODIS_CalYear_AUC_${year2ago} + MODIS_CalYear_AUC_${year3ago} +  MODIS_CalYear_AUC_${year4ago} + MODIS_CalYear_AUC_${year5ago} + MODIS_EOY_AUC_${year6ago}"

 r.mask -r
r.null map=MODIS_0yr_AUC_wk${currint}_${currYEAR}_step1 null=0
r.null map=MODIS_1yr_AUC_wk${currint}_${currYEAR}_step1 null=0
r.null map=MODIS_2yr_AUC_wk${currint}_${currYEAR}_step1 null=0
r.null map=MODIS_3yr_AUC_wk${currint}_${currYEAR}_step1 null=0
r.null map=MODIS_4yr_AUC_wk${currint}_${currYEAR}_step1 null=0
r.null map=MODIS_5yr_AUC_wk${currint}_${currYEAR}_step1 null=0

r.null map=MODIS_0yr_AUC_wk${currint}_${currYEAR}_step2 null=0
r.null map=MODIS_1yr_AUC_wk${currint}_${currYEAR}_step2 null=0
r.null map=MODIS_2yr_AUC_wk${currint}_${currYEAR}_step2 null=0
r.null map=MODIS_3yr_AUC_wk${currint}_${currYEAR}_step2 null=0
r.null map=MODIS_4yr_AUC_wk${currint}_${currYEAR}_step2 null=0
r.null map=MODIS_5yr_AUC_wk${currint}_${currYEAR}_step2 null=0

#Put it all together
echo "Calculating 0yr AUC for ${currdate}"
r.mapcalc "MODIS_0yr_AUC_wk${currdate}_${currYEAR} = MODIS_0yr_AUC_wk${currint}_${currYEAR}_step1 + MODIS_0yr_AUC_wk${currint}_${currYEAR}_step2"
echo "Calculating 1yr AUC for ${currdate}"
r.mapcalc "MODIS_1yr_AUC_wk${currdate}_${currYEAR} = MODIS_1yr_AUC_wk${currint}_${currYEAR}_step1 + MODIS_1yr_AUC_wk${currint}_${currYEAR}_step2"
r.mapcalc "MODIS_1yr_AUC_wk${currdate}_${currYEAR} = MODIS_1yr_AUC_wk${currint}_${currYEAR}_step1 + MODIS_1yr_AUC_wk${currint}_${currYEAR}_step2"
echo "Calculating 2yr AUC for ${currdate}"
r.mapcalc "MODIS_2yr_AUC_wk${currdate}_${currYEAR} = MODIS_2yr_AUC_wk${currint}_${currYEAR}_step1 + MODIS_2yr_AUC_wk${currint}_${currYEAR}_step2"
echo "Calculating 3yr AUC for ${currdate}"
r.mapcalc "MODIS_3yr_AUC_wk${currdate}_${currYEAR} = MODIS_3yr_AUC_wk${currint}_${currYEAR}_step1 + MODIS_3yr_AUC_wk${currint}_${currYEAR}_step2"
echo "Calculating 4yr AUC for ${currdate}"
r.mapcalc "MODIS_4yr_AUC_wk${currdate}_${currYEAR} = MODIS_4yr_AUC_wk${currint}_${currYEAR}_step1 + MODIS_4yr_AUC_wk${currint}_${currYEAR}_step2"
echo "Calculating 5yr AUC for ${currdate}"
r.mapcalc "MODIS_5yr_AUC_wk${currdate}_${currYEAR} = MODIS_5yr_AUC_wk${currint}_${currYEAR}_step1 + MODIS_5yr_AUC_wk${currint}_${currYEAR}_step2"

g.mremove rast=MODIS_0yr_AUC_wk${currint}_${currYEAR}_step1,MODIS_0yr_AUC_wk${currint}_${currYEAR}_step2 -f
g.mremove rast=MODIS_1yr_AUC_wk${currint}_${currYEAR}_step1,MODIS_1yr_AUC_wk${currint}_${currYEAR}_step2 -f
g.mremove rast=MODIS_2yr_AUC_wk${currint}_${currYEAR}_step1,MODIS_2yr_AUC_wk${currint}_${currYEAR}_step2 -f
g.mremove rast=MODIS_3yr_AUC_wk${currint}_${currYEAR}_step1,MODIS_3yr_AUC_wk${currint}_${currYEAR}_step2 -f
g.mremove rast=MODIS_4yr_AUC_wk${currint}_${currYEAR}_step1,MODIS_4yr_AUC_wk${currint}_${currYEAR}_step2 -f
g.mremove rast=MODIS_5yr_AUC_wk${currint}_${currYEAR}_step1,MODIS_5yr_AUC_wk${currint}_${currYEAR}_step2 -f

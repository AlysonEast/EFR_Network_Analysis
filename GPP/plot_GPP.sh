#!/bin/bash                                                                     

export GISRC=/home/1te/.grassrc6.data

g.region rast=MODIS_CalYear_AUC_2017
g.region n=50:58N s=23:34N w=130:30W e=63:26W
r.mask -r

product=5yr

g.mlist type=rast mapset=aly_east pattern="MODIS_${product}_AUC_wk*" separator="newline">temp

n=`g.mlist type=rast mapset=aly_east pattern="MODIS_${product}_AUC_wk*" | wc -l | awk '{print $1}'`
n=$((${n}+1))

d.mon x2
for((v=0; v<${n}; v++)) do
variable_rast=`cat temp | sed -n "$((v))p"`
echo ${variable_rast}
r.colors map=${variable_rast} rules=col_rules
d.rast ${variable_rast} 
d.legend -s ${variable_rast} at=10,13,15,85 labelnum=3
d.title -ds map=${variable_rast} size=3
d.out.file output=./maps/${product}/${variable_rast} format=png --o
d.erase -f
done

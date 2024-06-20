#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

year=2016

g.region n=1492881 s=1367371 w=1041349 e=1210451 -p
r.mask -r

for myfolder in `ls ../../Shapefiles/MTBS/wnc/mtbs/${year}/`
do
        echo ${myfolder}
        for myfile in `ls ../../Shapefiles/MTBS/wnc/mtbs/${year}/${myfolder}/*dnbr6.tif | awk 'BEGIN {FS="/"} {print $9}'`
        do
                echo ${myfile}
                #read files into grass
                r.in.gdal input=../../Shapefiles/MTBS/wnc/mtbs/${year}/${myfolder}/${myfile} output=${year}_${myfile} --o
                r.null map=${year}_${myfile} setnull=0 -i
        done
done


for myfolder in `ls ../../Shapefiles/MTBS/wnc/mtbs/${year}/`
do
        echo ${myfolder}
        for myfile in `ls ../../Shapefiles/MTBS/wnc/mtbs/${year}/${myfolder}/*dnbr.tif | awk 'BEGIN {FS="/"} {print $9}'`
        do
                echo ${myfile}
                #read files into grass
                g.list type=rast pattern=${year}_${myfolder}*dnbr6.tif
                r.mask raster=`g.list type=rast pattern=${year}_${myfolder}*dnbr6.tif` --o
                r.in.gdal input=../../Shapefiles/MTBS/wnc/mtbs/${year}/${myfolder}/${myfile} output=${year}_${myfile} --o
        done
done

r.mask -r

r.patch -z input=`g.list type=rast pattern="${year}*dnbr.tif" exclude="*rdnbr.tif" separator=","` output=MTBS_${year}_dnbr --o
r.patch input=`g.list type=rast pattern="${year}*dnbr6.tif" separator=","` output=MTBS_${year}_dnbr6 --o
r.patch input=`g.list type=rast pattern="${year}*rdnbr.tif" separator=","` output=MTBS_${year}_rdnbr --o

r.out.gdal input=MTBS_${year}_dnbr output=../../Shapefiles/MTBS/wnc/mtbs/MTBS_${year}_dnbr.tif --o
r.out.gdal input=MTBS_${year}_dnbr6 output=../../Shapefiles/MTBS/wnc/mtbs/MTBS_${year}_dnbr6.tif --o
r.out.gdal input=MTBS_${year}_rdnbr output=../../Shapefiles/MTBS/wnc/mtbs/MTBS_${year}_rdnbr.tif --o

g.remove type=rast name=`g.list type=rast pattern="${year}*nbr*.tif" separator=","` -f


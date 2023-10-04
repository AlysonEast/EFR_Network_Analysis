#!/bin/bash

export GISRC=/home/1te/.grassrc6.data


g.region n=59:03:45N e=57:22:45W s=11:15N w=137:15W res=0:00:15
r.mask -r

d.mon x3
d.erase white

r.stats -cn input=MODIS_CalYear_AUC_2021,2021.S3.wholeyear.partialsum >compare_tmp

cp cont2.wrk script.wrk
gnuplot < script.wrk &
wait


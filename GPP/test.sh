#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

eval `g.findfile element=cell file=MODIS_aqua_2022_2022.04.07`
echo $name

if [ -z ${name} ]; then echo "Missing"; fi


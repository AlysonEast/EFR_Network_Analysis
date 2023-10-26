#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

INDIVIDUAL_PRODUCT=1
ALL_PRODUCTS_FOR_DATE=0

#############################################################
if [ $INDIVIDUAL_PRODUCT -eq 1 ]
then

product=5yr

list=`ls /home/hnw/S3/prod/ -1 | grep auc${product}departure.LAEA | tr '\n' ' '`

cd /home/hnw/S3/prod/
zip /mnt/poseidon/remotesensing/1te/FW3/${product}download.zip ${list}

fi
################################################################
if [ $ALL_PRODUCTS_FOR_DATE -eq 1 ]
then

week=09-14

list=`ls /home/hnw/S3/prod/ -1 | grep auc | grep departure.LAEA | grep ${week} | tr '\n' ' '`

cd /home/hnw/S3/prod/
zip /mnt/poseidon/remotesensing/1te/FW3/FW${week}download.zip ${list}

fi

#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

INDIVIDUAL_PRODUCT=0
ALL_PRODUCTS_FOR_DATE=0
FROM_TMP=1

#############################################################
if [ $INDIVIDUAL_PRODUCT -eq 1 ]
then

product=1yr

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
################################################################
if [ $FROM_TMP -eq 1 ]
then


list=`ls /mnt/poseidon/remotesensing/forwarn/net_ecological_impact/hnw_notprod/ -1 | grep auc | tr '\n' ' '`

cd /mnt/poseidon/remotesensing/forwarn/net_ecological_impact/hnw_notprod
zip -m /mnt/poseidon/remotesensing/1te/FW3/FW_wnc_download.zip ${list}

fi

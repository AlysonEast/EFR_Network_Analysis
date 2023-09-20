#!/bin/bash

export GISRC=/home/1te/.grassrc6.data

year=2020
export year

./Do_GPP_Preprocess.sh

year=2021
export year

./Do_GPP_Preprocess.sh

year=2022
export year

./Do_GPP_Preprocess.sh

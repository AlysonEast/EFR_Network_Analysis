#!/bin/bash  

for((v=1; v<46; v++)) do
currint=$((v))
export currint
./doAUC.sh
done

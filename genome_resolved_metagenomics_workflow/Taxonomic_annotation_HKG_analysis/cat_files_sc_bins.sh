#!/bin/bash

for file in `ls -d  *_BIN_REFINEMENT`
do
#seqkit rmdup -s -i UHGG_modH.fna -o UHGG_modH_uniq.fna -d UHGG.duplicated.fna -D UHGG.duplicated.detail.txt
sample=${file%%_BIN_REFINEMENT}
cat ${sample}_bin.*_uniq.txt >${sample}_bin_all_uniq.txt

done

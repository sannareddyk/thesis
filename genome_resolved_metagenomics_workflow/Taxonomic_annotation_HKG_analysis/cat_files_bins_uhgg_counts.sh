#!/bin/bash

for file in *_bins_counts_HKGtype_tax.txt
do
#seqkit rmdup -s -i UHGG_modH.fna -o UHGG_modH_uniq.fna -d UHGG.duplicated.fna -D UHGG.duplicated.detail.txt
sample=${file%%_bins_counts_HKGtype_tax.txt}

cp ${sample}_bins_counts_HKGtype_tax.txt ${sample}_bins_UHGG_counts.txt
tail -n +2 ${sample}_UHGG_counts_HKGtype_tax.txt >>${sample}_bins_UHGG_counts.txt

done

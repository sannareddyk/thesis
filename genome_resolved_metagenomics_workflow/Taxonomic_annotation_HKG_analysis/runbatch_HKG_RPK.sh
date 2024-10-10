#!/bin/bash

for file in *bins_UHGG_counts.txt
do

sample=${file%%_bins_UHGG_counts.txt}

python3 HKG_RPK.py ${sample}_bins_UHGG_counts.txt ${sample}_bins_UHGG_RPK.txt

done

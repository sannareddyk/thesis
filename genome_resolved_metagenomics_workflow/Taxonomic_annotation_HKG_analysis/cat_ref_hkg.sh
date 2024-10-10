#!/bin/bash

for file in `ls *trimmed_1.fastq`
do
sample=${file%%_trimmed_1.fastq}

cat ${sample}*protein.fna >${sample}_all.fna
cat ${sample}*protein.fna >${sample}_all.fna

awk '/^>/ {$0=$1} 1' ${sample}_all.fna >${sample}_modH.fna
awk '/^>/ {$0=$1} 1' ${sample}_all.fna >${sample}_modH.fna

cat ${sample}_modH.fna UHGG_uniq_SC_HKG.fna >${sample}_modH_UHGG_HKG_uniq.fna
cat ${sample}_modH.fna UHGG_uniq_SC_HKG.fna >${sample}_modH_UHGG_HKG_uniq.fna

done

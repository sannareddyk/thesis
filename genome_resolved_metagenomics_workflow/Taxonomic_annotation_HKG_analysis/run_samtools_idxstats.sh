#!/bin/bash

for file in `ls *besthit.filtered.s.bam`
do
echo $file
sample=${file%%.besthit.filtered.s.bam}
samtools idxstats $file >${sample}_abundances.txt
done

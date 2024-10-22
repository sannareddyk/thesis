#!/bin/bash

for file in *.besthit.filtered.s.bam
do
sample=${file%%.besthit.filtered.s.bam}

#tail -n +2 ${sample}.binned.merge_out.txt >${sample}.merge_out.txt
#tail -n +3 ${sample}.umub.merge_out.txt >>${sample}.merge_out.txt
awk -v FS='\t' -v OFS='\t' '$8>0' ${sample}_nbh.featureCounts.out.txt >${sample}_nbh.featureCounts.proc.out.txt

tail -n +2 ${sample}_contigs.featureCounts.out.txt >${sample}.fc_out.txt
tail -n +3 ${sample}_nbh.featureCounts.proc.out.txt >>${sample}.fc_out.txt

done

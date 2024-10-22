#!/bin/bash

##script in python to parse featureCounts output and get normalized counts (RPK), calculate TPM
for file in *_nbh.s.bam
do

sample=${file%%_nbh.s.bam}
python3 fc_parse.py ${sample}.fc_out.txt ${sample}.featureCounts.norm.txt
python3 fc_TPM.py ${sample}.featureCounts.norm.txt ${sample}.featureCounts.TPM.txt

done 

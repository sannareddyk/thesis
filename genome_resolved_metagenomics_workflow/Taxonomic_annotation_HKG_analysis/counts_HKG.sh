#!/bin/bash

for file in *abundances.txt
do
sample=${file%%_abundances.txt}
echo $sample

grep '^G' ${sample}_abundances.txt | cut -f1,2,3 >${sample}_bins_counts.txt
grep '^MG' ${sample}_abundances.txt | cut -f1,2,3 >${sample}_UHGG_counts_HKG.txt
grep -wFf ${sample}_bins_HKG.txt ${sample}_bins_counts.txt >${sample}_bins_counts_HKG.txt

done

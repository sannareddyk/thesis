#!/bin/bash

for file in *bins_counts.txt
do

sample=${file%%_bins_counts.txt}

python3 merge_bins_hkg_tax.py ${sample}_bin_all_uniq.txt ${sample}_bin_tax_final.txt ${sample}_bins_HKGtype_tax.txt

#run only once
python3 merge_uhgg_hkg_tax.py UHGG_HKG_SC_final.txt UHGG_tax_final.txt UHGG_HKGtype_tax.txt

python3 merge_counts_bins_hkg_tax.py ${sample}_bins_counts_HKG.txt ${sample}_bins_HKGtype_tax.txt ${sample}_bins_counts_HKGtype_tax.txt
python3 merge_counts_uhgg_hkg_tax.py ${sample}_UHGG_counts_HKG.txt UHGG_HKGtype_tax.txt ${sample}_UHGG_counts_HKGtype_tax.txt

done

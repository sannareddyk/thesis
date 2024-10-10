#!/bin/bash

#Keerthi Sannareddy, June 2023

for f in G0*_bin.*_*tophit.tsv; do

	##get HKG from tophit files for each bin per sample
	##get sample+bin name
	sbin=$(echo $f | cut -d_ -f1-2)
	echo $sbin
	
	bin=$(echo $f | cut -d_ -f2)

	echo $bin	

	if [ -f "${sbin}_HKG.txt" ]; then

		awk -F'\t' -v var=$bin 'FNR>1{split($2,a,","); print $1,"\t",a[1],"\t",var}' $f >>${sbin}_HKG.txt

	else
	
		awk -F'\t' -v var=$bin 'FNR>1{split($2,a,","); print $1,"\t",a[1],"\t",var}' $f >${sbin}_HKG.txt
	fi
done

sleep 10


conda activate seqtk

for f in *bin*HKG.txt;do
	
	sbin=$(echo $f | cut -d_ -f1-2)
	cut -f1 $f | sort | uniq | seqtk subseq ${sbin}_protein.fna - >${sbin}_HKG.fna
	
	##modify headers of HKGs
        awk '/^>/ {$0=$1} 1' ${sbin}_HKG.fna >${sbin}_HKG_modH.fna

	##remove below line from code
	#cut -f1 $f | sort | uniq | grep -f - $f >${sbin}_uniq.txt
	sort -u -k1,1 $f >${sbin}_uniq.txt 

done

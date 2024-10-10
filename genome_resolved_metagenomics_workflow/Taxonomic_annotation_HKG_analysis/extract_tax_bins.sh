#!/bin/bash

#Keerthi Sannareddy,Sep 2023
set -e           
OldDir=$(pwd)
for d in *_BIN_REFINEMENT/Annotation/
do                   # below you get sample name from path
sample=$(echo $d | cut -d/ -f1 | cut -d_ -f1)
echo "# sample $sample"
cd "$d"
  for fn in *.summary.tsv
    do    
       echo $fn
       cp "$fn" "${sample}_$fn" # add a prefix on file
       cut -f1,2 ${sample}_*.summary.tsv | tail -n +2 >>${sample}_tax_final.txt
    done
    cp ${sample}_tax_final.txt $OldDir
cd "$OldDir"
done

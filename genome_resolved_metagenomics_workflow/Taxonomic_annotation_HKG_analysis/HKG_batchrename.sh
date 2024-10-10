#!/bin/bash

#Keerthi Sannareddy, June 2023
set -e               
OldDir=$(pwd)         
for d in *_BIN_REFINEMENT/marker_genes/identify/intermediate_results/marker_genes/
do                   # below you get sample name from path
sample=$(echo $d | cut -d/ -f1 | cut -d_ -f1)
echo "# sample $sample"
cd "$d"             
  for d2 in bin* 
  do 
   cd "$d2"          
    for fn in * 
    do
       mv -i "$fn" "${sample}_$fn" # Only adding a prefix on file
    done
   cd -              
   mv -i "$d2" "${sample}_$d2"     # Only adding a prefix on dir
   cp ${sample}_$d2/*tophit.tsv ${sample}_$d2/*protein.fna $OldDir
  done
cd "$OldDir"        
done
exit 0               # All good...

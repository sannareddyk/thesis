#!/bin/bash

#Keerthi Sannareddy, Nov 2022

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 20G

# set run on bigmem node only
#SBATCH --cpus-per-task 8

# set max wallclock time
#SBATCH --time=48:00:00

# set name of job
#SBATCH --job-name=runFuncAnnotParse

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

# Activate env on cluster node
#. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh

FILES=($(ls ./*.faa))
file=${FILES[$SLURM_ARRAY_TASK_ID]}

sample=${file%%.faa}

##########kofam##########
#awk -F'\t' '$2!=""' | cut -f1 ${sample}.kofam.txt | uniq -c | sort -nr | less
awk -F'\t' '$2!=""' ${sample}.kofam.txt >${sample}.kofam.filtered.txt
echo -e "geneID\tKOfamID" | cat - ${sample}.kofam.filtered.txt >${sample}.kofam.final.txt

#########Interproscan, pfam############
##pfam filtering
grep 'Pfam' ${sample}.tsv | cut -f1,5,9,14 >${sample}.pfam.filtered.txt

##pfam parse
#script in pandas to groupby pfamID and take the entry with lowest evalue
python3 pfam_groupby.py ${sample}.pfam.filtered.txt ${sample}.pfam.filtered.eval.txt

cut -f1,2 ${sample}.pfam.filtered.eval.txt >${sample}.pfam.final.txt

##GO#############
#script in python to get list of all GO entries for each PfamID
#work with ${sample}.pfam.filtered.txt file for GO annotation
cut -f1,4 ${sample}.pfam.filtered.txt | awk -F$'\t' '{split($2,arr,"|"); for(e in arr) print($1 "\t" arr[e])}' | awk  '$2!="-"' | sort -u -k1,1 -k2,2 | awk  '$2!=""' >${sample}.GO.txt
echo -e "geneID\tGOID" | cat - ${sample}.GO.txt >${sample}.GO.final.txt
#########################

########uniref###########
##uniref filtering
cut -f1,2,9 ${sample}.blastp.txt | awk '$9<0.00001 {print}' | cut -f1,2 >${sample}.blastp.filtered.txt
echo -e "geneID\tUniRefID" | cat - ${sample}.blastp.filtered.txt >${sample}.blastp.final.txt
#########################

######dbCAN4###############
python3 dbCAN4_parse.py ${sample}.dbCAN4.txt ${sample}.dbCAN4.final.txt


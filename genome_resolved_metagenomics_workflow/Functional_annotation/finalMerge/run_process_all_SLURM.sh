#!/bin/bash

#Keerthi Sannareddy, Aug 2023

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 10G

# set run on bigmem node only
#SBATCH --cpus-per-task 1

# set max wallclock time
#SBATCH --time=10:00:00

# set name of job
#SBATCH --job-name=runProcess

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

FILES=($(ls *.merge_out.txt))
file=${FILES[$SLURM_ARRAY_TASK_ID]}

sample=${file%%.merge_out.txt}

(head -n 1 ${sample}.KO_counts.txt && tail -n +2 ${sample}.KO_counts.txt | sort | uniq) > ${sample}.KO_counts.uniq.txt
cut -f2,3 ${sample}.KO_counts.uniq.txt >${sample}.KO_counts.final.txt

(head -n 1 ${sample}.PF_counts.txt && tail -n +2 ${sample}.PF_counts.txt | sort | uniq) > ${sample}.PF_counts.uniq.txt
cut -f2,3 ${sample}.PF_counts.uniq.txt >${sample}.PF_counts.final.txt

(head -n 1 ${sample}.GO_counts.txt && tail -n +2 ${sample}.GO_counts.txt | sort | uniq) > ${sample}.GO_counts.uniq.txt
cut -f2,3 ${sample}.GO_counts.uniq.txt >${sample}.GO_counts.final.txt

(head -n 1 ${sample}.Uniref_counts.txt && tail -n +2 ${sample}.Uniref_counts.txt | sort | uniq) > ${sample}.Uniref_counts.uniq.txt
cut -f2,3 ${sample}.Uniref_counts.uniq.txt >${sample}.Uniref_counts.final.txt

(head -n 1 ${sample}.CAZy_counts.txt && tail -n +2 ${sample}.CAZy_counts.txt | sort | uniq) > ${sample}.CAZy_counts.uniq.txt
cut -f2,3 ${sample}.CAZy_counts.uniq.txt >${sample}.CAZy_counts.final.txt


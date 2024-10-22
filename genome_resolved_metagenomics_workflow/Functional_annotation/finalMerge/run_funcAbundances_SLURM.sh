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
#SBATCH --job-name=runfuncAbundances

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate pandas

FILES=($(ls *.merge_out.txt))
file=${FILES[$SLURM_ARRAY_TASK_ID]}

sample=${file%%.merge_out.txt}

python3 run_funcAbundances.py ${sample}.merge_out.txt ${sample}.KO_counts.txt ${sample}.PF_counts.txt ${sample}.GO_counts.txt ${sample}.Uniref_counts.txt ${sample}.CAZy_counts.txt

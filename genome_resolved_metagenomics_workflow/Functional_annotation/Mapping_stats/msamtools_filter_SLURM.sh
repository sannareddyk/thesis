#!/bin/bash

#Keerthi Sannareddy, Aug 2023

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 20G

# set run on bigmem node only
#SBATCH --cpus-per-task 8

# set max wallclock time
#SBATCH --time=24:00:00

# set name of job
#SBATCH --job-name=msamtools

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate msamtools

FILES=($(ls ./*.s.n.bam))
file=${FILES[$SLURM_ARRAY_TASK_ID]}

#NAME=`echo $file | cut -d"_" -f1-2`

sample=${file%%.s.n.bam}

msamtools filter -b -l 50 -p 95 -z 80 --besthit ${sample}.s.n.bam >${sample}.besthit.filtered.bam
msamtools filter -b -l 50 -p 95 -z 80 -v --keep_unmapped ${sample}.s.n.bam >${sample}.nobesthit.filtered.bam


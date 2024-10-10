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
#SBATCH --job-name=runInterProScan

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

# Activate env on cluster node
. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate interproscan

FILES=($(ls ./*.faa))
file=${FILES[$SLURM_ARRAY_TASK_ID]}

#NAME=`echo $file | cut -d"_" -f1`

infile=$file
outfile=${infile%%.faa}

#/mnt/mibi_ngs/keerthi/my_interproscan/interproscan-5.59-91.0/interproscan.sh -i $infile --cpu 8 -appl Pfam,TIGRFAM -goterms -pa -b $outfile
interproscan.sh -i $infile --cpu 8 -appl Pfam,TIGRFAM -goterms -pa -b $outfile

#!/bin/bash

#Keerthi Sannareddy

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 20G

# set run on bigmem node only
#SBATCH --cpus-per-task 8

# set max wallclock time
#SBATCH --time=48:00:00

# set name of job
#SBATCH --job-name=kofamscan

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

# Activate env on cluster node
. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate kofamscan

FILES=($(ls *.faa))
infile=${FILES[$SLURM_ARRAY_TASK_ID]}
outfile=${infile%%.faa}

/mnt/mibi_ngs/keerthi/kofam_scan-1.3.0/exec_annotation -p /mnt/mibi_ngs/databases/kofamscan/profiles -k /mnt/mibi_ngs/databases/kofamscan/ko_list -f mapper --cpu 8 --tmp-dir ${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}/tmp -o $outfile.kofam.txt $infile

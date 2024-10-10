#!/bin/bash

#Keerthi Sannareddy, Mar 2022

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 20G

# set run on bigmem node only
#SBATCH --cpus-per-task 8

# set max wallclock time
#SBATCH --time=10:00:00

# set name of job
#SBATCH --job-name=mW_QC

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannarek@mh-hannover.de

#SBATCH --array=0-1

# Activate env on cluster node
. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate metawrap-env

FILES=($(ls *_1.fastq))
fastq1=${FILES[$SLURM_ARRAY_TASK_ID]}
echo "My input file is ${fastq1}"
#fastq1=$(ls *_1.fastq | sed -n ${SLURM_ARRAY_TASK_ID}p)
fastq2=${fastq1%%_1.fastq}"_2.fastq"
echo $fastq2
outfile=${fastq1%%_1.fastq}
echo $outfile

#need in format x_1.fastq.gz & x_2.fastq.gz 
#mv ${NAME}_R1_001_val_1.fq.gz ${NAME}_val_1.fastq.gz
#mv ${NAME}_R2_001_val_2.fq.gz ${NAME}_val_2.fastq.gz

#metaWRAP read_qc --skip-pre-qc-report --skip-post-qc-report -1 ${NAME}_R1_001.fastq.gz -2 ${NAME}_R2_001.fastq.gz -t 8 -o ${NAME}_mWoutput 
#metaWRAP read_qc --skip-bmtagger -1 ${NAME}_R1_001.fastq.gz -2 ${NAME}_R2_001.fastq.gz -t 8 -o ${NAME}_mWoutput
metaWRAP read_qc -1 $fastq1 -2 $fastq2 -t 8 -o ${outfile}_mWoutput

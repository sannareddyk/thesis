#!/bin/bash

#Keerthi Sannareddy, Mar 2022

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 30G

# set run on bigmem node only
#SBATCH --cpus-per-task 24

# set max wallclock time
#SBATCH --time=8:00:00

# set name of job
#SBATCH --job-name=mW_assembly

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

# Activate env on cluster node
. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate metawrap-env

FILES=($(ls *_trimmed_1.fastq))
fastq1=${FILES[$SLURM_ARRAY_TASK_ID]}
echo "My input file is ${fastq1}"
#fastq1=$(ls *_1.fastq | sed -n ${SLURM_ARRAY_TASK_ID}p)
fastq2=${fastq1%%_trimmed_1.fastq}"_trimmed_2.fastq"
echo $fastq2

NAME=`echo $fastq1 | cut -d"_" -f1`

metaWRAP assembly --megahit -t 24 -m 30 -1 $fastq1 -2 $fastq2 -o ${NAME}_assemble 

##filter and rename contigs
seqkit seq -m 1000 ${NAME}_assemble/final_assembly.fasta >${NAME}_assemble/${NAME}_ass_filt.fasta
seqkit replace -p .+ -r ${NAME}_contig_{nr} ${NAME}_assemble/${NAME}_ass_filt.fasta >${NAME}_assembly.fasta

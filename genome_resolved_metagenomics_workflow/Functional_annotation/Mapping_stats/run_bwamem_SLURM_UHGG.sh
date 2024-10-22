#!/bin/bash

#Keerthi Sannareddy, Mar 2022

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 20G

# set run on bigmem node only
#SBATCH --cpus-per-task 4

# set max wallclock time
#SBATCH --time=24:00:00

# set name of job
#SBATCH --job-name=runbwa

#mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

# Activate env on cluster node
. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate bwa

FILES=($(ls *nbh_1.fq))

fastq1=${FILES[$SLURM_ARRAY_TASK_ID]}
#echo "My input file is ${fastq1}"

fastq2=${fastq1%%_nbh_1.fq}"_nbh_2.fq"
#echo $fastq2

outfile=${fastq1%%_1.fq}
#echo $outfile

#prefix for index
#NAME=`echo $fastq1 | cut -d"_" -f1-2`

#ref=${NAME}_contigs
ref=UHGG
threads=4

#index reference
#bwa index -a bwtsw -p ${NAME}_contigs ${NAME}_assembly.fasta

#run bwa mem
bwa mem -M -a -t $threads $ref $fastq1 $fastq2 >$outfile.sam
samtools view -bS $outfile.sam > $outfile.bam
samtools sort -@ 4 $outfile.bam -o $outfile.s.bam
samtools index $outfile.s.bam


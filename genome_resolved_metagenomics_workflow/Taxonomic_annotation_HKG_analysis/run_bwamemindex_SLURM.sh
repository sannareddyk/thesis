#!/bin/bash

#Keerthi Sannareddy, Mar 2022

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 20G

# set run on bigmem node only
#SBATCH --cpus-per-task 8

# set max wallclock time
#SBATCH --time=24:00:00

# set name of job
#SBATCH --job-name=runbwa

#mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-7

# Activate env on cluster node
. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate bwa

FILES=($(ls *_UHGG_HKG_uniq.fna))

file=${FILES[$SLURM_ARRAY_TASK_ID]}

#prefix for index
NAME=`echo $file | cut -d"_" -f1`

ref=${NAME}_ref
threads=8

#index reference
bwa index -a bwtsw -p ${NAME}_ref ${NAME}_modH_UHGG_HKG_uniq.fna

#run bwa mem
#bwa mem -a -t $threads $ref $fastq1 $fastq2 >$outfile.sam
#samtools view -bS $outfile.sam > $outfile.bam

#name sort bam file for msamtools filtering
#samtools sort -n -@ 4 $outfile.bam -o $outfile.s.n.bam

#samtools sort -@ 4 $outfile.besthit.filtered.bam -o $outfile.besthit.filtered.s.bam
#samtools index $outfile.besthit.filtered.s.bam


#!/bin/bash

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 48G

# set run on bigmem node only
#SBATCH --cpus-per-task 24

# set max wallclock time
#SBATCH --time=24:00:00

# set name of job
#SBATCH --job-name=extract_reads

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
#echo "My input file is ${fastq1}"

sample=${fastq1%%_trimmed_1.fastq}

#samtools view -b -f1 ${sample}.nobesthit.filtered.bam >${sample}.paired.nbh.bam
#samtools view -b -f1 -F12 ${sample}.nobesthit.filtered.bam >${sample}.paired.mapped.nbh.bam
#samtools view -b -f12 ${sample}.nobesthit.filtered.bam >${sample}.paired.unmapped.nbh.bam

#samtools fastq -1 ${sample}_mnbh_1.fq -2 ${sample}_mnbh_2.fq ${sample}.paired.mapped.nbh.bam
#samtools fastq -1 ${sample}_umnbh_1.fq -2 ${sample}_umnbh_2.fq ${sample}.paired.unmapped.nbh.bam

samtools fastq -1 ${sample}_nbh_1.fq -2 ${sample}_nbh_2.fq -s ${sample}_SE.fq ${sample}.nobesthit.filtered.bam
#bedtools bamtofastq -i ${sample}.nobesthit.filtered.bam -fq ${sample}.end1.fq -fq2 ${sample}.end2.fq

#samtools fastq -1 ${sample}_bh_1.fq -2 ${sample}_bh_2.fq -s ${sample}_bh_SE.fq ${sample}.besthit.filtered.bam

#cat ${sample}_mnbh_1.fq  ${sample}_umnbh_1.fq >${sample}_bnbh_1.fq
#cat ${sample}_mnbh_2.fq  ${sample}_umnbh_2.fq >${sample}_bnbh_2.fq

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

##get unmapped reads, read and mate unmapped
#samtools view -b -f12 $file >$sample.both.unmapped.bam
#samtools view -b -f4 ${sample}.s.bam >${sample}.unmapped.bam
#samtools fastq -1 ${sample}_um_1.fq -2 ${sample}_um_2.fq $sample.both.unmapped.bam

grep '>' ../${sample}_BIN_REFINEMENT/metawrap_80_10_bins/bin*.fa | cut -d'>' -f2 | sort -V >${sample}_binned_contigs.txt
grep '>' ../${sample}_assembly.fasta | cut -d'>' -f2 | sort -V >${sample}_all_contigs.txt
grep -w -v -f ${sample}_binned_contigs.txt ${sample}_all_contigs.txt >${sample}_unbinned_contigs.txt

##get reads mapping to binned and unbinned contigs
samtools view -H $sample.besthit.filtered.s.bam >$sample.header.txt

while read line; do samtools view $sample.besthit.filtered.s.bam $line >>${sample}_unbinned.sam ; done <${sample}_unbinned_contigs.txt
cat $sample.header.txt ${sample}_unbinned.sam >${sample}_unbinned_H.sam

while read line; do samtools view $sample.besthit.filtered.s.bam $line >>${sample}_binned.sam ; done <${sample}_binned_contigs.txt
cat $sample.header.txt ${sample}_binned.sam >${sample}_binned_H.sam

##properly paired,f2
#samtools view -Sb -f2 ${sample}_binned_H.sam >${sample}_binned_H.bam
samtools view -Sb ${sample}_binned_H.sam >${sample}_binned_H.bam

#samtools view -Sb -f2 ${sample}_unbinned_H.sam >${sample}_unbinned_H.bam
samtools view -Sb ${sample}_unbinned_H.sam >${sample}_unbinned_H.bam

#bbmap repair.sh and then align
#repair.sh in=${sample}_umub_1.fq in2=${sample}_umub_2.fq out1=${sample}_umubr_1.fq out2=${sample}_umubr_2.fq outs=${sample}.singletons.fq overwrite=true



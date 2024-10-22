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
#SBATCH --job-name=runFeatureCounts

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1
FILES=($(ls *.besthit.filtered.s.bam))
file=${FILES[$SLURM_ARRAY_TASK_ID]}

sample=`echo $file | cut -d"." -f1`
echo $sample
/mnt/mibi_ngs/keerthi/subread-2.0.3-Linux-x86_64/bin/featureCounts -p -T 4 -t CDS -g ID --extraAttributes gene -a ${sample}.gff -o ${sample}_contigs.featureCounts.out.txt ${sample}.besthit.filtered.s.bam

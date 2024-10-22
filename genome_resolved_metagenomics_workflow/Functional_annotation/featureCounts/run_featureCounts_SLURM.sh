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
FILES=($(ls *nbh.s.bam))
file=${FILES[$SLURM_ARRAY_TASK_ID]}

sample=`echo $file | cut -d"_" -f1`
 
#/mnt/mibi_ngs/keerthi/subread-2.0.3-Linux-x86_64/bin/featureCounts -p -Q 20 -T 4 -t CDS -g ID --extraAttributes gene -a T006_S23_unbinned_contigs.gff -o binned_3.featureCounts.out.txt T006_S23.s.bam
/mnt/mibi_ngs/keerthi/subread-2.0.3-Linux-x86_64/bin/featureCounts -p -T 4 -t CDS -g ID --extraAttributes gene -a UHGG_gff -o ${sample}_nbh.featureCounts.out.txt $file

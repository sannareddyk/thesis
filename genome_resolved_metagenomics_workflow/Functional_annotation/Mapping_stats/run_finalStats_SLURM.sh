#!/bin/bash

#Keerthi Sannareddy

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 20G

# set run on bigmem node only
#SBATCH --cpus-per-task 8

# set max wallclock time
#SBATCH --time=24:00:00

# set name of job
#SBATCH --job-name=mappingstats

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate bbmap

FILES=($(ls ./*_1.fastq))
file=${FILES[$SLURM_ARRAY_TASK_ID]}

NAME=`echo $file | cut -d"_" -f1`

##get total number of reads from fastq files
totalReads=`expr $(cat ${NAME}_trimmed_1.fastq | wc -l) / 4 + $(cat ${NAME}_trimmed_2.fastq | wc -l) / 4`
echo $totalReads
##print header to mapping log file
printf "${NAME}_level\tpaired\tsingletons\n" >${NAME}.mapping.log

##bin level
#get read counts
paired=$(samtools flagstat ${NAME}_binned_H.bam | awk -F "[ +]" -v OFS='\t' 'NR == 8 {print $1}')
echo $paired
singletons=$(samtools flagstat ${NAME}_binned_H.bam | awk -F "[ +]" -v OFS='\t' 'NR == 14 {print $1}')
echo $singletons

#calculate percentage reads mapped in pairs and singletons
percentPaired=$(awk "BEGIN {pc=100*${paired}/${totalReads};print pc}")
echo $percentPaired
percentSingletons=$(awk "BEGIN {pc=100*${singletons}/${totalReads};print pc}")
echo $percentSingletons

#percent percent paired and singletons
printf "binned\t%.1f\t" $percentPaired >>${NAME}.mapping.log
printf "%.1f\n" $percentSingletons >>${NAME}.mapping.log

##unbinned
#get read counts
paired=$(samtools flagstat ${NAME}_unbinned_H.bam | awk -F "[ +]" -v OFS='\t' 'NR == 8 {print $1}')
singletons=$(samtools flagstat ${NAME}_unbinned_H.bam | awk -F "[ +]" -v OFS='\t' 'NR == 14 {print $1}')

#calculate percentage reads mapped in pairs and singletons
percentPaired=$(awk "BEGIN {pc=100*${paired}/${totalReads};print pc}")
percentSingletons=$(awk "BEGIN {pc=100*${singletons}/${totalReads};print pc}")

#percent percent paired and singletons
printf "unbinned\t%.1f\t" $percentPaired >>${NAME}.mapping.log
printf "%.1f\n" $percentSingletons >>${NAME}.mapping.log

##unmapped
#get read counts
paired=$(samtools flagstat ${NAME}.nobesthit.filtered.bam | awk -F "[ +]" -v OFS='\t' 'NR == 2 {print $1}')
singletons=$(samtools flagstat ${NAME}.nobesthit.filtered.bam | awk -F "[ +]" -v OFS='\t' 'NR == 14 {print $1}')
#singletons=$(samtools flagstat ${NAME}.unmapped.bam | awk -F "[ +]" -v OFS='\t' 'NR == 14 {print $1}')

#calculate percentage reads mapped in pairs and singletons
percentPaired=$(awk "BEGIN {pc=100*${paired}/${totalReads};print pc}")
percentSingletons=$(awk "BEGIN {pc=100*${singletons}/${totalReads};print pc}")

#percent percent paired and singletons
printf "unmapped\t%.1f\t" $percentPaired >>${NAME}.mapping.log
printf "%.1f\n" $percentSingletons >>${NAME}.mapping.log

#samtools view -c -f0x2 -F256 G01898.s.q20.bam
#samtools view -c -f8 -F0x100 G01898.s.q20.bam

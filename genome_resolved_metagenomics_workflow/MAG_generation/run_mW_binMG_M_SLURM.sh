#!/bin/bash

#Keerthi Sannareddy, Mar 2022

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 48G

# set run on bigmem node only
#SBATCH --cpus-per-task 24

# set max wallclock time
#SBATCH --time=48:00:00

# set name of job
#SBATCH --job-name=mW_bin

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
#fastq2=${fastq1%%_trimmed_1.fastq}"_trimmed_2.fastq"
#echo $fastq2

NAME=`echo $fastq1 | cut -d"_" -f1`

#metawrap binning -o ${NAME}_BINNING -t 24 -a ${NAME}_assemble/final_assembly.fasta --metabat2 --maxbin2 --concoct ./*${NAME}*val*.fq
metawrap binning -o ${NAME}_BINNING -t 24 -a ${NAME}_assembly.fasta --metabat2 --maxbin2 --concoct ./${NAME}*trimmed*.fastq
#mv ${NAME}_BINNING/metabat2_bins/bin.unbinned.fa ${NAME}_BINNING/

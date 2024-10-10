#!/bin/bash

#Keerthi Sannareddy, Mar 2022

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 40G

# set run on bigmem node only
#SBATCH --cpus-per-task 5

# set max wallclock time
#SBATCH --time=24:00:00

# set name of job
#SBATCH --job-name=mW_binREF

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

NAME=`echo $fastq1 | cut -d"_" -f1`

#for file in M*val_1.fq.gz;
#do
#    NAME=$(awk '{split($0,a,/_/); print a[1]}' <<< ${file});

#metawrap bin_refinement -t 5 -m 200 -o ${NAME}_BIN_REFINEMENT -A ${NAME}_BINNING/metabat2_bins/ -B ${NAME}_BINNING/maxbin2_bins/ -C ${NAME}_BINNING/concoct_bins/ -c 50 -x 10
#metawrap bin_refinement -t 5 -m 40 -o ${NAME}_BIN_REFINEMENT -A ${NAME}_BINNING/metabat2_bins/ -B ${NAME}_BINNING/maxbin2_bins/ -C ${NAME}_vamb/bins/ -c 80 -x 10
metawrap bin_refinement -t 5 -m 40 -o ${NAME}_BIN_REFINEMENT -A ${NAME}_BINNING/metabat2_bins/ -B ${NAME}_BINNING/maxbin2_bins/ -C ${NAME}_BINNING/concoct_bins/ -c 80 -x 10
#done

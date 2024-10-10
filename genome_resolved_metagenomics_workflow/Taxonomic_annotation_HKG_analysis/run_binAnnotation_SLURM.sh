#!/bin/bash

#Keerthi Sannareddy, Mar 2022

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 150G

# set run on bigmem node only
#SBATCH --cpus-per-task 1

# set max wallclock time
#SBATCH --time=2-00:00:00

# set name of job
#SBATCH --job-name=runAnnotation

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

# Activate env on cluster node
. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate gtdbtk-2.1.0

FILES=($(ls *_trimmed_1.fastq))
fastq1=${FILES[$SLURM_ARRAY_TASK_ID]}
echo "My input file is ${fastq1}"
#fastq1=$(ls *_1.fastq | sed -n ${SLURM_ARRAY_TASK_ID}p)

NAME=`echo $fastq1 | cut -d"_" -f1`

#gtdbtk classify_wf --genome_dir ${NAME}_BIN_REFINEMENT/metawrap_80_10_bins --out_dir ${NAME}_BIN_REFINEMENT/Annotation -x fa --cpus 1
#gtdbtk identify --genome_dir ${NAME}_BIN_REFINEMENT/metawrap_80_10_bins --out_dir ${NAME}_BIN_REFINEMENT/marker_genes --write_single_copy_genes -x fa --cpus 4
gtdbtk identify --genome_dir ${NAME}_BIN_REFINEMENT/metawrap_80_10_bins --out_dir ${NAME}_BIN_REFINEMENT/marker_genes -x fa --cpus 4

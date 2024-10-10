#!/bin/bash

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 20G

# set run on bigmem node only
#SBATCH --cpus-per-task 8

# set max wallclock time
#SBATCH --time=24:00:00

# set name of job
#SBATCH --job-name=runAnnotation

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

# Activate env on cluster node
. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate prokka

FILES=($(ls *assembly.fasta))
file=${FILES[$SLURM_ARRAY_TASK_ID]}

NAME=`echo $file | cut -d"_" -f1`
#for file in *contigs.fasta;
#NAME=$(awk '{split($0,a,/.contigs./); print a[1]}' <<< ${file});
#NAME=$(awk '{split($0,a,".fa"); print a[1]}' <<< ${file});
echo $NAME

#prokka --cpus 8 $file --outdir ${NAME}_prokka --norrna --notrna --metagenome --locustag ${NAME} --prefix ${NAME}
prokka --cpus 8 $file --outdir ${NAME}_prokka --fast --metagenome --locustag ${NAME} --prefix ${NAME}

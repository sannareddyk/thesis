#!/bin/bash

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 20G

# set run on bigmem node only
#SBATCH --cpus-per-task 4

# set max wallclock time
#SBATCH --time=2:00:00

# set name of job
#SBATCH --job-name=runfastqc

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate metawrap-env

for file in *.fastq

        do
        	fastqc -t 4 -quiet $file

done

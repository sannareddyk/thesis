#!/bin/bash

#Keerthi Sannareddy, Apr 2022
#updated to dbCAN4 March 2023

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 20G

# set run on bigmem node only
#SBATCH --cpus-per-task 8

# set max wallclock time
#SBATCH --time=24:00:00

# set name of job
#SBATCH --job-name=rundbCAN4

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate run_dbcan-4

FILES=($(ls ./*.faa))
file=${FILES[$SLURM_ARRAY_TASK_ID]}

#NAME=`echo $file | cut -d"_" -f1-2`

infile=$file
outfile=${infile%%.faa}

run_dbcan $infile protein --db_dir /mnt/mibi_ngs/databases/db_dbCAN4 --out_dir ${outfile}_dbCAN4

sleep 10

mv ${outfile}_dbCAN4/overview.txt ${outfile}.dbCAN4.txt

##CGC
#run_dbcan $infile protein -c ${outfile}.gff --db_dir /mnt/mibi_ngs/databases/db_dbCAN3 --out_dir ${outfile}_dbCAN3_CGC

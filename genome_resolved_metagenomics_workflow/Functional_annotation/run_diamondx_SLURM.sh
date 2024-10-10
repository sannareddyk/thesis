#!/bin/bash

#Keerthi Sannareddy, Mar 2022

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 20G

# set run on bigmem node only
#SBATCH --cpus-per-task 32

# set max wallclock time
#SBATCH --time=24:00:00

# set name of job
#SBATCH --job-name=rundiamond

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate diamond

FILES=($(ls ./*.faa))
file=${FILES[$SLURM_ARRAY_TASK_ID]}

#NAME=`echo $file | cut -d"_" -f1-2`

infile=$file
outfile=${infile%%.faa}

#diamond blastx -p 32 --db /mnt/ngsnfs/seqres/uniprot/uniref50.fasta.gz.dmnd --query NG-10335_A549Flag_lib157486_5074_4_1.fasta -a out_A549_diamond.txt --id 90 --max-target-seqs 2 --evalue 1e-50
#diamond blastx -p 32 --db /mnt/mibi_ngs/databases/uniref/uniref90.fasta.dmnd --query ./bin.unbinned.fa -a out_unbinned_diamond_1.txt --id 70 --max-target-seqs 2 --evalue 1e-50
diamond blastp -p 32 --db /mnt/mibi_ngs/databases/uniref/uniref90.fasta.dmnd --query $file -f 6 qseqid sseqid pident qcovhsp scovhsp length slen qlen evalue --max-target-seqs 1 -o $outfile.blastp.txt

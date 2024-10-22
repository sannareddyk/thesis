#!/bin/bash

#Keerthi Sannareddy, Aug 2023

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 10G

# set run on bigmem node only
#SBATCH --cpus-per-task 1

# set max wallclock time
#SBATCH --time=10:00:00

# set name of job
#SBATCH --job-name=runProcess

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=sannareddy.keerthi@mh-hannover.de

#SBATCH --array=0-1

. /mnt/mibi_ngs/keerthi/miniconda3/etc/profile.d/conda.sh
conda activate pandas

FILES=($(ls *.merge_out.txt))
file=${FILES[$SLURM_ARRAY_TASK_ID]}

sample=${file%%.merge_out.txt}

python3 summarize_KO.py ${sample}.KO_counts.final.txt ${sample}.KO_summarize.txt
python3 summarize_PF.py ${sample}.PF_counts.final.txt ${sample}.PF_summarize.txt
python3 summarize_GO.py ${sample}.GO_counts.final.txt ${sample}.GO_summarize.txt
python3 summarize_UniRef.py ${sample}.Uniref_counts.final.txt ${sample}.Uniref_summarize.txt
python3 summarize_dbCAN4.py ${sample}.CAZy_counts.final.txt ${sample}.CAZy_summarize.txt


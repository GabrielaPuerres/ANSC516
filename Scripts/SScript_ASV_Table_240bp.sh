#!/bin/sh -l

#SBATCH --job-name=Script_ASV_Table_240bp
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --time=4:00:00
#SBATCH -A nightingale
#SBATCH --output=%x_%j_slurm.out
#SBATCH --error=%x_%j_slurm.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=dpuerres@purdue.edu

#########################################################################

echo "Start time"
date +"%d %B %Y %H:%M:%S"

echo "Job started on $(date)"
echo "Running on node: $(hostname)"
echo "CPUs allocated: $SLURM_CPUS_PER_TASK"

THREADS=${SLURM_CPUS_PER_TASK}

#step 1, cd into the proper directory. This directory must already exist

DIR=/depot/islizovs/shared/projects/Cow_Inflammation_Study_Blood_Slizovskiy_Project_004/07_QIIME2
cd "$DIR"
pwd

# Load modules
ml biocontainers
ml qiime2

#step 2, Run dada2
echo "dada2"

qiime dada2 denoise-single \
  --i-demultiplexed-seqs Final_demux-paired-end.qza \
  --p-trim-left 0 \
  --p-trunc-len 240 \
  --p-n-threads ${THREADS} \
  --o-representative-sequences rep-seqs-240bp.qza \
  --o-table table-240bp.qza \
  --o-denoising-stats stats-dada2-240bp.qza

#Convert .qza to .qzv format

qiime metadata tabulate \
  --m-input-file stats-dada2-240bp.qza \
  --o-visualization stats-dada2-240bp.qzv


#Create a .qzv from the output of denoise
qiime feature-table summarize \
  --i-table table-240bp.qza \
  --o-visualization table-240bp.qzv \
  --m-sample-metadata-file QIIME2_Blood_Metadata_02.27.26.txt

qiime feature-table tabulate-seqs \
  --i-data rep-seqs-240bp.qza \
  --o-visualization rep-seqs-240bp.qzv


echo "End time"
date +"%d %B %Y %H:%M:%S"

#to run: sbatch Script_ASV_Table_240bp.sh

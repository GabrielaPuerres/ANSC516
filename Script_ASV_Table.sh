#!/bin/sh -l

#SBATCH --job-name=Script_ASV_Table
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --time=4:00:00
#SBATCH -A life
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
module --force purge
ml biocontainers
ml qiime2

module --force purge
module load biocontainers
module load qiime2

export MPLCONFIGDIR=$HOME/.matplotlib
mkdir -p $MPLCONFIGDIR

# step 2, Import data using the manifest file
qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
--input-path Manifest_Blood_Microbiome.txt \
--input-format PairedEndFastqManifestPhred33V2 \
--output-path Final_demux-paired-end.qza 

qiime demux summarize \
--i-data Final_demux-paired-end.qza \
--o-visualization Final_demux-paired-end.qzv


#step 3, Run dada2
echo "dada2"

qiime dada2 denoise-paired \
    --i-demultiplexed-seqs Final_demux-paired-end.qza \
    --p-trim-left-f 10 \
    --p-trim-left-r 13 \
    --p-trunc-len-f 260 \
    --p-trunc-len-r 260 \
    --p-n-threads ${THREADS} \
    --o-representative-sequences rep-seqs.qza \
    --o-table table.qza \
    --o-denoising-stats stats-dada2.qza

#Convert .qza to .qzv format

qiime metadata tabulate \
  --m-input-file stats-dada2.qza \
  --o-visualization stats-dada2.qzv


#Create a .qzv from the output of denoise
qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file QIIME2_Blood_Metadata_02.27.26.txt  


qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv


echo "End time"
date +"%d %B %Y %H:%M:%S"

#to run: sbatch Script_ASV_Table.sh
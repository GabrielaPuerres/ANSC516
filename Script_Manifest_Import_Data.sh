#!/bin/sh -l

#SBATCH --job-name=QIIME2_Demux
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=70
#SBATCH --mem=220G
#SBATCH --time=48:00:00
#SBATCH -A nightingale
#SBATCH --output=slurm_%x_%j.out
#SBATCH --error=slurm_%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=dpuerres@purdue.edu

#########################################################################

echo "Start time"
date +"%d %B %Y %H:%M:%S"

#step 1, cd into the proper directory. This directory must already exist

cd /depot/islizovs/shared/projects/Cow_Inflammation_Study_Blood_Slizovskiy_Project_004/07_QIIME2
pwd

module load biocontainers
module load qiime2

qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
--input-path Manifest_Blood_Microbiome.txt \
--input-format PairedEndFastqManifestPhred33V2 \
--output-path Final_demux-paired-end.qza 

qiime demux summarize \
--i-data Final_demux-paired-end.qza \
--o-visualization Final_demux-paired-end.qzv

ls 

echo "End time"
date +"%d %B %Y %H:%M:%S"

#to run: sbatch Script_Manifest_Import_Data.slurm

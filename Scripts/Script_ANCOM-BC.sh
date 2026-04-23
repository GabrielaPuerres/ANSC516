#!/bin/sh -l

#SBATCH --job-name=Script_ANCOMBC_240bp
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=168:00:00
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
module list

# ======
echo "Filter away some sample types and do ancom"

# Filter to just blood samples
qiime feature-table filter-samples \
  --i-table table-240bp.qza \
  --m-metadata-file QIIME2_Blood_Metadata_02.27.26.txt \
  --p-where "[Sample_Type]='Blood'" \
  --o-filtered-table Blood-table-240bp.qza

# Visualize the filtered table
qiime feature-table summarize \
  --i-table Blood-table-240bp.qza \
  --o-visualization Blood-table-240bp.qzv

# Filter to just features with at least 10001 counts across at least 5 samples
qiime feature-table filter-features \
  --i-table Blood-table-240bp.qza \
  --o-filtered-table Blood-table-240bp-filtered-1000.qza \
  --p-min-frequency 10001 \
  --p-min-samples 5 

qiime feature-table summarize \
  --i-table Blood-table-240bp-filtered-1000.qza  \
  --o-visualization Blood-table-240bp-filtered-1000.qzv

# Filter features by abundance and prevalence
qiime feature-table filter-features-conditionally \
  --i-table Blood-table-240bp.qza \
  --p-abundance 0.005 \
  --p-prevalence 0.05 \
  --o-filtered-table Blood-table-240bp-filtered-prevalence.qza


qiime feature-table summarize \
  --i-table Blood-table-240bp-filtered-prevalence.qza  \
  --o-visualization Blood-table-240bp-filtered-prevalence.qzv


# Run ancombc on the filtered table 
qiime composition ancombc \
  --i-table Blood-table-240bp-filtered-prevalence.qza \
  --m-metadata-file QIIME2_Blood_Metadata_02.27.26.txt \
  --p-formula 'Haptoglobin_InflamStat' \
  --o-differentials ancombc-Haptoglobin_InflamStat-240bp.qzv

qiime composition da-barplot \
  --i-data ancombc-Haptoglobin_InflamStat-240bp.qzv \
  --p-significance-threshold 0.001 \
  --o-visualization da-barplot-Haptoglobin_InflamStat-240bp.qzv









# Run ancom on the filtered table
qiime composition ancom \
  --i-table comp-Blood-table-240bp.qza \
  --m-metadata-file QIIME2_Blood_Metadata_02.27.26.txt \
  --m-metadata-column Haptoglobin_InflamStat \
  --o-visualization ancom-Haptoglobin_InflamStat-240bp.qzv

echo "Collapse levels and ancom again."

qiime taxa collapse \
  --i-table Blood-table-240bp-filtered-prevalence.qza \
  --i-taxonomy taxonomy-240bp.qza \
  --p-level 6 \
  --o-collapsed-table Blood-table-l6-240bp.qza

qiime composition add-pseudocount \
  --i-table Blood-table-l6-240bp.qza \
  --o-composition-table comp-Blood-table-l6-240bp.qza

qiime composition ancom \
  --i-table comp-Blood-table-l6-240bp.qza \
  --m-metadata-file QIIME2_Blood_Metadata_02.27.26.txt \
  --m-metadata-column Haptoglobin_InflamStat \
  --o-visualization l6-ancom-Haptoglobin_InflamStat-240bp.qzv

echo "End time"
date +"%d %B %Y %H:%M:%S"

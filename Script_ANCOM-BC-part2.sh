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


# optionally, set R environment variables to avoid issues with R packages when running ANCOM-BC
export R_LIBS_USER=NULL
export R_LIBS=NULL
export R_LIBS_SITE=NULL
export R_ENVIRON_USER=NULL
export R_PROFILE_USER=NULL
export MPLCONFIGDIR=/tmp/$USER-matplotlib

echo "Filter away some sample types and do ancom"
# Files
METADATA=QIIME2_Blood_Metadata_04.03.26.txt

# Filter to just blood samples
qiime feature-table filter-samples \
  --i-table table-240bp.qza \
  --m-metadata-file QIIME2_Blood_Metadata_04.03.26.txt \
  --p-where "[Sample_Type]='Blood'" \
  --o-filtered-table Blood-table-240bp.qza

qiime composition ancombc \
  --i-table Blood-table-240bp.qza \
  --m-metadata-file QIIME2_Blood_Metadata_04.03.26.txt \
  --p-formula 'Haptoglobin_InflamStat' \
  --o-differentials ancombc-Haptoglobin_InflamStat.qza 

qiime composition da-barplot \
  --i-data ancombc-Haptoglobin_InflamStat.qza \
  --p-significance-threshold 0.001 \
  --o-visualization da-barplot-Haptoglobin_InflamStat.qzv

qiime taxa collapse \
  --i-table Blood-table-240bp.qza \
  --i-taxonomy taxonomy-240bp.qza \
  --p-level 6 \
  --o-collapsed-table Blood-table-l6-240bp.qza

qiime composition ancombc \
  --i-table Blood-table-l6-240bp.qza \
  --m-metadata-file QIIME2_Blood_Metadata_04.03.26.txt \
  --p-formula 'Haptoglobin_InflamStat' \
  --o-differentials l6-ancombc-Haptoglobin_InflamStat.qza

qiime composition da-barplot \
  --i-data l6-ancombc-Haptoglobin_InflamStat.qza \
  --p-significance-threshold 0.001 \
  --p-level-delimiter ';' \
  --o-visualization l6-da-barplot-Haptoglobin_InflamStat.qzv

# Fibrinogen Analysis
qiime composition ancombc \
  --i-table Blood-table-240bp.qza \
  --m-metadata-file QIIME2_Blood_Metadata_04.03.26.txt \
  --p-formula 'Fibrinogen_InflamStat' \
  --o-differentials ancombc-Fibrinogen_InflamStat.qza

qiime composition da-barplot \
  --i-data ancombc-Fibrinogen_InflamStat.qza \
  --p-significance-threshold 0.001 \
  --o-visualization da-barplot-Fibrinogen_InflamStat.qzv

qiime taxa collapse \
  --i-table Blood-table-240bp.qza \
  --i-taxonomy taxonomy-240bp.qza \
  --p-level 6 \
  --o-collapsed-table Blood-table-fibrinogen-l6-240bp.qza

qiime composition ancombc \
  --i-table Blood-table-fibrinogen-l6-240bp.qza \
  --m-metadata-file QIIME2_Blood_Metadata_04.03.26.txt \
  --p-formula 'Fibrinogen_InflamStat' \
  --o-differentials l6-ancombc-Fibrinogen_InflamStat.qza

qiime composition da-barplot \
  --i-data l6-ancombc-Fibrinogen_InflamStat.qza \
  --p-significance-threshold 0.001 \
  --p-level-delimiter ';' \
  --o-visualization l6-da-barplot-Fibrinogen_InflamStat.qzv

# Parity Analysis
qiime composition ancombc \
  --i-table Blood-table-240bp.qza \
  --m-metadata-file QIIME2_Blood_Metadata_04.03.26.txt \
  --p-formula 'Parity' \
  --o-differentials ancombc-Parity.qza

qiime composition da-barplot \
  --i-data ancombc-Parity.qza \
  --p-significance-threshold 0.001 \
  --o-visualization da-barplot-Parity.qzv

qiime taxa collapse \
  --i-table Blood-table-240bp.qza \
  --i-taxonomy taxonomy-240bp.qza \
  --p-level 6 \
  --o-collapsed-table Blood-table-parity-l6-240bp.qza

qiime composition ancombc \
  --i-table Blood-table-parity-l6-240bp.qza \
  --m-metadata-file QIIME2_Blood_Metadata_04.03.26.txt \
  --p-formula 'Parity' \
  --o-differentials l6-ancombc-Parity.qza

qiime composition da-barplot \
  --i-data l6-ancombc-Parity.qza \
  --p-significance-threshold 0.001 \
  --p-level-delimiter ';' \
  --o-visualization l6-da-barplot-Parity.qzv


echo "End time"
date +"%d %B %Y %H:%M:%S"
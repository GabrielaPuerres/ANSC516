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


sinteractive -A microbiome -t 2:30:00 -n4
module load conda
conda activate qiime2-amplicon-2024.10
conda info

## Fibrinogen ---------------------------------------------------------------
qiime sample-classifier classify-samples \
  --i-table Blood-table-240bp.qza \
  --m-metadata-file QIIME2_Blood_Metadata_02.27.26.txt \
  --m-metadata-column Fibrinogen_InflamStat \
  --p-optimize-feature-selection \
  --p-parameter-tuning \
  --p-estimator RandomForestClassifier \
  --p-n-estimators 20 \
  --p-random-state 123 \
  --output-dir moving-pictures-classifier


qiime metadata tabulate \
  --m-input-file moving-pictures-classifier/predictions.qza \
  --o-visualization moving-pictures-classifier/predictions.qzv

qiime metadata tabulate \
  --m-input-file moving-pictures-classifier/probabilities.qza \
  --o-visualization moving-pictures-classifier/probabilities.qzv

qiime metadata tabulate \
  --m-input-file moving-pictures-classifier/feature_importance.qza \
  --o-visualization moving-pictures-classifier/feature_importance.qzv

qiime feature-table filter-features \
  --i-table Blood-table-240bp.qza \
  --m-metadata-file moving-pictures-classifier/feature_importance.qza \
  --o-filtered-table moving-pictures-classifier/important-feature-table.qza

qiime sample-classifier heatmap \
  --i-table Blood-table-240bp.qza \
  --i-importance moving-pictures-classifier/feature_importance.qza \
  --m-sample-metadata-file QIIME2_Blood_Metadata_02.27.26.txt \
  --m-sample-metadata-column Fibrinogen_InflamStat \
  --p-group-samples \
  --p-feature-count 30 \
  --o-filtered-table moving-pictures-classifier/important-feature-table-top-30.qza \
  --o-heatmap moving-pictures-classifier/important-feature-heatmap.qzv

qiime sample-classifier heatmap \
--i-table Blood-table-240bp.qza \
--i-importance moving-pictures-classifier/feature_importance.qza  \
--m-sample-metadata-file QIIME2_Blood_Metadata_02.27.26.txt  \
--m-sample-metadata-column Fibrinogen_InflamStat \
--m-feature-metadata-file taxonomy-240bp.qza \
--m-feature-metadata-column Taxon \
--p-group-samples  \
--p-feature-count 30  \
--o-filtered-table moving-pictures-classifier/important-feature-table-taxonomy-top-30.qza \
--o-heatmap moving-pictures-classifier/important-feature-heatmap-taxonomy.qzv


## Haptoglobin ---------------------------------------------------------------
qiime sample-classifier classify-samples \
  --i-table Blood-table-240bp.qza \
  --m-metadata-file QIIME2_Blood_Metadata_02.27.26.txt \
  --m-metadata-column Haptoglobin_InflamStat \
  --p-optimize-feature-selection \
  --p-parameter-tuning \
  --p-estimator RandomForestClassifier \
  --p-n-estimators 20 \
  --p-random-state 123 \
  --output-dir moving-pictures-classifier-haptoglobin


qiime metadata tabulate \
  --m-input-file moving-pictures-classifier-haptoglobin/predictions.qza \
  --o-visualization moving-pictures-classifier-haptoglobin/predictions.qzv

qiime metadata tabulate \
  --m-input-file moving-pictures-classifier-haptoglobin/probabilities.qza \
  --o-visualization moving-pictures-classifier-haptoglobin/probabilities.qzv

qiime metadata tabulate \
  --m-input-file moving-pictures-classifier-haptoglobin/feature_importance.qza \
  --o-visualization moving-pictures-classifier-haptoglobin/feature_importance.qzv

qiime feature-table filter-features \
  --i-table Blood-table-240bp.qza \
  --m-metadata-file moving-pictures-classifier-haptoglobin/feature_importance.qza \
  --o-filtered-table moving-pictures-classifier-haptoglobin/important-feature-table.qza

qiime sample-classifier heatmap \
  --i-table Blood-table-240bp.qza \
  --i-importance moving-pictures-classifier-haptoglobin/feature_importance.qza \
  --m-sample-metadata-file QIIME2_Blood_Metadata_02.27.26.txt \
  --m-sample-metadata-column Haptoglobin_InflamStat \
  --p-group-samples \
  --p-feature-count 30 \
  --o-filtered-table moving-pictures-classifier-haptoglobin/important-feature-table-top-30.qza \
  --o-heatmap moving-pictures-classifier-haptoglobin/important-feature-heatmap.qzv

qiime sample-classifier heatmap \
--i-table Blood-table-240bp.qza \
--i-importance moving-pictures-classifier-haptoglobin/feature_importance.qza  \
--m-sample-metadata-file QIIME2_Blood_Metadata_02.27.26.txt  \
--m-sample-metadata-column Haptoglobin_InflamStat \
--m-feature-metadata-file taxonomy-240bp.qza \
--m-feature-metadata-column Taxon \
--p-group-samples  \
--p-feature-count 30  \
--o-filtered-table moving-pictures-classifier-haptoglobin/important-feature-table-taxonomy-top-30.qza \
--o-heatmap moving-pictures-classifier-haptoglobin/important-feature-heatmap-taxonomy.qzv
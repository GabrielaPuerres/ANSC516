#!/bin/sh -l

#SBATCH --job-name=Script_Diversity_240bp
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
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

# Phylogenetic tree
echo "Create a phylogenetic tree. (Phylogenetic method)"
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs-240bp.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza

# Rarefaction curve
echo "Rarefaction"
qiime diversity alpha-rarefaction \
  --i-table table-240bp.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 4000 \
  --m-metadata-file QIIME2_Blood_Metadata_02.27.26.txt \
  --o-visualization alpha-rarefaction.qzv


#!/bin/bash
#SBATCH --job-name=download
#SBATCH --time=72:00:00
#SBATCH --mem=100Gb
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --workdir=/home/pedro.barbosa/scratch/downloads
#SBATCH --output=/home/pedro.barbosa/scratch/%j_download.log

wget -c https://storage.googleapis.com/gtex_analysis_v7/rna_seq_data/GTEx_Analysis_2016-01-15_v7_STARv2.4.2a_junctions.gct.gz
#wget -c https://storage.googleapis.com/gtex_analysis_v7/annotations/GTEx_Analysis_v7_Annotations_SampleAttributesDD.xlsx
#wget -c https://storage.googleapis.com/gtex_analysis_v7/annotations/GTEx_Analysis_v7_Annotations_SubjectPhenotypesDD.xlsx
#wget -c https://storage.googleapis.com/gtex_analysis_v7/annotations/GTEx_v7_Annotations_SampleAttributesDS.txt
#wget -c https://storage.googleapis.com/gtex_analysis_v7/annotations/GTEx_v7_Annotations_SubjectPhenotypesDS.txt
#wget -c https://storage.googleapis.com/gtex_analysis_v7/rna_seq_data/GTEx_Analysis_2016-01-15_v7_RNASeQCv1.1.8_gene_reads.gct.gz
#wget -c https://storage.googleapis.com/gtex_analysis_v7/rna_seq_data/GTEx_Analysis_2016-01-15_v7_RNASeQCv1.1.8_gene_tpm.gct.gz
#wget -c https://storage.googleapis.com/gtex_analysis_v7/rna_seq_data/GTEx_Analysis_2016-01-15_v7_RSEMv1.2.22_transcript_tpm.txt.gz

mv GTX* $SLURM_SUBMIT_DIR 


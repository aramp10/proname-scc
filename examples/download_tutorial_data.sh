#!/bin/bash
set -euo pipefail
module load sratoolkit/3.3.0

mkdir -p RawData

# NCBI BioProject PRJNA1299388 -- PRONAME's own tutorial test dataset
# (10 nanopore amplicon runs, 16S-ITS-23S rRNA operon, tomato root bacterial communities)
declare -A SAMPLES=(
  [SRR34795474]=sample1
  [SRR34795473]=sample2
  [SRR34795472]=sample3
  [SRR34795471]=sample4
  [SRR34795470]=sample5
  [SRR34795469]=sample6
  [SRR34795468]=sample7
  [SRR34795467]=sample8
  [SRR34795466]=sample9
  [SRR34795465]=sample10
)

for srr in "${!SAMPLES[@]}"; do
  name="${SAMPLES[$srr]}"
  prefetch "$srr"
  fasterq-dump "$srr" --outdir RawData/
  mv "RawData/${srr}.fastq" "RawData/${name}.fastq"
  rm -rf "$srr"   # prefetch's own <accession>/<accession>.sra dir, left in cwd
done

rm -rf ~/ncbi/public/sra   # prefetch's separate cache under home, not cleared above

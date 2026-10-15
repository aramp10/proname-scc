#!/bin/bash
# Runs inside the container. Usage: bash taxonomy.sh /path/to/config.sh /path/to/metadata.tsv
set -euo pipefail
source "$1"
cd "$WORKDIR"
proname_taxonomy \
  --qseqs rep_seqs.qza \
  --qtable rep_table.qza \
  --db /opt/db/rEGEN-B/rEGEN-B_sequences.fasta \
  --reftax /opt/db/rEGEN-B/rEGEN-B_taxonomy.tsv \
  --threads "$NSLOTS" \
  --metadata "$2" \
  --assay assay1 \
  --phyloseq yes

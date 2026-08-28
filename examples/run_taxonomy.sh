#!/bin/bash
set -euo pipefail
cd /projectnb/your_project/your_workdir
proname_taxonomy \
  --qseqs /projectnb/your_project/refine_output/rep_seqs.qza \
  --qtable /projectnb/your_project/refine_output/rep_table.qza \
  --db /opt/db/rEGEN-B/rEGEN-B_sequences.fasta \
  --reftax /opt/db/rEGEN-B/rEGEN-B_taxonomy.tsv \
  --threads "$NSLOTS" \
  --metadata /projectnb/your_project/sample_metadata.tsv \
  --assay assay1 \
  --phyloseq yes
# --phyloseq yes requires rep_seqs.fasta and rep_table.tsv (produced
# alongside rep_seqs.qza/rep_table.qza by proname_refine) to also be
# present as plain files in this script's cwd -- symlink them in from
# your refine output directory if they aren't already there, or the
# main taxonomy step will succeed but phyloseq object creation will fail.

#!/bin/bash
set -euo pipefail
cd /projectnb/your_project/your_workdir
proname_taxonomy \
  --qseqs rep_seqs.qza \
  --qtable rep_table.qza \
  --db /opt/db/rEGEN-B/rEGEN-B_sequences.fasta \
  --reftax /opt/db/rEGEN-B/rEGEN-B_taxonomy.tsv \
  --threads "$NSLOTS" \
  --metadata /projectnb/your_project/sample_metadata.tsv \
  --assay assay1 \
  --phyloseq yes
# --qseqs/--qtable are relative here because this script runs in the same
# working directory as run_refine.sh, which is where proname_refine wrote
# rep_seqs.qza/rep_table.qza. If you instead run refine/taxonomy in
# separate directories, use absolute paths to those two files, AND
# separately copy/symlink in rep_seqs.fasta and rep_table.tsv (also
# produced by proname_refine) -- --phyloseq yes looks for those two as
# plain files in this script's own cwd, not via --qseqs/--qtable, and
# will fail at that step (while the main taxonomy assignment still
# succeeds) if they aren't there.
